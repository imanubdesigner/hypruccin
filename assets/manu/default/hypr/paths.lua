local home = os.getenv("HOME") or ""

return {
  home = home,
  config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config"),
  state_home = os.getenv("XDG_STATE_HOME") or (home .. "/.local/state"),
  manu_path = os.getenv("MANU_PATH") or (home .. "/.local/share/manu"),
}
