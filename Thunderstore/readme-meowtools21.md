# 21的喵喵工具 · MeowTools21

一站式 QoL 整合包：装上这一个，中文属性面板、宝箱高亮、小地图全部到位，依赖会自动装好。

**整合包本身不含任何 mod 文件**，只是把下面这些包绑在一起；其中面板本体（PanelDisplay21）是独立发版的，它更新后你在 mod manager 里点一次更新即可，不需要等整合包发新版。

## 包含内容

| 功能 | 来源 |
| --- | --- |
| 全中文属性面板、物品数值、buff 悬停说明、背包排序、DPS 统计 | [PanelDisplay21](https://thunderstore.io/c/riskofrain2/p/MeowTools21/PanelDisplay21/)（独立发版） |
| 宝箱、神龛、商店终端高亮，空箱隐藏 | [QoLChests](https://thunderstore.io/c/riskofrain2/p/Faustvii/QoLChests/) |
| 小地图（M 键开合） | [MiniMapMod](https://thunderstore.io/c/riskofrain2/p/DekuDesu/MiniMapMod/) |

面板部分基于 [Wet-Boys/LookingGlass](https://github.com/Wet-Boys/LookingGlass)（LGPL-3.0）做的中文汉化 + 魔改版，源码在 https://github.com/ryougi21-9527/PanelDisplay21 。

## 安装

**推荐**：在 r2modman 或 Thunderstore Mod Manager 里点「Install with Mod Manager」，下面这些依赖会全部自动装齐。

**手动安装**：自行装好 BepInExPack 5.4.21+、RiskOfOptions 2.8.6+、HookGenPatcher 1.2.9+、PanelDisplay21、QoLChests 1.3.6、MiniMapMod 4.0.0。本包解压后只有说明与清单，没有可放的文件。

## 注意

- **不要与原版 LookingGlass 同时启用**，功能重叠。
- **不要与单独安装的 QoLChests / MiniMapMod 重复启用**，本整合包已经把它们装上了。
- 面板插件 GUID 仍是 `MeowTools21.PanelDisplay21`，从旧整合包（0.2.1）升级过来配置不会丢。
- QoLChests 和 MiniMapMod 需要 HookGenPatcher 生成 MMHOOK，已在依赖里声明。
- 从旧整合包升级时，之前打进 `BepInEx/plugins/PanelDisplay21/` 的 dll 会被 mod manager 替换成独立发的面板包，不要手动再放一份。
