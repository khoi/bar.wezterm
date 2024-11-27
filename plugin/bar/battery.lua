local wez = require "wezterm"

local M = {}

-- Get battery info
local function get_battery_status()
  -- Get battery info from wezterm
  local battery = wez.battery_info()
  if not battery or #battery == 0 then
    return ""
  end

  -- Get first battery
  local first_battery = battery[1]
  local percentage = first_battery.state_of_charge * 100

  -- Show lightning bolt when charging
  if first_battery.state == "Charging" or first_battery.state == "Full" then
    return string.format("⚡%.0f%%", percentage)
  else
    return string.format("%.0f%%", percentage)
  end
end

M.get_battery_status = get_battery_status
return M
