-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

local home = os.getenv("HOME") or ""

package.path = home .. "/.config/?.lua;" .. (os.getenv("MANU_PATH") or (home .. "/.local/share/manu")) .. "/?.lua;" .. package.path

local paths = require("default.hypr.paths")

-- Use Manu defaults, but don't edit these directly.
require("default.hypr.autostart")
require("default.hypr.bindings.media")
require("default.hypr.bindings.clipboard")
require("default.hypr.bindings.tiling-v2")
require("default.hypr.bindings.utilities")
require("default.hypr.envs")
require("default.hypr.looknfeel")
require("default.hypr.input")
require("default.hypr.windows")

-- Current theme overrides.
do
  local theme = io.open(paths.config_home .. "/manu/current/theme/hyprland.lua", "r")
  if theme then
    theme:close()
    require("manu.current.theme.hyprland")
  end
end

-- Change your own setup in these files and override defaults.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- hl.window_rule({ match = { class = "qemu" }, workspace = "5" })
