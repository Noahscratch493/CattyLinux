#!/usr/bin/env python3
import subprocess
import sys
import time
import shutil
import platform

spinner_cycle = ['|', '/', '-', '\\']

def spinner(seconds=5, prefix="Installing"):
    print(prefix, end=' ', flush=True)
    for i in range(seconds * 4):
        print(spinner_cycle[i % len(spinner_cycle)], end='\b', flush=True)
        time.sleep(0.25)
    print()

def run_command(cmd, show_output=True):
    try:
        if show_output:
            subprocess.run(cmd, shell=True, check=True)
        else:
            subprocess.run(cmd, shell=True, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        print(f"❌ Command failed: {cmd}")
        sys.exit(1)

def update_system():
    print("🔄 Updating system package lists...")
    run_command("sudo apt update", show_output=False)
    run_command("sudo apt upgrade -y", show_output=False)
    print("✅ System updated.\n")

def install_packages(packages):
    for pkg in packages:
        print(f"⬇️ Installing {pkg} ...")
        run_command(f"sudo apt install -y {pkg}", show_output=False)
        spinner(3, prefix=f"Installing {pkg}")

def set_plasma_default():
    print("⚙️ Setting Plasma as default desktop environment...")
    run_command("sudo systemctl enable sddm.service", show_output=False)
    run_command("sudo systemctl set-default graphical.target", show_output=False)
    spinner(2, prefix="Configuring")

def uninstall_cattylinux():
    pkgs = [
        "plasma-desktop", "sddm", "xorg",
        "chromium-browser", "lxterminal", "gedit",
        "python3", "python3-pip"
    ]
    print("🗑️ Uninstalling CattyLinux Infinite components...")
    for pkg in pkgs:
        print(f"Removing {pkg} ...")
        run_command(f"sudo apt remove --purge -y {pkg}", show_output=False)
        spinner(2, prefix=f"Removing {pkg}")
    print("🧹 Cleanup...")
    run_command("sudo apt autoremove -y", show_output=False)
    print("✅ Uninstall complete.")

def unsupported_os():
    print("⚠️ Your OS is unsupported by this installer.")
    if platform.system() == "Darwin":
        print("Sorry, macOS is not supported.")
    elif platform.system() == "Windows":
        print("Your OS, Windows, is unsupported but there is some luck! Install WSL (Windows Subsystem for Linux) and then you can install CattyLinux Infinite inside WSL!")
    sys.exit(0)

def main():
    os_name = platform.system()
    if os_name not in ["Linux"]:
        unsupported_os()

    while True:
        print("\n🐾 CattyLinux Infinite Installer")
        print("What do you want to do?")
        print("1) Full installation (recommended)")
        print("2) Custom installation")
        print("3) Uninstall CattyLinux Infinite")
        print("4) Exit")
        choice = input("Enter your choice (1-4): ").strip()

        if choice == "1":
            update_system()
            pkgs = [
                "plasma-desktop", "sddm", "xorg",
                "chromium-browser", "lxterminal", "gedit",
                "python3", "python3-pip"
            ]
            install_packages(pkgs)
            set_plasma_default()
            print("\n🎉 Full installation complete! Reboot your system to start using CattyLinux Infinite.")
            break

        elif choice == "2":
            update_system()
            available_pkgs = {
                "1": "plasma-desktop",
                "2": "sddm",
                "3": "xorg",
                "4": "chromium-browser",
                "5": "lxterminal",
                "6": "gedit",
                "7": "python3",
                "8": "python3-pip"
            }
            print("\nChoose packages to install (separate numbers with spaces):")
            for k, v in available_pkgs.items():
                print(f"{k}) {v}")
            selections = input("Your choices: ").strip().split()

            selected_pkgs = [available_pkgs[s] for s in selections if s in available_pkgs]
            if not selected_pkgs:
                print("No valid packages selected, aborting.")
                continue

            install_packages(selected_pkgs)

            if "1" in selections:
                default_env = input("Set Plasma as the default desktop environment? (y/n): ").strip().lower()
                if default_env == "y":
                    set_plasma_default()

            print("\n🎉 Custom installation complete! Reboot your system if needed.")
            break

        elif choice == "3":
            uninstall_cattylinux()
            break

        elif choice == "4":
            print("👋 Goodbye!")
            sys.exit(0)
        else:
            print("❌ Invalid choice, try again.")

if __name__ == "__main__":
    main()
