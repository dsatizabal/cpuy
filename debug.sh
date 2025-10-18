#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# This script must be run as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}⚠️  This script must be run as root!${NC}"
    exit 1
fi

echo -e "\n${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║ Setting up Caravel Board environment ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}\n"

# Linux user must be part of the dialout group to access the FTDI USB-serial interface
CURRENT_USER=${SUDO_USER:-$USER}
if ! groups "$CURRENT_USER" | grep -q "\bdialout\b"; then
    echo -e "Adding user ${BLUE}$CURRENT_USER${NC} to dialout group..."
    adduser "$CURRENT_USER" dialout
    echo -e "User ${BLUE}$CURRENT_USER${NC} was added to dialout group"
fi

# Check if FTDI device is detected
VID_PID=$(lsusb | grep -i ftdi | grep -oE '[0-9a-f]{4}:[0-9a-f]{4}' | head -n1)

if [ -z "$VID_PID" ]; then
    echo -e "${RED}Error: No FTDI device detected.${NC}"
    echo -e "(Ensure the board is connected)\n"
    # exit 1
fi

VID=${VID_PID%:*}
PID=${VID_PID#*:}
echo -e "${GREEN}Detected FTDI device: $VID:$PID${NC}"

# Check if rule file already exists
# and create if not
RULE_FILE="/etc/udev/rules.d/99-ftdi-everyone.rules"

if [ ! -f "$RULE_FILE" ]; then

sudo tee "$RULE_FILE" > /dev/null <<EOF
# Per https://groups.google.com/g/weewx-user/c/kol0udZNuyc/m/1WhtZF0kBAAJ
# ...and https://github.com/algofoogle/journal/blob/master/0206-2024-06-26.md
# ...this ensures all users get full access to the FTDI USB interface on
# the caravel_board hardware, without having to be root:

SUBSYSTEM=="usb", ATTR{idVendor}=="$VID", ATTR{idProduct}=="$PID", MODE="666"
EOF

# Reload udev rules
service udev restart

echo -e "${BLUE}Please unplug and replug the board. Then press Enter${NC}"
read -r 

fi

cd caravel

# Create Python VENV if it doesn't exist
if [ ! -d ".venv" ]; then
    echo -e ${GREEN}"Creating Python virtual environment...${NC}"
    python3 -m venv --prompt caravel_board .venv
    echo '*' >> .venv/.gitignore
fi

# Activate VENV and install dependencies
source .venv/bin/activate
if ! pip3 show pyftdi >/dev/null 2>&1; then
    echo "Installing Python dependencies..."
    pip3 install pyftdi
fi

cd ..

#!/bin/bash

# RISC-V toolchain installation variables
TOOLCHAIN_DIR="/opt"
RISCVTOOLS="riscv64-unknown-elf-toolchain-10.2.0-2020.12.8-x86_64-linux-ubuntu14"
TOOLCHAIN_URL="https://static.dev.sifive.com/dev-tools/freedom-tools/v2020.12/$RISCVTOOLS.tar.gz"
SYMLINK_NAME="riscv-toolchain"

echo ""

# Check if toolchain is already installed and working
if [ ! -f "/opt/$SYMLINK_NAME/bin/riscv64-unknown-elf-gcc" ]; then
    echo "❌ RISC-V toolchain is NOT installed"
    echo "🔄 Installing RISC-V toolchain..."
    
    echo "🔧 Checking RISC-V toolchain installation..."
    
    # Check if downloaded tarball already exists
    if [ -f "/opt/$RISCVTOOLS.tar.gz" ]; then
        echo "📦 Found existing toolchain tarball, extracting..."
        cd "$TOOLCHAIN_DIR" || exit 1
        sudo tar xf "$RISCVTOOLS.tar.gz"
    else
        echo "📥 Downloading RISC-V toolchain..."
        cd "$TOOLCHAIN_DIR" || exit 1
        
        # Download with progress and error handling
        if ! sudo wget --progress=bar:force --no-check-certificate "$TOOLCHAIN_URL"; then
            echo "❌ Failed to download RISC-V toolchain"
            exit 1
        fi
        
        echo "📦 Extracting toolchain..."
        sudo tar xf "$RISCVTOOLS.tar.gz" || {
            echo "❌ Failed to extract toolchain"
            exit 1
        }
    fi
    
    # Remove tarball to save space
    if [ -f "/opt/$RISCVTOOLS.tar.gz" ]; then
        echo "🧹 Cleaning up downloaded tarball..."
        sudo rm -f "/opt/$RISCVTOOLS.tar.gz"
    fi
    
    # Create symlink if it doesn't exist
    if [ ! -L "/opt/$SYMLINK_NAME" ] && [ ! -d "/opt/$SYMLINK_NAME" ]; then
        echo "🔗 Creating symlink: $SYMLINK_NAME -> $RISCVTOOLS"
        sudo ln -sf "$RISCVTOOLS" "$SYMLINK_NAME"
    else
        echo "✅ Symlink already exists"
    fi
    
    # Add to PATH in current environment
    export PATH="/opt/$SYMLINK_NAME/bin:$PATH"
    
    echo "✅ RISC-V toolchain installation completed"
    
    # Test the installation
    echo "🧪 Testing toolchain installation..."
    if /opt/$SYMLINK_NAME/bin/riscv64-unknown-elf-gcc --version > /dev/null 2>&1; then
        echo "🎉 Toolchain test successful!"
        /opt/$SYMLINK_NAME/bin/riscv64-unknown-elf-gcc --version
    else
        echo "❌ Toolchain test failed"
        exit 1
    fi
fi

# Interactive menu for next actions
show_menu() {
 # Mostrar menú con marco y colores
echo -e "\n${BLUE}╔══════════╗${NC}"
echo -e "${BLUE}║   MENU   ║${NC}"
echo -e "${BLUE}╚══════════╝${NC}\n"
echo -e "${BLUE}1) Flash${NC}"
echo -e "${BLUE}2) New Firmware${NC}"
echo -e "${BLUE}q) Quit${NC}\n"

# Leer opción del usuario sin presionar Enter, solo aceptar entrada válida
while true; do
    read -n1 choice
    if [[ "$choice" == "1" || "$choice" == "q" ]]; then
        break
    fi
done
}

while true; do
    show_menu
    case $choice in
        1)
    echo -e "\n"

    FIRMWARE_DIR="$PWD/caravel/firmware"

    if [ -d "$FIRMWARE_DIR" ]; then
        firmwares=()
        while IFS= read -r -d $'\0' dir; do
            firmwares+=("$dir")
        done < <(find "$FIRMWARE_DIR" -maxdepth 1 -type d -not -path "$FIRMWARE_DIR" -print0)
        
        if [ ${#firmwares[@]} -eq 0 ]; then
            echo -e "${RED}No firmware found${NC}"
            continue
        fi

        echo -e "${BLUE}Select Firmware to Flash:${NC}\n"
        for i in "${!firmwares[@]}"; do
            folder_name=$(basename "${firmwares[$i]}")
            echo -e "$((i+1))) $folder_name"
        done
        echo ""

        read -n1 -s -r -p "" subchoice
        echo
        if [[ "$subchoice" =~ ^[0-9]+$ ]] && [ "$subchoice" -ge 1 ] && [ "$subchoice" -le "${#firmwares[@]}" ]; then
            selected="${firmwares[$((subchoice-1))]}"
            folder_name=$(basename "$selected")
            echo -e "${BLUE}Flashing: $folder_name${NC}\n"

            if [ -f "$selected/Makefile" ]; then
                (cd "$selected" && make flash)
                if [ $? -ne 0 ]; then
                    echo -e "\n${RED}Flash failed${NC}"
                fi
            else
                echo -e "${RED}Error: No Makefile found in $selected.${NC}"
            fi
        fi
    fi
    ;;

        2)
            DIR="./caravel/firmware"
            read -rp "Enter name for new firmware subdirectory: " newfw

            if [ -z "$newfw" ]; then
                echo "❌ Name cannot be empty."
                continue
            fi

            newdir="$DIR/$newfw"
            if [ -d "$newdir" ]; then
                echo "❌ Directory $newdir already exists."
            else
                mkdir -p "$newdir"
                echo "✅ Created new firmware directory: $newdir"

                # Crear Makefile básico
                cat > "$newdir/Makefile" <<EOL
all:
\t@echo "Building firmware..."

flash:
\t@echo "Flashing firmware..."
EOL
                echo "✅ Basic Makefile created in $newdir"
            fi
            ;;
        q|Q)
            echo -e "\n\nGoodbye!"
            break
            ;;
        *)
            echo "❌ Invalid option"
            ;;
    esac
    echo ""
done
