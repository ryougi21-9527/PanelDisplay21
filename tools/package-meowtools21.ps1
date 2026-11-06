<#
.SYNOPSIS
    为「21的喵喵工具」出包（捆绑式：面板显示 + 宝箱高亮 + 小地图）。
.DESCRIPTION
    默认输出到 E:\开发\雨中冒险2mod\出包文件夹，每次出包前会先删掉该目录里上一次的 *.zip。
    一个包里放四个插件 dll：
      - PanelDisplay21.dll   （本项目源码编译）
      - QoLChests.dll        （从本机 r2modman profile 取）
      - MiniMapMod.dll       （从本机 r2modman profile 取）
      - MiniMapLibrary.dll   （从本机 r2modman profile 取）
    产出两个包：
      1) r2modman / Thunderstore Mod Manager 导入包
      2) 手动安装包（内置 RiskOfOptions，解压到游戏根目录即用）
.PARAMETER OutDir
    出包目录，默认 E:\开发\雨中冒险2mod\出包文件夹
.PARAMETER SkipBuild
    跳过 dotnet build，直接用现有 bin\Debug 产物
#>
[CmdletBinding()]
param(
    [string]$OutDir = 'E:\开发\雨中冒险2mod\出包文件夹',
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$repoRoot = Split-Path -Parent $PSScriptRoot          # ...\LookingGlass-main
$proj     = Join-Path $repoRoot 'LookingGlass\LookingGlass.csproj'
$thunder  = Join-Path $repoRoot 'Thunderstore'
$iconPng  = Join-Path $thunder 'icons\meowtools21-icon.png'

$packName = '21的喵喵工具'

# ---------- 读版本 / 程序集名 ----------
$csprojText = Get-Content $proj -Raw -Encoding UTF8
$version = [regex]::Match($csprojText, '<MinVerVersionOverride[^>]*>([^<]+)</MinVerVersionOverride>').Groups[1].Value
if (-not $version) { throw '没能从 csproj 读到 MinVerVersionOverride' }
$asmName = [regex]::Match($csprojText, '<AssemblyName>([^<]+)</AssemblyName>').Groups[1].Value
if (-not $asmName) { $asmName = 'PanelDisplay21' }

Write-Host "包名: $packName   版本: $version   主程序集: $asmName" -ForegroundColor Cyan

# ---------- 构建 ----------
if (-not $SkipBuild) {
    Write-Host 'dotnet build -c Debug ...' -ForegroundColor Cyan
    dotnet build $proj -c Debug --nologo
    if ($LASTEXITCODE -ne 0) { throw "dotnet build 失败，退出码 $LASTEXITCODE" }
}

$dll = Join-Path $repoRoot "LookingGlass\bin\Debug\netstandard2.1\$asmName.dll"
if (-not (Test-Path $dll)) { throw "找不到产物: $dll" }

# ---------- 从 r2modman profile 找要捆绑的插件 ----------
$profilesRoot = Join-Path $env:APPDATA 'r2modmanPlus-local\RiskOfRain2\profiles'
function Find-PluginDll {
    param([string]$FileName)
    Get-ChildItem $profilesRoot -Recurse -Filter $FileName -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

$qol     = Find-PluginDll 'QoLChests.dll'
$mini    = Find-PluginDll 'MiniMapMod.dll'
$miniLib = Find-PluginDll 'MiniMapLibrary.dll'
$roo     = Get-ChildItem $profilesRoot -Directory -ErrorAction SilentlyContinue |
    ForEach-Object { Join-Path $_.FullName 'BepInEx\plugins\Rune580-Risk_Of_Options\RiskOfOptions\RiskOfOptions.dll' } |
    Where-Object { Test-Path $_ } |
    ForEach-Object { Get-Item $_ } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

foreach ($pair in @(
    @{ Name = 'QoLChests.dll';    Item = $qol },
    @{ Name = 'MiniMapMod.dll';   Item = $mini },
    @{ Name = 'MiniMapLibrary.dll'; Item = $miniLib },
    @{ Name = 'RiskOfOptions.dll'; Item = $roo }
)) {
    if (-not $pair.Item) { throw "没找到 $($pair.Name)（r2modman profile 里）" }
    Write-Host ("{0,-20} {1} 字节  {2}" -f $pair.Name, $pair.Item.Length, $pair.Item.FullName) -ForegroundColor Cyan
}

# ---------- 输出目录 ----------
$OutDir = [System.IO.Path]::GetFullPath($OutDir)
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

# 每次出包先删掉上一次的包（只删本脚本自己产出的，别碰 tcli 出的 Thunderstore 包）
$old = Get-ChildItem $OutDir -File -Filter "$packName-*.zip" -ErrorAction SilentlyContinue
foreach ($f in $old) {
    Write-Host "删除旧包: $($f.Name)" -ForegroundColor DarkYellow
    Remove-Item $f.FullName -Force
}

# ---------- 工具函数 ----------
function New-Staging {
    $s = Join-Path $env:TEMP ('MeowTools21_pack_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $s -Force | Out-Null
    return $s
}

function Copy-Into {
    param([string]$Src, [string]$Stage, [string]$Rel)
    $dst = Join-Path $Stage $Rel
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Copy-Item $Src $dst -Force
}

function Write-TextFile {
    param([string]$Stage, [string]$Rel, [string]$Text)
    $dst = Join-Path $Stage $Rel
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($dst, $Text, (New-Object System.Text.UTF8Encoding($false)))
}

function New-ZipFromStage {
    param([string]$Stage, [string]$ZipPath)
    if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
    $files = Get-ChildItem $Stage -Recurse -File
    # 注意：$env:TEMP 可能是 8.3 短路径（如 C:\Users\RYOUGI~1\...），
    # 而 Get-ChildItem 返回的是长路径，直接用 $Stage.Length 截取会算错。
    # 用「临时目录叶子名」定位，长短路径下都稳。
    $leaf = Split-Path $Stage -Leaf
    $marker = '\' + $leaf + '\'
    $fs = [System.IO.File]::Open($ZipPath, [System.IO.FileMode]::CreateNew)
    try {
        $archive = [System.IO.Compression.ZipArchive]::new($fs, [System.IO.Compression.ZipArchiveMode]::Create, $false)
        try {
            foreach ($f in $files) {
                $idx = $f.FullName.IndexOf($marker, [System.StringComparison]::OrdinalIgnoreCase)
                if ($idx -lt 0) { throw "无法计算相对路径: $($f.FullName)" }
                $rel = $f.FullName.Substring($idx + $marker.Length).Replace('\', '/')
                $entry = $archive.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
                $entry.LastWriteTime = [DateTimeOffset]$f.LastWriteTime
                $es = $entry.Open()
                try {
                    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
                    $es.Write($bytes, 0, $bytes.Length)
                }
                finally { $es.Dispose() }
            }
        }
        finally { $archive.Dispose() }
    }
    finally { $fs.Dispose() }
}

$manifest = @"
{
  "name": "$packName",
  "author": "21的大肥鱼",
  "version_number": "$version",
  "website_url": "",
  "description": "自用整合包：改写版 LookingGlass 全中文面板 + QoLChests 宝箱高亮 + MiniMapMod 小地图。",
  "dependencies": [
    "bbepis-BepInExPack-5.4.2122",
    "Rune580-Risk_Of_Options-2.8.6",
    "RiskofThunder-HookGenPatcher-1.2.9"
  ]
}
"@

$readme = @"
# $packName $version

自用整合包，一个包装三样东西：

| 功能 | 来源 | 说明 |
|---|---|---|
| 全中文状态面板 | 本包自带（改写 LookingGlass） | 右侧属性条、物品数值、buff 提示 |
| 宝箱高亮 / 空箱隐藏 | QoLChests 1.3.6 | 宝箱、神龛、商店终端都高亮 |
| 小地图 | MiniMapMod 4.0.0 | 按 M 显示/隐藏 |

- 需要 BepInEx 5.4.21+（RoR2BepInExPack）
- 需要 RiskOfOptions 2.8.3+
- 需要 HookGenPatcher（QoLChests 和小地图都靠它生成 hook）
- 不要和原版 LookingGlass、单独的 QoLChests、单独的 MiniMapMod 同时启用
"@

$installNote = @"
$packName $version — 手动安装说明

【安装前确认】
1. 你的游戏已经装了 BepInEx（装过其他 mod 一般都有）。
2. 没有装过原版 LookingGlass、QoLChests、MiniMapMod；装过请先在 mod 管理器里停用。

【安装】
把压缩包里的 BepInEx 文件夹整个解压到游戏根目录
（Steam 里右键游戏 -> 管理 -> 浏览本地文件，能看到 Risk of Rain 2.exe 的那一层），
覆盖提示选「是」。

解压后应该是：
  BepInEx\plugins\PanelDisplay21\PanelDisplay21.dll
  BepInEx\plugins\QoLChests\QoLChests.dll
  BepInEx\plugins\MiniMapMod\MiniMapMod.dll
  BepInEx\plugins\MiniMapMod\MiniMapLibrary.dll
  BepInEx\plugins\RiskOfOptions\RiskOfOptions.dll

【还缺一个】HookGenPatcher
本包没有内置它，去 mod 站装一次即可（装过就跳过）：
  https://thunderstore.io/package/RiskofThunder/HookGenPatcher/
  或者管理器里搜 HookGenPatcher 装上、启用。
它负责生成 MMHOOK_Assembly-CSharp.dll，宝箱高亮和小地图都依赖它。

【注意】
- 如果你已经装过 RiskOfOptions，就跳过 BepInEx\plugins\RiskOfOptions 这个文件夹，别覆盖。
- 进游戏后，设置里的 Risk of Options 里能看到「21的面板显示」「QoLChests」「Mini Map Mod」，说明都加载成功。
- 小地图按 M 显示/隐藏。
- 如果某个功能不出现：看 BepInEx\LogOutput.log 里对应插件名的报错。
"@

# ---------- 包 1：r2modman 导入包 ----------
$stage1 = New-Staging
try {
    Write-TextFile $stage1 'manifest.json' $manifest
    Write-TextFile $stage1 'README.md' $readme
    if (Test-Path $iconPng) { Copy-Into $iconPng $stage1 'icon.png' }
    Copy-Into $dll $stage1 "plugins\$asmName\$asmName.dll"
    Copy-Into $qol.FullName  $stage1 'plugins\QoLChests\QoLChests.dll'
    Copy-Into $mini.FullName $stage1 'plugins\MiniMapMod\MiniMapMod.dll'
    Copy-Into $miniLib.FullName $stage1 'plugins\MiniMapMod\MiniMapLibrary.dll'
    $zip1 = Join-Path $OutDir "$packName-$version-r2modman导入包.zip"
    New-ZipFromStage $stage1 $zip1
}
finally { Remove-Item $stage1 -Recurse -Force -ErrorAction SilentlyContinue }

# ---------- 包 2：手动安装（内置 RiskOfOptions） ----------
$stage2 = New-Staging
try {
    Copy-Into $dll $stage2 "BepInEx\plugins\$asmName\$asmName.dll"
    Copy-Into $qol.FullName     $stage2 'BepInEx\plugins\QoLChests\QoLChests.dll'
    Copy-Into $mini.FullName    $stage2 'BepInEx\plugins\MiniMapMod\MiniMapMod.dll'
    Copy-Into $miniLib.FullName $stage2 'BepInEx\plugins\MiniMapMod\MiniMapLibrary.dll'
    Copy-Into $roo.FullName     $stage2 'BepInEx\plugins\RiskOfOptions\RiskOfOptions.dll'
    Write-TextFile $stage2 '安装说明.txt' $installNote
    $zip2 = Join-Path $OutDir "$packName-$version-手动安装(含RiskOfOptions).zip"
    New-ZipFromStage $stage2 $zip2
}
finally { Remove-Item $stage2 -Recurse -Force -ErrorAction SilentlyContinue }

# ---------- 汇总 ----------
Write-Host ''
Write-Host '===== 出包结果 =====' -ForegroundColor Green
Get-ChildItem $OutDir -File -Filter '*.zip' | ForEach-Object {
    $sha = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
    "{0,10} 字节  {1}" -f $_.Length, $_.Name
    "            SHA256 $sha"
}
Write-Host ''
Write-Host '主插件 dll:' -ForegroundColor Green
$dllHash = (Get-FileHash $dll -Algorithm SHA256).Hash
"  {0}  {1} 字节  SHA256 {2}" -f $dll, (Get-Item $dll).Length, $dllHash
