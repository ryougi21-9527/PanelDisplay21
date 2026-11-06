<#
.SYNOPSIS
    为「21的面板显示」(PanelDisplay21) 出包。
.DESCRIPTION
    默认输出到 E:\开发\雨中冒险2mod\出包文件夹，每次出包前会先删掉该目录里上一次的 *.zip。
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
$iconPng  = Join-Path $thunder 'icons\looking-glass-icon-static.png'

# ---------- 读版本 / 程序集名 ----------
$csprojText = Get-Content $proj -Raw -Encoding UTF8
$version = [regex]::Match($csprojText, '<MinVerVersionOverride[^>]*>([^<]+)</MinVerVersionOverride>').Groups[1].Value
if (-not $version) { throw '没能从 csproj 读到 MinVerVersionOverride' }
$asmName = [regex]::Match($csprojText, '<AssemblyName>([^<]+)</AssemblyName>').Groups[1].Value
if (-not $asmName) { $asmName = 'PanelDisplay21' }

Write-Host "版本: $version   程序集: $asmName" -ForegroundColor Cyan

# ---------- 构建 ----------
if (-not $SkipBuild) {
    Write-Host 'dotnet build -c Debug ...' -ForegroundColor Cyan
    dotnet build $proj -c Debug --nologo
    if ($LASTEXITCODE -ne 0) { throw "dotnet build 失败，退出码 $LASTEXITCODE" }
}

$dll = Join-Path $repoRoot "LookingGlass\bin\Debug\netstandard2.1\$asmName.dll"
if (-not (Test-Path $dll)) { throw "找不到产物: $dll" }

# ---------- 找 RiskOfOptions ----------
$roo = Get-ChildItem "$env:APPDATA\r2modmanPlus-local\RiskOfRain2\profiles" -Directory -ErrorAction SilentlyContinue |
    ForEach-Object { Join-Path $_.FullName 'BepInEx\plugins\Rune580-Risk_Of_Options\RiskOfOptions\RiskOfOptions.dll' } |
    Where-Object { Test-Path $_ } |
    ForEach-Object { Get-Item $_ } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if (-not $roo) { throw '没找到 RiskOfOptions.dll（r2modman profile 里）' }
Write-Host "RiskOfOptions: $($roo.FullName) ($($roo.Length) 字节)" -ForegroundColor Cyan

# ---------- 输出目录 ----------
$OutDir = [System.IO.Path]::GetFullPath($OutDir)
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

# 每次出包先删掉上一次的包
$old = Get-ChildItem $OutDir -File -Filter '*.zip' -ErrorAction SilentlyContinue
foreach ($f in $old) {
    Write-Host "删除旧包: $($f.Name)" -ForegroundColor DarkYellow
    Remove-Item $f.FullName -Force
}

# ---------- 工具函数 ----------
function New-Staging {
    $s = Join-Path $env:TEMP ('PanelDisplay21_pack_' + [guid]::NewGuid().ToString('N'))
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
  "name": "21的面板显示",
  "author": "21的大肥鱼",
  "version_number": "$version",
  "website_url": "",
  "description": "自用改版 LookingGlass：全中文面板，去掉本关击杀和连击，新增暴击伤害倍率（原生 200%），默认解除暴击率显示上限。",
  "dependencies": [
    "bbepis-BepInExPack-5.4.2113",
    "Rune580-Risk_Of_Options-2.8.3"
  ]
}
"@

$readme = @"
# 21的面板显示 $version

自用改版 LookingGlass：全中文面板，去掉本关击杀和连击，新增暴击伤害倍率（原生 200%），默认解除暴击率显示上限。

- 需要 BepInEx 5.4.21+（RoR2BepInExPack）
- 需要 RiskOfOptions 2.8.3+
- 不要和原版 LookingGlass 同时启用
"@

$installNote = @"
21的面板显示 $version — 手动安装说明

【安装前确认】
1. 你的游戏已经装了 BepInEx（装过其他 mod 一般都有）。
2. 没有装过原版 LookingGlass；如果装过，请先在 mod 管理器里停用它（两个一起开会冲突）。

【安装】
把压缩包里的 BepInEx 文件夹整个解压到游戏根目录
（Steam 里右键游戏 -> 管理 -> 浏览本地文件，能看到 Risk of Rain 2.exe 的那一层），
覆盖提示选「是」。

解压后应该是：
  BepInEx\plugins\PanelDisplay21\PanelDisplay21.dll
  BepInEx\plugins\RiskOfOptions\RiskOfOptions.dll

【注意】
- 如果你已经装过 RiskOfOptions，就跳过 BepInEx\plugins\RiskOfOptions 这个文件夹，别覆盖，避免版本冲突。
- 进游戏后，设置里的 Risk of Options 里能看到「21的面板显示」，就说明加载成功了。
- 如果面板不显示：看 BepInEx\LogOutput.log 里有没有 PanelDisplay21 的报错。
"@

# ---------- 包 1：r2modman 导入包 ----------
$stage1 = New-Staging
try {
    Write-TextFile $stage1 'manifest.json' $manifest
    Write-TextFile $stage1 'README.md' $readme
    if (Test-Path $iconPng) { Copy-Into $iconPng $stage1 'icon.png' }
    Copy-Into $dll $stage1 "plugins\$asmName\$asmName.dll"
    if (Test-Path $iconPng) { Copy-Into $iconPng $stage1 "plugins\$asmName\icons\looking-glass-icon-static.png" }
    $zip1 = Join-Path $OutDir "21的面板显示-$version-r2modman导入包.zip"
    New-ZipFromStage $stage1 $zip1
}
finally { Remove-Item $stage1 -Recurse -Force -ErrorAction SilentlyContinue }

# ---------- 包 2：手动安装（内置 RiskOfOptions） ----------
$stage2 = New-Staging
try {
    Copy-Into $dll $stage2 "BepInEx\plugins\$asmName\$asmName.dll"
    if (Test-Path $iconPng) { Copy-Into $iconPng $stage2 "BepInEx\plugins\$asmName\icons\looking-glass-icon-static.png" }
    Copy-Into $roo.FullName $stage2 'BepInEx\plugins\RiskOfOptions\RiskOfOptions.dll'
    Write-TextFile $stage2 '安装说明.txt' $installNote
    $zip2 = Join-Path $OutDir "21的面板显示-$version-手动安装(含RiskOfOptions).zip"
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
Write-Host '插件 dll:' -ForegroundColor Green
$dllHash = (Get-FileHash $dll -Algorithm SHA256).Hash
"  {0}  {1} 字节  SHA256 {2}" -f $dll, (Get-Item $dll).Length, $dllHash
