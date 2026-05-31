#!/bin/bash

# =========================================================
# 1. ENCONTRAR EL PUNTO DE MONTAJE DE CALAMARES
# =========================================================
TARGET_ROOT=$(mount | grep -o '/tmp/calamares-root-[^ ]*' | head -n 1)

if [ -z "$TARGET_ROOT" ]; then
    TARGET_ROOT=$(ls -d /tmp/calamares-root-* 2>/dev/null | head -n 1)
fi

if [ -z "$TARGET_ROOT" ] || [ ! -d "$TARGET_ROOT" ]; then
    echo "ERROR: No se encontró el directorio de instalación de Calamares."
    exit 1
fi

echo "==> Directorio objetivo detectado en: $TARGET_ROOT"

# =========================================================
# 2. TRASPLANTE DEL KERNEL Y CONFIGURACIÓN DE PLYMOUTH
# =========================================================
SRC_KERNEL="/run/archiso/bootmnt/arch/boot/x86_64/vmlinuz-linux"
if [ ! -f "$SRC_KERNEL" ]; then
    SRC_KERNEL="/run/archiso/bootmnt/arch/x86_64/vmlinuz-linux"
fi

echo "==> Trasplantando el Kernel de la ISO..."
mkdir -p "$TARGET_ROOT/boot"
mkdir -p "$TARGET_ROOT/etc/mkinitcpio.d"
cp "$SRC_KERNEL" "$TARGET_ROOT/boot/vmlinuz-linux"

rm -f "$TARGET_ROOT/etc/mkinitcpio.conf.d/archiso.conf"

cat << 'EOF' > "$TARGET_ROOT/etc/mkinitcpio.d/linux.preset"
ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux"
PRESETS=('default' 'fallback')
default_image="/boot/initramfs-linux.img"
fallback_image="/boot/initramfs-linux-fallback.img"
fallback_options="-S autodetect"
EOF

# MIGRACIÓN DE PLYMOUTH: Si definiste un tema por defecto en la ISO, 
# nos aseguramos de que el sistema instalado lo tenga configurado activamente.
if [ -f "$TARGET_ROOT/etc/plymouth/plymouthd.conf" ]; then
    echo "==> Asegurando configuración y tema de Plymouth..."
    # Si usas un tema custom (ej. "atomic-logo"), puedes forzarlo aquí:
    # arch-chroot "$TARGET_ROOT" plymouth-set-default-theme -R atomic-logo
fi

echo "==> Generando initramfs real con soporte Plymouth en el disco..."
arch-chroot "$TARGET_ROOT" mkinitcpio -P

# =========================================================
# 3. HABILITAR SERVICIOS
# =========================================================
echo "==> Habilitando servicios esenciales..."
arch-chroot "$TARGET_ROOT" systemctl enable greetd NetworkManager

# =========================================================
# 4. CONFIGURACIÓN DEFINITIVA DE GREETD (DMS-GREETER)
# =========================================================
if [ -f "$TARGET_ROOT/etc/greetd/config.toml.installed" ]; then
    cp -f "$TARGET_ROOT/etc/greetd/config.toml.installed" "$TARGET_ROOT/etc/greetd/config.toml"
    rm -f "$TARGET_ROOT/etc/greetd/config.toml.installed"
fi

arch-chroot "$TARGET_ROOT" usermod -aG video,render,input greeter 2>/dev/null || true

# =========================================================
# 5. PURGA DE CALAMARES (ELIMINAR DEL AUTOSTART LUA Y DEL SISTEMA)
# =========================================================
echo "==> Eliminando Calamares del autostart de Hyprland (.lua)..."

# Remover la línea de calamares en el esqueleto (/etc/skel) para futuros usuarios
if [ -f "$TARGET_ROOT/etc/skel/.config/hypr/hyprland.lua" ]; then
    sed -i '/calamares/d' "$TARGET_ROOT/etc/skel/.config/hypr/hyprland.lua"
fi

# Remover la línea de calamares en el home del usuario que se acaba de crear
for user_dir in "$TARGET_ROOT"/home/*; do
    if [ -d "$user_dir" ] && [ -f "$user_dir/.config/hypr/hyprland.lua" ]; then
        echo "==> Limpiando autostart en: $user_dir"
        sed -i '/calamares/d' "$user_dir/.config/hypr/hyprland.lua"
    fi
done

echo "==> Desinstalando Calamares por completo del sistema definitivo..."
# Desinstalar el paquete calamares y sus dependencias huérfanas en el sistema real
arch-chroot "$TARGET_ROOT" pacman -Rns calamares --noconfirm 2>/dev/null || echo "⚠️ Calamares no se pudo remover o ya no existía."

echo "==> [PROCESO COMPLETADO EXITOSAMENTE]"
exit 0
