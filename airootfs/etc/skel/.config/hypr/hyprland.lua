-- =======================================================================================
-- HYPRLAND LUA CONFIGURATION (VANGUARDIA)
-- Ricing adaptado al Modo Toji por Angelito :P
-- =======================================================================================

------------------
---- MONITORS ----
------------------
-- Ajustado exactamente a su monitor principal
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "hyprlauncher"

-------------------
---- AUTOSTART ----
-------------------
-- Brain Shell Autostarts
hl.on("hyprland.start", function()
     -- Conseguimos la HOME de forma dinámica en Lua
     local home = os.getenv("HOME")
     
     hl.exec_cmd("awww-daemon")
     -- Usamos la variable local 'home' en lugar de tu ruta personal
     hl.exec_cmd("hypridle -c " .. home .. "/.local/src/Brain_Shell/src/config/hypridle.conf")
     hl.exec_cmd("quickshell -c /usr/share/Brain_Shell")
     hl.exec_cmd("systemctl --user start hyprpolkitagent")
     hl.exec_cmd("wl-paste --type text --watch cliphist store")
     hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- Brain_ShellKeybinds universales usando la variable 'home'
dofile(os.getenv("HOME") .. "/.config/Brain_Shell/Brain_ShellKeybinds.lua")

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 1,
        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding = 10,

        blur = {
            enabled        = true,
            size           = 10,
            passes         = 3,
            vibrancy       = 0.2,
            ignore_opacity = true, 
        },
    },

    animations = {
        enabled = true,
    },
})

----------------------------------------
---- DISTRIBUCIONES Y XWAYLAND ---------
----------------------------------------
hl.config({
    dwindle  = { preserve_split = true },
    master   = { new_status = "master" },
    misc     = { force_default_wallpaper = -1, disable_hyprland_logo = false },
    xwayland = { 
        enabled = true,
        force_zero_scaling = true,
    },
})

----------------------------------------
---- CURVAS BEZIER Y RESORTES ----------
----------------------------------------
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })
hl.curve("chiclosa", { type = "bezier", points = { {0.15, 1.15}, {0.15, 1.15} } }) -- <-- mi curva personalizada :D

----------------------------------------
---- ANIMACIONES DE ENTORNO ------------
----------------------------------------

-- Ventanas (Con efecto gelatinoso al entrar y moverse)
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, bezier = "chiclosa", style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 4, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "chiclosa", style = "slide" })

-- Capas (DMShell, menús)
hl.animation({ leaf = "layersIn",    enabled = true, speed = 5, bezier = "chiclosa", style = "slide" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 5, bezier = "easeOutQuint", style = "slide" })

-- Escritorios virtuales
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, bezier = "chiclosa", style = "slide" })

-- Distribuciones
hl.config({
    dwindle = { preserve_split = true },
    master  = { new_status = "master" },
    misc    = { force_default_wallpaper = -1, disable_hyprland_logo = false }
})

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout    = "latam",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad     = { natural_scroll = false },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Binds del ecosistema de Apps
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Movimiento de Foco
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Espacios de trabajo (Workspaces 1 - 10)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspaces especiales
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Rueda de ratón / Cambio de workspace
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Drag & Resize con el mouse (¡Tu joya pulida!)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Teclas multimedia (Locked & Repeating para fluidez de audio/brillo)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Controles de Playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Capturas de pantalla dirigidas a mi carpeta personalizada de ~/Imágenes/'capturas de pantalla'
hl.bind("Print",         hl.dsp.exec_cmd("hyprshot -m region -o ~/Imagenes/'capturas de pantalla'"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m window -o ~/Imagenes/'capturas de pantalla'"))
hl.bind("CTRL + Print",  hl.dsp.exec_cmd("hyprshot -m output -o ~/Imagenes/'capturas de pantalla'"))

-- Sistema de Wofi y Rofimoji
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("command wofi --show drun --allow-images"))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("command rofimoji"))

-- Hyprlock
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("command hyprlock"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Mi icónica transparencia global Toji Mode
hl.window_rule({
    name = "transparencia-global",
    match = { class = "^.*$" },
    opacity = "0.75 0.55",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

