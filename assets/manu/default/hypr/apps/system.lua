hl.window_rule({ match = { tag = "floating-window" }, float = true })
hl.window_rule({ match = { tag = "floating-window" }, center = true })
hl.window_rule({ match = { tag = "floating-window" }, size = { 875, 600 } })

hl.window_rule({ match = { class = "(org.manu.bluetui|org.manu.impala|org.manu.wiremix|org.manu.btop|org.manu.terminal|org.manu.bash|org.codeberg.dnkl.foot|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|Manu|About|TUI.float|imv|mpv)" }, tag = "+floating-window" })
hl.window_rule({ match = { class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus)", title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)" }, tag = "+floating-window" })
hl.window_rule({ match = { class = "org.gnome.Calculator" }, float = true })

hl.window_rule({ match = { class = "org.manu.screensaver" }, fullscreen = true })
hl.window_rule({ match = { class = "org.manu.screensaver" }, float = true })
hl.window_rule({ match = { class = "org.manu.screensaver" }, animation = "slide" })

hl.window_rule({ match = { class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$" }, tag = "-default-opacity" })
hl.window_rule({ match = { class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$" }, opacity = "1 1" })

hl.window_rule({ match = { tag = "pop" }, rounding = 8 })

hl.window_rule({ match = { tag = "noidle" }, idle_inhibit = "always" })

hl.layer_rule({ match = { namespace = "manu-image-selector" }, no_anim = true })
