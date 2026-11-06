# PanelDisplay21 · 全中文属性面板

把 RoR2 原本藏起来的一堆数值摆到屏幕上，并且全部翻成中文。基于 [Wet-Boys/LookingGlass](https://github.com/Wet-Boys/LookingGlass)（LGPL-3.0）的汉化 + 魔改版。

## 功能

**右侧属性条**：伤害、攻击速度、暴击率、暴击伤害（倍率百分比）、生命回复、护甲、移动速度、跳跃次数、DPS 等，随装备实时刷新。Tab 面板与主面板字段一致。

**物品逐层数值**：谁拿了几个、每个提供多少，鼠标悬停物品图标即可看到逐层累加的数值。

**buff 相关**：图标上显示剩余时间与层数，鼠标悬停弹出名称与说明。

**背包整理**：背包、命令窗、粉碎机的物品自动排序；DPS 统计；传送门追踪；未解锁物品提示等若干 QoL 小功能。

全部界面文本已汉化，不需要额外的汉化补丁。

## 安装

**推荐**：在 r2modman / Thunderstore Mod Manager 里点「Install with Mod Manager」，依赖会自动装好。

**手动安装**：先装 BepInExPack 5.4.21+ 与 RiskOfOptions 2.8.6+，再把包内 `plugins/PanelDisplay21/` 整个目录放进 `BepInEx/plugins/`。

## 注意

- **不要与原版 LookingGlass 同时启用**，两者功能重叠。
- 插件 GUID 仍是 `MeowTools21.PanelDisplay21`，从旧版本升级配置不会丢。
- 想要「面板 + 宝箱高亮 + 小地图」一步到位，装整合包 [MeowTools21](https://thunderstore.io/c/riskofrain2/p/MeowTools21/MeowTools21/)，不要同时装本包。

## 源码与许可

面板基于 [Wet-Boys/LookingGlass](https://github.com/Wet-Boys/LookingGlass)（LGPL-3.0），是一个**中文汉化 + 魔改版**：功能主体来自原作者，中文文本与界面调整由我完成。它不是原版 LookingGlass，也不是官方维护的分支。随包附带 LICENSE 全文。

修改部分的完整源码（含全部改动与提交记录）：https://github.com/ryougi21-9527/PanelDisplay21
