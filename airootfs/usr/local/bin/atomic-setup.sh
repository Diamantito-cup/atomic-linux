#!/bin/bash

# 1. Esperar un momento a que el sistema se asiente
sleep 2

# 2. Detectar el nuevo usuario real en /home (omitiendo 'live' y 'greeter')
REAL_USER=$(basename $(ls -d /home/* 2>/dev/null | grep -v 'live' | grep -v 'greeter' | head -n 1))

if [ -n "$REAL_USER" ]; then
    # 3. Ceder privilegios de superusuario y grupos de video/render
    usermod -aG wheel,video,audio,input,render "$REAL_USER"

    # 4. Asegurar que el grupo wheel tenga permisos en sudoers
    echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/90-wheel
    chmod 440 /etc/sudoers.d/90-wheel

    # 5. Eliminar al usuario live y su home de la ISO
    if id "live" &>/dev/null; then
        userdel -r live 2>/dev/null
    fi

    # 6. Forzar regeneración de mkinitcpio con Plymouth por si acaso
    # (Asumiendo que el /etc/mkinitcpio.conf de la ISO ya tiene el hook 'plymouth')
    mkinitcpio -P
fi

# 7. Auto-destrucción: Desactivar este servicio para que no vuelva a correr
systemctl disable atomic-setup.service
rm -- "$0"
