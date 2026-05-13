-- Control your input devices.
hl.config({
  input = {
    -- kb_layout = "us,dk,eu",
    -- kb_variant = "intl",
    kb_options = "",
    repeat_rate = 50,
    repeat_delay = 300,
    numlock_by_default = true,
    -- sensitivity = 0.35,
    -- accel_profile = "flat",
    touchpad = {
      -- natural_scroll = true,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
      -- disable_while_typing = false,
      -- drag_3fg = 1,
    },
  },
})

hl.window_rule({ match = { class = "(Alacritty|kitty|foot)" }, scroll_touchpad = 1.5 })
hl.window_rule({ match = { class = "com.mitchellh.ghostty" }, scroll_touchpad = 0.2 })
