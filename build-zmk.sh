#!/bin/bash
# ZMK 编译脚本

set -e

source ~/zmk-env/bin/activate

if [ "$1" = "dongle" ]; then
    echo "📦 编译 Dongle (中央设备)..."
    west build -b sofle_dongle -d build/sofle_dongle \
        -- -DSHIELD=st7789_display \
        -DCONFIG_ZMK_SPLIT=y \
        -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=y
    echo "✅ 完成！输出: build/sofle_dongle/zephyr/zmk.uf2"

elif [ "$1" = "q10" ]; then
    echo "📦 编译 Q10 (外设设备)..."
    west build -b zitaotech_q10 -d build/q10 \
        -- -DCONFIG_ZMK_SPLIT=y \
        -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n
    echo "✅ 完成！输出: build/q10/zephyr/zmk.uf2"

elif [ "$1" = "both" ]; then
    echo "📦 编译两个固件..."
    $0 dongle
    $0 q10
    echo "✅ 全部完成！"
else
    echo "用法: $0 [dongle|q10|both]"
    echo ""
    echo "例子："
    echo "  $0 dongle    # 编译 Dongle"
    echo "  $0 q10       # 编译 Q10"
    echo "  $0 both      # 编译两个"
fi
