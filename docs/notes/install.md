# Arch Linux Installation Instructions

This guide provides a comprehensive, step-by-step walkthrough for installing
Arch Linux on a system with an NVMe SSD. Arch Linux is a lightweight and
flexible Linux distribution that follows a rolling release model, giving you
access to the latest software packages. Before beginning, download the latest
Arch Linux ISO from the official website at
[https://archlinux.org/download/](https://archlinux.org/download/) and create a
bootable USB drive. This installation process will set up a minimal base system
with essential components including the bootloader, networking tools, and basic
system utilities.

The instructions assume you're booting from an Arch Linux installation medium
and have basic familiarity with Linux command-line operations. The installation
will configure a standard partition scheme with a 1GB EFI system partition, a
4GB swap partition, and the remaining space allocated to the root filesystem.
Throughout this process, you'll configure essential system settings including
timezone, locale, networking, and the GRUB bootloader to create a fully
functional Arch Linux installation ready for customization.

## 1. Wipe NVMe Drive

```bash
# Wipe NVMe drive /dev/nvme0n1
gdisk /dev/nvme0n1

# Open the partitioning tool:
#   - Press x (Extra functionality menu)
#   - Press z (Zap GPT and MBR)
#   - Confirm with y twice

# Reboot your system before proceeding
reboot now
```

## 2. Connect to the Internet

```bash
iwctl
device list
station wlan0 get-networks
station wlan0 connect <SSID>
```

## 3. Partition NVMe SSDs

```bash
# Partition /dev/nvme0n1
gdisk /dev/nvme0n1

# Create EFI partition (1GB)
# - Press n, then Enter for the default partition number and starting sector
# - Type "+1G" for size, then Enter
# - Type "ef00"

# Create swap partition (4GB)
# - Press n, then Enter for the default partition number and starting sector
# - Type "+4G" for size, then Enter
# - Type "8200"

# Create root partition (remaining space)
# - Press n, then Enter for the default partition number and starting sector
# - Press Enter to use the remaining space
# - Type "8300"
# - Press w to write changes
```

## 4. Format Partitions

```bash
# Format EFI partition
mkfs.fat -F32 /dev/nvme0n1p1

# Format swap partition
mkswap /dev/nvme0n1p2

# Format root partition
mkfs.ext4 /dev/nvme0n1p3
```

## 5. Mount Partitions

```bash
# Mount root partition
mount /dev/nvme0n1p3 /mnt

# Enable swap partition
swapon /dev/nvme0n1p2

# Create and mount EFI partition
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi
```

## 6. Install Arch Linux

```bash
pacstrap -K /mnt base linux linux-firmware intel-ucode dosfstools e2fsprogs sof-firmware networkmanager wpa_supplicant neovim tldr
```

## 7. Generate fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

## 8. Change Root into New System

```bash
arch-chroot /mnt
```

## 9. Set Time and Timezone

```bash
# Set the time zone
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime

# Generate /etc/adjtime
hwclock --systohc

# Configure time synchronization
nvim /etc/systemd/timesyncd.conf

# Modify the file as follows:
[Time]
NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
FallbackNTP=0.pool.ntp.org 1.pool.ntp.org

# Enable time synchronization service
systemctl enable systemd-timesyncd.service
```

## 10. Localization

```bash
# Edit the locale file
nvim /etc/locale.gen

# Uncomment the following line:
en_US.UTF-8 UTF-8

# Generate the locales
locale-gen

# Create the locale configuration file
echo LANG=en_US.UTF-8 > /etc/locale.conf

# Set the keyboard layout persistently
echo KEYMAP=us > /etc/vconsole.conf
```

## 11. Network Configuration

```bash
# Edit /etc/hostname and add 'archlinux' as the hostname
echo archlinux > /etc/hostname

# Enable NetworkManager
systemctl enable NetworkManager
```

## 12. Set Root Password

```bash
passwd
```

## 13. Install GRUB Bootloader

```bash
# Install GRUB packages
pacman -S grub efibootmgr

# Install GRUB to EFI
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Generate GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg
```

## 14. Finish Installation

```bash
# Exit the chroot environment
exit

# Unmount all partitions
umount -R /mnt

# Shutdown the system
shutdown now
```
