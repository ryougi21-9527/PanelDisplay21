# PanelDisplay21 · 21的喵喵工具（面板部分）

一个《雨中冒险 2》的界面增强 mod，本仓库是它的完整源码。

**先说清楚来源**：这个 mod 不是从零写的，它基于开源项目 [Wet-Boys/LookingGlass](https://github.com/Wet-Boys/LookingGlass)（LGPL-3.0）。我在它的基础上做了**中文本地化**，并按自己的使用习惯做了**一定程度的魔改**。功能主体、代码结构、hook 思路都来自原作者，功劳是他们的；中文文本、界面调整和一部分行为改动是我加的。

## 我改了什么

- **界面全中文**：右侧属性条、物品数值说明、buff 悬停提示、设置菜单、各类提示文本
- **属性条调整**：去掉斩杀数 / 连击数，在暴击率下面加「暴击伤害」（显示倍率，原生 200%）
- **buff 说明汉化**：逐步补齐中文名称与描述（仍在进行中）
- **配置默认值**：暴击率不再默认封顶 100%
- **打包与分发**：加了打包脚本和 Thunderstore 配置，能直接出 r2modman 导入包和手动安装包

## 没变的部分

- 程序集名仍是 `PanelDisplay21`；插件标识从 0.2.4 起改为 `MeowTools21.PanelDisplay21`（旧名字里带了本机用户名，公开分发不合适），改名后旧配置文件需手动改名才能沿用
- 物品数值、排序、DPS 统计、传送门追踪等模块的逻辑保持原样

## 构建

需要 .NET SDK 和游戏程序集引用（`lib-stripped/` 里放了编译所需的 stripped 依赖）。

```
dotnet build -c Debug
```

产物在 `LookingGlass/bin/Debug/netstandard2.1/PanelDisplay21.dll`。

版本号由 `LookingGlass/LookingGlass.csproj` 里的 `MinVerVersionOverride` 固定。

## 打包

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools\package-meowtools21.ps1
```

一次产出两个包到 `..\出包文件夹`：r2modman 导入包、手动安装包（内嵌 RiskOfOptions）。

## 许可

本仓库整体以 **LGPL-3.0** 发布，LICENSE 全文见仓库根目录。这是上游 LookingGlass 的许可证，衍生作品必须沿用。

## 相关

- 上游项目：[Wet-Boys/LookingGlass](https://github.com/Wet-Boys/LookingGlass)
- 整合包（Thunderstore）：`MeowTools21` —— 这个包除了本面板，还通过依赖引用 [QoLChests](https://thunderstore.io/c/riskofrain2/p/Faustvii/QoLChests/)（宝箱高亮）和 [MiniMapMod](https://thunderstore.io/c/riskofrain2/p/DekuDesu/MiniMapMod/)（小地图），那两个是作者原版，我没有改动也没有重分发
