-- Personal input overrides.

local sensitivity = 0
local local_input_file = (os.getenv("HOME") or "") .. "/.config/hypr/input.local.lua"
local f = io.open(local_input_file, "r")
if f then
  f:close()
  local local_cfg = dofile(local_input_file)
  if type(local_cfg) == "table" and type(local_cfg.sensitivity) == "number" then
    sensitivity = local_cfg.sensitivity
  end
end

hl.config({
  input = {
    kb_layout = "es",
    kb_options = "compose:caps",
    repeat_rate = 40,
    repeat_delay = 600,
    numlock_by_default = true,
    follow_mouse = 2,
    sensitivity = sensitivity,
    accel_profile = "flat",
    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.4,
    },
  },
})

o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
