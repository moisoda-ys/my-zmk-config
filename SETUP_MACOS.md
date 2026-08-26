# macOS 本地 ZMK 编译环境配置

这个指南帮你在 macOS 上设置 ZMK 编译环境来编译 Dongle + Q10 固件。

## 前置条件

### 1. 安装 Xcode Command Line Tools
```bash
xcode-select --install
```

### 2. 安装 Homebrew（如未安装）
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. 安装必要工具

```bash
# 使用 Homebrew 安装依赖
brew install cmake ninja gperf python3 ccache wget libmagic

# 安装 Python 虚拟环境
python3 -m venv ~/zmk-env
source ~/zmk-env/bin/activate

# 升级 pip 和安装 West
pip install --upgrade pip
pip install west
```

### 4. 安装 Nordic NRF5 SDK（核心步骤）

```bash
# 创建工作目录
mkdir -p ~/zephyr-workspace
cd ~/zephyr-workspace

# 初始化 West（下载 Zephyr、ZMK 及所有依赖）
west init -m https://github.com/zmkfirmware/zmk.git --mr main

# 更新依赖
west update

# 导出 Zephyr CMake 包
west zephyr-export
```

### 5. 安装 Nordic 工具链

**选项 A：使用预构建的 GNU Arm 工具链（推荐）**
```bash
source ~/zmk-env/bin/activate
cd ~/zephyr-workspace

# 下载并配置工具链
wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-mac.tar.bz2
tar xjf gcc-arm-none-eabi-10.3-2021.10-mac.tar.bz2

# 添加到 PATH
echo 'export PATH=~/zephyr-workspace/gcc-arm-none-eabi-10.3-2021.10/bin:$PATH' >> ~/.zshrc
# 或者如果使用 bash：
echo 'export PATH=~/zephyr-workspace/gcc-arm-none-eabi-10.3-2021.10/bin:$PATH' >> ~/.bash_profile
```

重新打开终端或运行：
```bash
source ~/.zshrc  # 或 ~/.bash_profile
```

**选项 B：使用 Homebrew（更简单）**
```bash
brew install gcc-arm-embedded
```

## 编译固件

### 准备工作
```bash
# 激活虚拟环境
source ~/zmk-env/bin/activate

# 进入项目目录
cd ~/my-zmk-config  # 你的项目路径
```

### 编译 Dongle（中央设备）
```bash
west build -b sofle_dongle -d build/sofle_dongle \
  -- -DSHIELD=st7789_display \
  -DCONFIG_ZMK_SPLIT=y \
  -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=y
```

输出文件：`build/sofle_dongle/zephyr/zmk.uf2`

### 编译 Q10（外设设备）
```bash
west build -b zitaotech_q10 -d build/q10 \
  -- -DCONFIG_ZMK_SPLIT=y \
  -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n
```

输出文件：`build/q10/zephyr/zmk.uf2`

## 刷入固件

### 1. 进入 Bootloader 模式

**Dongle:**
- 按住 RESET 按钮直到 LED 闪烁
- 或双击 RESET 按钮

**Q10:**
- 同样操作

### 2. 刷入 UF2 文件

当设备进入 Bootloader 模式时，会显示为 USB 驱动器。

```bash
# Dongle
cp build/sofle_dongle/zephyr/zmk.uf2 /Volumes/DONGLE_BOOT/

# Q10
cp build/q10/zephyr/zmk.uf2 /Volumes/Q10_BOOT/
```

或直接在 Finder 中拖拽 `.uf2` 文件到 USB 驱动器。

## 故障排除

### 问题：Command not found: west
**解决：** 确保虚拟环境已激活
```bash
source ~/zmk-env/bin/activate
```

### 问题：arm-none-eabi-gcc not found
**解决：** 检查工具链路径
```bash
# 如果使用 Homebrew
brew list gcc-arm-embedded

# 或验证下载的工具链
ls ~/zephyr-workspace/gcc-arm-none-eabi-10.3-2021.10/bin/
```

### 问题：找不到 sofle_dongle 或 zitaotech_q10 boards
**解决：** 这些是自定义 board，应该在项目的 `boards/shields/` 目录中
```bash
ls boards/shields/sofle_dongle/
ls boards/shields/zitaotech_q10/
```

### 问题：编译失败 - Missing ZMK Compat
**原因：** ZMK 版本不兼容
**解决：** 检查 `west.yml` 版本和 Zephyr 版本

## 便捷别名（可选）

在 `~/.zshrc` 或 `~/.bash_profile` 中添加：

```bash
# ZMK 别名
alias zmk-env='source ~/zmk-env/bin/activate'
alias zmk-dongle='west build -b sofle_dongle -d build/sofle_dongle -- -DSHIELD=st7789_display -DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=y'
alias zmk-q10='west build -b zitaotech_q10 -d build/q10 -- -DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n'
```

然后使用：
```bash
zmk-env    # 激活环境
zmk-dongle # 编译 Dongle
zmk-q10    # 编译 Q10
```

## 参考资源

- [ZMK 官方文档](https://zmk.dev)
- [ZMK GitHub](https://github.com/zmkfirmware/zmk)
- [Zephyr RTOS](https://www.zephyrproject.org/)
