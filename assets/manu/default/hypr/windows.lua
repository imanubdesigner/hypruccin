hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

hl.window_rule({ match = { class = ".*" }, tag = "+default-opacity" })

hl.window_rule({
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

require("default.hypr.apps")

hl.window_rule({ match = { tag = "default-opacity" }, opacity = "0.97 0.9" })
