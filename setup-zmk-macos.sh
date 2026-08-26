#!/bin/bash
# ZMK macOS 自动化安装脚本

set -e  # 任何错误立即停止

echo "========================================="
echo "ZMK macOS 编译环境自动安装"
echo "========================================="

# 步骤 1: 检查 Homebrew
echo -e "\n[步骤 1/6] 检查 Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew 未安装"
    echo "请先手动安装 Homebrew："
    echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
else
    echo "✅ Homebrew 已安装"
    brew --version
fi

# 步骤 2: 安装依赖
echo -e "\n[步骤 2/6] 安装编译依赖..."
brew install cmake ninja gperf python3 ccache wget gcc-arm-embedded libmagic
echo "✅ 依赖安装完成"

# 步骤 3: 创建虚拟环境
echo -e "\n[步骤 3/6] 创建 Python 虚拟环境..."
python3 -m venv ~/zmk-env
echo "✅ 虚拟环境创建完成: ~/zmk-env"

# 步骤 4: 激活虚拟环境并安装 West
echo -e "\n[步骤 4/6] 安装 West..."
source ~/zmk-env/bin/activate
pip install --upgrade pip
pip install west
echo "✅ West 安装完成"

# 步骤 5: 初始化 Zephyr 工作区
echo -e "\n[步骤 5/6] 初始化 Zephyr 工作区..."
mkdir -p ~/zephyr-workspace
cd ~/zephyr-workspace

if [ -d "zmk" ]; then
    echo "⚠️  zmk 目录已存在，跳过 west init"
else
    west init -m https://github.com/zmkfirmware/zmk.git --mr main
fi

echo "✅ 初始化完成"

# 步骤 6: 更新依赖
echo -e "\n[步骤 6/6] 更新 Zephyr 依赖（这可能需要几分钟）..."
west update
west zephyr-export
echo "✅ 依赖更新完成"

echo -e "\n========================================="
echo "✅ 安装完成！"
echo "========================================="
echo ""
echo "下一步：编译固件"
echo ""
echo "编译 Dongle (中央)："
echo "  source ~/zmk-env/bin/activate"
echo "  cd ~/my-zmk-config"
echo "  west build -b sofle_dongle -d build/sofle_dongle -- -DSHIELD=st7789_display -DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=y"
echo ""
echo "编译 Q10 (外设)："
echo "  west build -b zitaotech_q10 -d build/q10 -- -DCONFIG_ZMK_SPLIT=y -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n"
echo ""
