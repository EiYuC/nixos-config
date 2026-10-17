# NixOS configuration

使用 nixos-unstable 和独立的 Home Manager，保留 KDE Plasma，并提供 i3 X11 会话。
Flake 入口仍是 `nixosConfigurations.nixos` 和 `homeConfigurations."cao@nixos"`。

## 目录

```text
flake.nix / flake.lock
hosts/nixos/
  default.nix                 # 当前主机、引导器、系统版本
  hardware-configuration.nix  # 原硬件配置，内容保持不变
modules/
  system.nix                  # Nix、网络、语言、字体、用户、SSH
  desktop.nix                 # SDDM + Breeze、KDE Plasma
  input-method.nix            # Fcitx5、GTK/Qt 插件、Rime 引擎
  i3.nix                      # i3 登录会话、锁屏、桌面门户
  power.nix                   # 合盖时按外接电源/电池决定是否休眠
home/
  default.nix                 # 导入全部用户模块
  fcitx5/                     # 输入法列表、KDE 集成
    rime-data-flypy/           # 自定义小鹤音形源文件
  i3/                         # config、keybindings、i3blocks.conf、scripts/
  programs/                   # 浏览器、常用软件、Git、媒体、VS Code、XDG
  polybar/                    # Catppuccin Mocha 状态栏、模块与来源说明
  rofi/                       # 应用启动器和菜单主题
  shell/                      # Fish、Starship、Kitty
wallpaper.jpg                 # 可选：自行放置的 i3 壁纸
```

`home/default.nix`、`home/programs/default.nix` 和 `home/shell/default.nix`
均通过显式 `imports` 组合子模块。添加模块时同步更新相应的导入列表。
当前只配置这台真实主机；新主机应创建自己的 `hosts/<name>`、硬件配置与 flake 入口。

## 应用

新增文件需要先被 Git 识别；无需提交。保存工作后执行：

```sh
cd ~/nixos-config
git add -N home hosts modules
sudo nixos-rebuild boot --flake .#nixos
nix build '.#homeConfigurations."cao@nixos".activationPackage' -o result-home
HOME_MANAGER_BACKUP_EXT=nixos-migration ./result-home/activate
```

如果同名的 `.nixos-migration` 备份已存在，先将该备份另行保存，再重新激活。
上述命令分别准备下次启动的系统和当前用户配置。重启后，在 SDDM 的会话菜单
选择 **i3** 或 **Plasma**；默认仍为 Plasma Wayland。SDDM 登录界面使用 X11。
首次进入 i3 前务必完成 Home Manager 激活，否则不会加载本仓库的快捷键和外观。
后续也可用 `home-manager switch --flake ~/nixos-config#cao@nixos -b nixos-migration`。

如果 i3 提示缺少配置并启动首次配置向导，说明系统会话已安装，但用户配置尚未激活。
确认 `~/.config/i3/config` 是 Home Manager 创建的符号链接。完成激活后执行
`i3-msg restart` 加载配置；如果仍处于旧会话，注销并重新选择 i3，以启动完整的自启动程序。

原来的 `/etc/nixos` 保留；重建时指定本仓库路径。
`system.stateVersion` 和 `home.stateVersion` 保持为 `26.05`。

## i3 快捷键

`Super` 是 Win 键。

| 快捷键                  | 操作                             |
| ----------------------- | -------------------------------- |
| Super + Enter           | Kitty 终端                       |
| Super + D               | Rofi 应用启动器                  |
| Super + /               | 快捷键提示                       |
| Super + H/J/K/L         | 向左/下/上/右聚焦                |
| Super + Shift + H/J/K/L | 移动窗口                         |
| Super + 1…0            | 工作区 1…103                    |
| Super + Shift + 1…0    | 移动窗口到工作区                 |
| Super + F               | 全屏                             |
| Super + Shift + Space   | 浮动窗口                         |
| Super + R               | 调整大小，Enter/Esc 退出         |
| Super + Shift + Q       | 关闭窗口                         |
| Super + Shift + C / R   | 重载配置 / 重启 i3               |
| Super + Ctrl + L        | 锁屏                             |
| Super + Shift + E       | 锁屏、注销、挂起、重启、关机菜单 |

