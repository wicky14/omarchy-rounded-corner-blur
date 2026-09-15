-- Window appearance module for the "Rounded Corner Blur" bar-widget plugin.
--
-- Place this file at ~/.config/hypr/appearance.lua and add
--   require("hypr.appearance")
-- near the top of ~/.config/hypr/hyprland.lua (after `require("hypr.looknfeel")`
-- if present). The plugin writes appearance state to
-- ~/.local/state/omarchy/appearance.lua and triggers `hyprctl reload`. This
-- module is loaded on every Hyprland config reload and applies that state via
-- hl.config(). When the state file is missing (fresh install, or after Reset),
-- this module is a no-op and the Omarchy defaults / active theme win.

local home = os.getenv("HOME")
local state_file = home and (home .. "/.local/state/omarchy/appearance.lua") or nil

local function load_state()
  if not state_file then
    return nil
  end

  local file = io.open(state_file, "r")
  if not file then
    return nil
  end

  local chunk = file:read("*a")
  file:close()

  if not chunk then
    return nil
  end

  local ok, state = pcall(load, chunk)
  if not ok or type(state) ~= "function" then
    return nil
  end

  local ok2, result = pcall(state)
  if not ok2 or type(result) ~= "table" then
    return nil
  end

  return result
end

local function blur_enabled(state)
  local blur = state.blur
  if type(blur) ~= "table" then
    return false
  end
  return blur.enabled == true
end

local state = load_state()
if state then
  local decoration = {}

  if state.rounding ~= nil then
    decoration.rounding = math.floor(state.rounding + 0.5)
  end

  if state.active_opacity ~= nil
    and state.active_opacity >= 0
    and state.active_opacity <= 1 then
    decoration.active_opacity = state.active_opacity
  end

  if state.inactive_opacity ~= nil
    and state.inactive_opacity >= 0
    and state.inactive_opacity <= 1 then
    decoration.inactive_opacity = state.inactive_opacity
  end

  local blur = state.blur
  if type(blur) == "table" then
    decoration.blur = { enabled = blur_enabled(state) }
    if blur_enabled(state) then
      if blur.size ~= nil then
        decoration.blur.size = math.floor(blur.size + 0.5)
      end
      if blur.passes ~= nil then
        decoration.blur.passes = math.floor(blur.passes + 0.5)
      end
    end
  end

  hl.config({ decoration = decoration })
end