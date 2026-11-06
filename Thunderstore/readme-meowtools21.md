# 21的喵喵工具 · MeowTools21

一站式 QoL 整合包：装上这一个，中文属性面板、宝箱高亮、小地图全部到位，依赖会自动装好。

## 包含内容

| 功能 | 来源 |
| --- | --- |
| 全中文属性条 / 物品数值 / buff 悬停说明 | 本包自带（基于 LookingGlass 修改） |
| 宝箱、神龛、商店终端高亮，空箱隐藏 | QoLChests 1.3.6（作为依赖自动安装） |
| 小地图（M 键开合） | MiniMapMod 4.0.0（作为依赖自动安装） |

面板内容：右侧属性条（伤害、攻速、暴击率与暴击伤害、生命回复、护甲、移速、跳跃次数、DPS 等）、物品逐层数值、buff 剩余时间与说明、背包与命令窗排序、DPS 统计。所有标签已汉化。

## 安装

**推荐**：在 r2modman 或 Thunderstore Mod Manager 里点「Install with Mod Manager」，manifest 里声明的依赖会全部自动装齐。

**手动安装**：先自行装好 BepInExPack 5.4.21+、RiskOfOptions 2.8.6+、HookGenPatcher 1.2.9+、QoLChests 1.3.6、MiniMapMod 4.0.0，再把包内 `plugins/PanelDisplay21/` 整个目录放到 `BepInEx/plugins/` 下。

## 注意

- **不要与原版 LookingGlass 同时启用**，两者功能重叠。
- **不要与单独安装的 QoLChests / MiniMapMod 同时启用**，本包已经带上了。
- 插件 GUID 仍是 `MeowTools21.PanelDisplay21`，从旧版升级配置不会丢。
- QoLChests 和 MiniMapMod 需要 HookGenPatcher 生成 MMHOOK，已在依赖里声明。

## 源码与许可

面板部分基于 [Wet-Boys/LookingGlass](https://github.com/Wet-Boys/LookingGlass)（LGPL-3.0），是一个**中文汉化 + 魔改版**：功能主体来自原作者，中文文本与界面调整由我完成。它不是原版 LookingGlass，也不是官方维护的分支。随包附带 LICENSE 全文。

修改部分的完整源码（含全部改动与提交记录）：https://github.com/ryougi21-9527/PanelDisplay21

宝箱高亮与小地图直接引用原作者发布的包，本包没有重分发他们的文件。
