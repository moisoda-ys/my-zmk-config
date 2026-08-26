# Dongle + Q10 Split Configuration

This configuration allows the SOFLE DONGLE to act as a central device and connect to the ZitaoTech Q10 keyboard as a split peripheral.

## ⚠️ Important: Local Compilation Required

**GitHub Actions CI cannot build this project** because `sofle_dongle` and `zitaotech_q10` are custom board definitions not in ZMK's official board registry. You **must compile locally** using the commands below.

## Setup - Local Compilation

### Building for DONGLE (Central)
The dongle is already configured as a central in the default configuration.

```bash
west build -b sofle_dongle -d build/sofle_dongle -- -DSHIELD=sofle_dongle -DKEYMAP_FILE=sofle_dongle.keymap
```

### Building for Q10 (Peripheral)
To build Q10 in peripheral mode to connect with the DONGLE central:

```bash
west build -b zitaotech_q10_peripheral -d build/q10_peripheral -- -DKEYMAP_FILE=zitaotech_q10.keymap
```

Or using the new defconfig:
```bash
west build -b zitaotech_q10_peripheral -d build/q10_peripheral -c
```

## Configuration Files Created

### Q10 Peripheral Files
- `boards/shields/zitaotech_q10/zitaotech_q10_peripheral_defconfig` - Complete configuration for Q10 as a split peripheral
- `config/zitaotech_q10_peripheral.conf` - Q10 peripheral mode configuration options

### Modified Files
- `boards/shields/zitaotech_q10/Kconfig.zitaotech_q10` - Added BOARD_ZITAOTECH_Q10_PERIPHERAL configuration option
- `boards/shields/zitaotech_q10/Kconfig.defconfig` - Added split peripheral defaults for Q10 in peripheral mode

## Key Configuration Changes for Q10 Peripheral

- `CONFIG_ZMK_SPLIT=y` - Enable split keyboard support
- `CONFIG_ZMK_SPLIT_ROLE_PERIPHERAL=y` - Set Q10 as a peripheral device
- `CONFIG_ZMK_SPLIT_PERIPHERAL_HID_INDICATORS=y` - Enable HID indicator support

## Pairing

1. Flash the DONGLE with the central configuration
2. Flash the Q10 with the peripheral configuration
3. Power on both devices
4. The Q10 peripheral should automatically discover and connect to the DONGLE central via Bluetooth

## Features Maintained

Both devices maintain their original features:
- Q10: Trackpad (A320), keyboard backlight, RGB underglow
- DONGLE: Trackball/trackpad support, backlight, mouse support

## Troubleshooting

If the Q10 doesn't connect to the DONGLE:
1. Ensure both devices have split support enabled
2. Check that Q10 is in peripheral mode and DONGLE is in central mode
3. Reset both devices and try pairing again
4. Check the ZMK logs for connection errors

## References
- ZMK Split Configuration: https://zmk.dev/docs/features/split-keyboards
- SOFLE DONGLE: Original central configuration
- ZitaoTech Q10: Original standalone keyboard configuration
