#!/bin/bash
# ===================================================================
# Script de Instalación Automatizada de Limine para Atomic Linux
# ===================================================================

echo "=== CONFIGURANDO CARGADOR DE ARRANQUE LIMINE ==="

# 1. Identificar la partición raíz interna y el disco físico real
ROOT_PART=$(findmnt -n -o SOURCE /)
ROOT_UUID=$(blkid -o value -s UUID "$ROOT_PART")

# Detectar el disco padre (ej: /dev/sda o /dev/nvme0n1)
DISK_NAME=$(lsblk -no PKNAME "$ROOT_PART" 2>/dev/null | tr -d '[:space:]')
if [ -z "$DISK_NAME" ]; then
    TARGET_DISK=$(echo "$ROOT_PART" | sed -E 's/p?[0-9]+$//')
else
    TARGET_DISK="/dev/$DISK_NAME"
fi

echo "-> Partición raíz: $ROOT_PART (UUID=$ROOT_UUID)"
echo "-> Disco objetivo: $TARGET_DISK"

# 2. Configurar las rutas del Kernel según el esquema de particiones
if mountpoint -q /boot; then
    K_PATH="boot:///vmlinuz-linux"
    I_PATH="boot:///initramfs-linux.img"
else
    K_PATH="boot:///boot/vmlinuz-linux"
    I_PATH="boot:///boot/initramfs-linux.img"
fi

# 3. Detectar modo de arranque (UEFI vs BIOS) e instalar
if [ -d /sys/firmware/efi ]; then
    echo "-> MODO DETECTADO: UEFI. Desplegando binarios de 64-bits..."
    
    # Encontrar el punto de montaje del ESP (Calamares puede usar /boot o /boot/efi)
    ESP_DIR="/boot"
    if mountpoint -q /boot/efi; then
        ESP_DIR="/boot/efi"
    elif mountpoint -q /boot/EFI; then
        ESP_DIR="/boot/EFI"
    fi

    mkdir -p "$ESP_DIR/EFI/BOOT"
    cp /usr/share/limine/BOOTX64.EFI "$ESP_DIR/EFI/BOOT/BOOTX64.EFI"
    
    # Añadir la entrada oficial a la NVRAM de la placa madre
    echo "-> Registrando Atomic Linux en el firmware UEFI..."
    PART_NUM=$(echo "$ROOT_PART" | grep -oE '[0-9]+$')
    efibootmgr --create --disk "$TARGET_DISK" --part "${PART_NUM:-1}" --label "Atomic Linux (Limine)" --loader "\\EFI\\BOOT\\BOOTX64.EFI" --verbose
else
    echo "-> MODO DETECTADO: BIOS/LEGACY. Escribiendo MBR en $TARGET_DISK..."
    limine bios-install "$TARGET_DISK"
fi

# 4. Generar el archivo limine.cfg dinámico e impecable
echo "-> Generando /boot/limine.cfg..."
cat << EOF > /boot/limine.cfg
TIMEOUT=5
SERIAL=no
GRAPHICS=yes

:Atomic Linux
    PROTOCOL=linux
    KERNEL_PATH=$K_PATH
    MODULE_PATH=$I_PATH
    CMDLINE=root=UUID=$ROOT_UUID rw quiet splash
EOF

echo "=== LIMINE DESPLEGADO CON ÉXITO ==="
