#!/bin/bash

# Spinner animation
spin() {
    local -a spinner=('|' '/' '-' '\\')
    local i=0
    local pid=$1
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r⏳ Installing... %s" "${spinner[i]}"
        i=$(( (i + 1) % 4 ))
        sleep 0.2
    done
    printf "\r✅ Done!                         \n"
}

install_step() {
    echo "🛠️  $1"
    eval "$2" &  # run in background
    spin $!
    wait $!
}

# Header
echo "🐾 Welcome to the CattyLinux Infinite Installer"
echo "==============================================="

# OS Detection
UNAME=$(uname)

if [ "$UNAME" = "Darwin" ]; then
    echo "❌ macOS is not supported for CattyLinux Infinite."
    exit 1
elif [[ "$UNAME" =~ MINGW|MSYS|CYGWIN ]]; then
    echo "⚠️ Windows detected."
    echo "💡 Install WSL and run this script inside it:"
    echo "🔗 https://aka.ms/wslinstall"
    exit 1
elif [ "$UNAME" != "Linux" ]; then
    echo "❌ Unsupported OS: $UNAME"
    exit 1
fi

# Ask for install type
echo ""
echo "💻 What do you want to install?"
echo "1) CattyLinux Infinite"
echo "2) CattyLinux Custom"
echo "3) Remove CattyLinux"
echo "4) Exit"
read -p "Enter a number [1-4]: " CHOICE

if [[ "$CHOICE" == "4" ]]; then
    echo "👋 Exiting. Bye!"
    exit 0
fi

# Full installation
if [[ "$CHOICE" == "1" ]]; then
    echo "🔧 Starting full installation of CattyLinux Infinite..."

    install_step "Updating packages" "sudo apt update && sudo apt upgrade -y"
    install_step "Installing Xorg and Plasma Desktop (minimal)" "sudo apt install -y xorg kde-plasma-desktop"
    install_step "Installing Chromium" "sudo apt install -y chromium-browser || sudo apt install -y chromium"
    install_step "Installing LXTerminal and Gedit" "sudo apt install -y lxterminal gedit"
    install_step "Installing Python3 and pip" "sudo apt install -y python3 python3-pip"
    install_step "Installing SDDM Display Manager" "sudo apt install -y sddm"
    install_step "Installing utilities (htop, neofetch, curl)" "sudo apt install -y htop curl neofetch git"

    read -p "🖥️ Set CattyLinux Infinite (Plasma) as your default environment? (y/n): " SET_DEFAULT
    if [[ "$SET_DEFAULT" == "y" || "$SET_DEFAULT" == "Y" ]]; then
        sudo systemctl enable sddm
        echo "✅ Plasma enabled as default desktop."
    else
        echo "ℹ️ Skipped setting Plasma as default."
    fi

    echo "🎉 Full installation of CattyLinux Infinite complete!"
    echo "🔁 Reboot your system to begin using it: sudo reboot"
    exit 0
fi

# Custom installation
if [[ "$CHOICE" == "2" ]]; then
    echo "🔧 Starting custom installation..."

    read -p "Install Xorg and Plasma Desktop (minimal)? (y/n): " PLASMA
    read -p "Install Chromium Browser? (y/n): " CHROMIUM
    read -p "Install LXTerminal and Gedit? (y/n): " TERMINAL
    read -p "Install Python3 and pip? (y/n): " PYTHON
    read -p "Install htop, curl, neofetch, git? (y/n): " UTILS
    read -p "Install SDDM Display Manager? (y/n): " SDDM

    install_step "Updating packages" "sudo apt update && sudo apt upgrade -y"

    [[ "$PLASMA" =~ [yY] ]] && install_step "Installing Plasma" "sudo apt install -y xorg kde-plasma-desktop"
    [[ "$CHROMIUM" =~ [yY] ]] && install_step "Installing Chromium" "sudo apt install -y chromium-browser || sudo apt install -y chromium"
    [[ "$TERMINAL" =~ [yY] ]] && install_step "Installing LXTerminal and Gedit" "sudo apt install -y lxterminal gedit"
    [[ "$PYTHON" =~ [yY] ]] && install_step "Installing Python3 and pip" "sudo apt install -y python3 python3-pip"
    [[ "$UTILS" =~ [yY] ]] && install_step "Installing System Utilities" "sudo apt install -y htop curl neofetch git"
    [[ "$SDDM" =~ [yY] ]] && install_step "Installing SDDM" "sudo apt install -y sddm"

    if [[ "$SDDM" =~ [yY] && "$PLASMA" =~ [yY] ]]; then
        read -p "Set Plasma as default desktop? (y/n): " DEF
        [[ "$DEF" =~ [yY] ]] && sudo systemctl enable sddm && echo "✅ SDDM enabled."
    fi

    echo "🎉 Custom installation of CattyLinux Infinite complete!"
    exit 0
fi

# Uninstall
if [[ "$CHOICE" == "3" ]]; then
    echo "⚠️ This will remove all CattyLinux Infinite packages. Continue? (y/n): "
    read -p "> " CONFIRM
    if [[ "$CONFIRM" =~ [yY] ]]; then
        install_step "Removing Plasma Desktop" "sudo apt remove -y kde-plasma-desktop"
        install_step "Removing Xorg" "sudo apt remove -y xorg"
        install_step "Removing Chromium" "sudo apt remove -y chromium-browser chromium"
        install_step "Removing LXTerminal and Gedit" "sudo apt remove -y lxterminal gedit"
        install_step "Removing Python3 and pip" "sudo apt remove -y python3 python3-pip"
        install_step "Removing Utilities" "sudo apt remove -y htop curl neofetch git"
        install_step "Removing SDDM" "sudo apt remove -y sddm"
        echo "🗑️  CattyLinux Infinite has been uninstalled."
    else
        echo "❌ Uninstall cancelled."
    fi
    exit 0
fi

echo "❌ Invalid choice. Exiting."
exit 1
