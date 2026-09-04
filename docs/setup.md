# Arch Linux Post-Installation Configuration

After completing the base Arch Linux installation, you'll need to configure
your system for daily use. This guide walks you through essential
post-installation steps including setting up a user account with sudo
privileges, configuring the package manager, installing graphics and audio
drivers, and enabling important system services. These configurations will
optimize your system's performance, security, and functionality, transforming
your minimal base installation into a fully operational desktop environment
ready for customization and use.

## 1. Connect to Wi-Fi

```bash
nmcli device wifi connect "<SSID>" password "<PASSWORD>"
```

## 2. Create new user & Configure sudo

```bash
# Install Zsh shell and sudo
pacman -S zsh sudo

# Create a new user with a home directory and Zsh as the default shell
useradd -m -G wheel -s /bin/zsh rahul
passwd rahul

# Set Neovim as the default editor
export EDITOR=nvim

# Edit the sudoers file to grant sudo privileges to the wheel group
visudo

# Uncomment the line: %wheel ALL=(ALL:ALL) ALL
# Log out and log back in as the new user
exit

# Then log in as user 'rahul'
login rahul
```

## 3. Configure pacman

```bash
# Edit the pacman configuration file
sudo nvim /etc/pacman.conf

# Uncomment "VerbosePkgLists" and enable ILoveCandy
# Also, enable multilib by uncommenting:
# [multilib]
# Include = /etc/pacman.d/mirrorlist
```

## 4. Update system

```bash
sudo pacman -Syu
```

## 5. Improve download speeds

```bash
# Install reflector
sudo pacman -S reflector

# Backup the current mirrorlist
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

# Update mirrorlist using reflector for the 10 fastest HTTPS mirrors
sudo reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Enable reflector service to keep mirrors up to date
sudo systemctl enable reflector.timer
```

## 6. Install yay

```bash
# Install Git and base-devel
sudo pacman -S git base-devel

# Clone Yay repository from the AUR
git clone https://aur.archlinux.org/yay.git
cd yay

# Build and install Yay
makepkg -si

# Remove folder
cd ..
rm -rf yay
```

## 7. Install graphics drivers

```bash
# Install Intel graphical drivers
sudo pacman -S intel-media-driver intel-gpu-tools libva-intel-driver mesa vulkan-intel
```

## 8. Configure audio system

```bash
# Install audio related packages, firmware, and drivers
sudo pacman -S alsa-firmware alsa-utils pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber

# Enable PipeWire services for the user
systemctl --user enable pipewire wireplumber
```

## 9. Setup bluetooth

```bash
# Install Bluetooth packages and iNet wireless daemon
sudo pacman -S bluetui bluez bluez-utils iwd

# Load Bluetooth kernel module
sudo modprobe btusb

# Enable and start the Bluetooth service
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
```

## 10. Configure power and event management

```bash
# Install power management (tuned) and event handling (acpid) packages
sudo pacman -S acpid tuned tuned-ppd

# Enable services
sudo systemctl enable tuned
sudo systemctl enable --now acpid
```

## 11. Enable firewall

```bash
# Install UFW
sudo pacman -S ufw

# Enable and start the firewall
sudo ufw enable
sudo systemctl enable ufw
```

## 12. Enable SSD TRIM support

```bash
# Enable periodic TRIM for SSDs
sudo systemctl enable fstrim.timer
```

## 13. Setup firmware and disk management

```bash
# Install fwupd and udisks2
sudo pacman -S fwupd udisks2

# Check compatible components with fwupd
fwupdmgr get-devices

# List updates available for any devices on the system
fwupdmgr get-updates

# Install available updates
fwupdmgr update
```

## 14. Install all required packages (OPTIONAL)

```bash
# Install Native (Arch Repo) packages
sudo pacman -S --needed - < docs/native_pkgs.txt

# Install Foreign (AUR/Local) packages
yay -S --needed - < docs/foreign_pkgs.txt
```
