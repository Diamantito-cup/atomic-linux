#!/bin/bash

echo "Iniciando instalación de Limine Bootloader para Atomic Linux..."

# 1. Encontrar la partición raíz y el disco base de forma dinámica
ROOT_PART=$(findmnt -n -o SOURCE /)
DISK_NAME=$(lsblk -no pkname "$ROOT_PART" | head -n 1)
TARGET_DISK="/dev/$DISK_NAME"

# Obtener UUID de la raíz para pasarle al kernel
ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PART")

# 2. Generar el archivo de configuración de Limine
cat <<EOF > /boot/limine.conf
timeout: 5
remember_last_entry: yes
interface_resolution: 1920x1080
term_background: 00000000

# Descomenta la siguiente línea si metes una imagen en /boot/
# background_path: boot():/atomic-bg.jpg

/Atomic Linux
    protocol: linux
    kernel_path: boot():/vmlinuz-linux
    initramfs_path: boot():/initramfs-linux.img
    cmdline: root=UUID=${ROOT_UUID} rw quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0
EOF

# 3. Detectar el firmware (UEFI o Legacy BIOS)
if [ -d /sys/firmware/efi ]; then
    echo "Modo UEFI detectado..."
    
    # Encontrar la partición EFI exacta y su número
    EFI_PART=$(findmnt -n -o SOURCE /boot/efi)
    EFI_NUM=$(lsblk -no PARTN "$EFI_PART")
    EFI_DISK=$(lsblk -no pkname "$EFI_PART")
    
    mkdir -p /boot/efi/EFI/BOOT
    cp /usr/share/limine/BOOTX64.EFI /boot/efi/EFI/BOOT/
    
    # Inyectar en la placa base
    efibootmgr -c -d "/dev/$EFI_DISK" -p "$EFI_NUM" -L "Atomic Linux" -l '\EFI\BOOT\BOOTX64.EFI'
else
    echo "Modo Legacy BIOS detectado..."
    limine bios-install "$TARGET_DISK"
fi

echo "¡Limine configurado con éxito!"
