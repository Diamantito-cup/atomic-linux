#!/bin/bash
# =====================================================================
# Atomic Linux - Live Session Environment & Initialization Script
# =====================================================================

# 1. Variables de entorno esenciales para Wayland
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

# 2. Forzar renderizado nativo en Wayland (evita fallos de escalado y XWayland)
export GDK_BACKEND="wayland,x11"
export QT_QPA_PLATFORM="wayland;xcb"
export MOZ_ENABLE_WAYLAND=1
export CLUTTER_BACKEND=wayland
export OZONE_PLATFORM=wayland

# 3. Integración de Estilos y Temas (Kvantum y Qt6ct)
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_STYLE_OVERRIDE=kvantum

# 4. Asegurar permisos correctos en el entorno de ejecución del usuario
if [ -d "$XDG_RUNTIME_DIR" ]; then
    chmod 700 "$XDG_RUNTIME_DIR"
fi

# 5. Inicialización de configuraciones base de la sesión live
# (Aquí puedes añadir comandos rápidos de pre-arranque si fuesen necesarios)

# 6. Ejecución del compositor de ventanas de la distro
if command -v Hyprland &> /dev/null; then
    exec Hyprland
else
    # Fallback por si ocurre una emergencia en el Live USB
    exec zsh
fi
