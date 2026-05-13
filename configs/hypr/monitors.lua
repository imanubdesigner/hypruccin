-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
local manu_gdk_scale = 2
local manu_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(manu_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = manu_monitor_scale })

-- Portrait/rotated secondary monitor (transform: 1 = 90, 3 = 270)
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Example for Framework 13 w/ 6K XDR Apple display.
-- hl.monitor({ output = "DP-5", mode = "6016x3384@60", position = "auto", scale = 2 })
-- hl.monitor({ output = "eDP-1", mode = "2880x1920@120", position = "auto", scale = 2 })

-- Disable the second ghost monitor on an Apple 6K XDR over Thunderbolt.
-- hl.monitor({ output = "DP-2", disabled = true })
