# rime-toggle.nvim

[English](README_en.md) | 简体中文

通过 D-Bus 在 Neovim 中自动切换 fcitx5 Rime 输入法的 ASCII 模式。

## 功能特性

- 离开插入模式时自动切换 Rime 到 ASCII 模式
- 进入插入模式时恢复之前的输入状态
- 通过 D-Bus 与 fcitx5 通信
- 开箱即用，无需配置

## 系统要求

- 支持systemd(比如linux和bsd)
- 安装了 Rime 输入法的 fcitx5
- `busctl` 命令（通常来自 systemd 软件包）

## 安装

使用 [lazy.nvim](https://github.com/folke/lazy.nvim)：

```lua
{
  "rime-toggle.nvim",
  event = "InsertEnter",
  -- 以下是默认值
  -- enabled表示默认启用
  -- opts = {
  --   enabled = true,
  -- }
}
```

使用 Neovim 内置包管理器(neovim 0.12加入，需要使用nightly版本)：

```lua
vim.pack.add({
  { src = "https://github.com/Qiumix/rime-toggle.nvim") },
})

require('rime_dbus').setup({
  -- enabled = true,
})
```

## 命令

- RimeEnable: 启用
- RimeDisablea: 禁用
- RimeToggle: 切换

## 建议

在配置文件 `~/.config/fcitx5/conf/rime.conf` 里添加下面这个选项

```conf
# 禁用多窗口rime状态共享
InputState=No
```

## 工作原理

当离开插入模式时，插件会：

1. 通过 D-Bus 查询当前 Rime 输入状态
2. 在内部保存该状态
3. 如果当前是中文模式，则切换到 ASCII 模式

当再次进入插入模式时，插件会：

1. 查询当前状态
2. 如果与之前保存的状态不同，则恢复之前的状态

这样可以确保在 Neovim 中以 ASCII 模式浏览和操作，同时在编辑时保持你偏好的输入状态。
