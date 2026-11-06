# PanelDisplay21 · 全中文属性面板

把游戏里原本藏起来的数值摆到屏幕上，并且全部做成中文。

## 功能

- 右侧属性条：伤害、攻速、暴击率、暴击伤害、生命回复、护甲、移速、跳跃次数、DPS，随装备实时刷新
- 物品数值：鼠标悬停物品图标，看它现在一共给了多少
- buff：图标上显示剩余时间和层数，悬停看名称和说明
- 背包、命令窗、粉碎机的物品自动排序；拾取通知可关、可调时长

界面已经全中文，不用另装汉化。

## 注意

- 别和原版 LookingGlass 同时开，功能重叠

## 来源

原作者是 [Wet-Boys/LookingGlass](https://github.com/Wet-Boys/LookingGlass)（LGPL-3.0）。功能主体是他们的，我做的是中文汉化和界面上的改动，不是原版，也不是官方分支。LICENSE 全文随包附带。

https://github.com/ryougi21-9527/PanelDisplay21

## 构建

需要 .NET SDK 和游戏程序集引用（`lib-stripped/` 里放了编译所需的 stripped 依赖）。

```
dotnet build -c Debug
```

产物在 `LookingGlass/bin/Debug/netstandard2.1/PanelDisplay21.dll`，版本号由 `LookingGlass/LookingGlass.csproj` 里的 `MinVerVersionOverride` 固定。
