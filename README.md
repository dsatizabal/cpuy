# CPUy Bring Up Guide

This guide walks through the process of bringing up the CPUy project on the Caravel SoC development board.

## Setup Instructions

### 1. Environment Setup

Navigate to caravel directory and create a Python virtual environment:

```bash
cd caravel
python3 -m venv --prompt caravel_board .venv
echo '*' >> .venv/.gitignore
source .venv/bin/activate
```

Verify Python version (3.10+ recommended):
```bash
python3 --version
```

### 2. Install Dependencies

Install the required Python packages:

```bash
pip3 install pyftdi
```

### 3. Configure USB Device Access

To allow non-root access to the FTDI USB-serial device:

1. **Identify the device**: Run `lsusb` to find your FTDI device (typically shows as `0403:6014`)

2. **Create udev rule**: As root, create `/etc/udev/rules.d/99-ftdi-everyone.rules` with the following content:

```bash
# FTDI USB access rule for Caravel board
# Allows all users full access to FTDI USB interface without root privileges
# References:
# - https://groups.google.com/g/weewx-user/c/kol0udZNuyc/m/1WhtZF0kBAAJ
# - https://github.com/algofoogle/journal/blob/master/0206-2024-06-26.md

SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6014", MODE="666"
```

3. **Apply changes**: 
```bash
sudo service udev restart
```

4. **Reconnect device**: Unplug and replug the Caravel board. If using a VM, ensure USB passthrough is configured.

### 4. Verification

Test the connection using the HK Debug utility:

```bash
cd firmware/gf180/util
python3 caravel_hkdebug.py
```

**Expected output:**
```
Success: Found one matching FTDI device at ftdi://ftdi:232h:1:4/1
Caravel data:
 mfg = 0456
 product = 20
 project ID = 1801dc4f
 project ID = f23b8018
```

If you see this output, your board connection is working correctly.

## GPIO Configuration

![GPIO Configuration](docs/gpio.jpeg)

*GPIO pin assignments and configuration details - refer to the image above for the current pin mapping.*

## Related Resources

- **Caravel Board Repository**: https://github.com/efabless/caravel_board
- **Multi-Project Repository**: https://github.com/algofoogle/algofoogle-multi-caravel

*This documentation is actively being updated. Please check back for updates on the automated configuration script.*