注销、重启、关机会二次确认。注销后回到 SDDM 选择桌面。
i3 启动 Fcitx5、通知、网络托盘、权限认证代理和自动锁屏。
状态栏使用 Polybar + Catppuccin Mocha 深色配色，提供工作区、日期时间、网络、
CPU 使用率、已用内存、电池、音量、系统托盘和电源菜单。
电池区分充电、充满、放电与低电量（20%），CPU 显示实际使用率。
左键点击音量切换静音，滚轮调整音量，右键打开音量控制；点击日期切换详细时间。
左侧 NixOS 图标打开 Rofi，右键显示快捷键提示；最右侧电源图标打开会话菜单。
样式与模块集中在 `home/polybar/config.ini`，参考来源和许可证在 `home/polybar/SOURCES.md`。
图标字体由 Home Manager 安装。Polybar 由用户服务管理，只从 i3 启动；
修改配置并应用 Home Manager 后，可执行 `systemctl --user restart polybar`。
旧的 `home/i3/i3blocks.conf` 和脚本保留，但当前不再使用 i3bar/i3blocks。
在仓库根目录放入 `wallpaper.jpg` 并执行 `git add -N wallpaper.jpg`，
重新应用 Home Manager 后生效；未放置时使用深色背景。

## i3 合盖和屏幕电源

接通外部电源时合盖关闭笔记本内屏，系统继续运行；电池供电时合盖进入
挂起到内存（suspend）。打开盖子时恢复内屏。外接显示器保持原有状态。
合盖时拔掉电源也会触发休眠；判断的是是否接通外部电源，电池充满时同样适用。

i3 禁用 X11 屏保、闲置熄屏和 DPMS 自动节能，系统不因闲置自动休眠。
手动锁屏、手动休眠及休眠前锁屏仍然可用。
`acpid` 统一执行合盖供电策略，避免外接显示器时 logind 的 docked 策略覆盖电池行为。
用户服务 `i3-lid-display` 每秒检查合盖状态，仅在状态变化时关闭/恢复内屏；
从休眠唤醒后也会重新检查，无需依赖可能在休眠期间丢失的开盖事件。
更改此策略需同时应用系统和 Home Manager 配置；仅应用 Home Manager 不会改变休眠行为。

## 小鹤音形

目前仓库尚未包含你的自定义词库，因此默认保留拼音，同时安装 Fcitx5-Rime。
将你已有的小鹤音形源文件放进 `home/fcitx5/rime-data-flypy/`，包括：

- `*.schema.yaml`、`*.dict.yaml` 和方案依赖的 Lua 等文件。
- `default.custom.yaml`，其 `schema_list` 使用你实际的 `schema_id`。

不要放入 `build/`、用户词典、同步数据或 `installation.yaml`。
加入 Git、重新应用 Home Manager，然后在 Fcitx5 的 Rime 菜单执行“重新部署”。
检测到 schema 后，输入法列表会默认选择 Rime，并保留拼音备选。
源文件逐个链接到 `~/.local/share/fcitx5/rime`，编译缓存和用户词典仍可正常写入。
KDE Wayland 由 KWin 启动 Fcitx5；i3 使用 X11 输入法环境变量。
Kitty 的 X11 输入法需要 `GLFW_IM_MODULE=ibus`，已在用户环境与终端快捷键中配置。
输入法启动前打开的旧应用可能需要重新打开，再使用 Ctrl+Space 切换中文。

## 验证和更新

```sh
nix flake check --no-build
nix build .#nixosConfigurations.nixos.config.system.build.toplevel --no-link
nix build '.#homeConfigurations."cao@nixos".activationPackage' --no-link
nix flake update
```
