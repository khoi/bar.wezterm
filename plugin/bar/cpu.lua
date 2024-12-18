local wez = require "wezterm"
local utilities = require "bar.utilities"

local M = {}

local last_update = 0
local stored_cpu = ""

-- Get CPU load average
local function get_cpu_usage()
  if utilities._wait(5, last_update) then
    return stored_cpu
  end

  local success, stdout, stderr
  if wez.target_triple == "x86_64-apple-darwin" or wez.target_triple == "aarch64-apple-darwin" then
    success, stdout, stderr = wez.run_child_process {
      "sh",
      "-c",
      "sysctl -n vm.loadavg | awk '{print $2,$3,$4}'"
    }
  else
    success, stdout, stderr = wez.run_child_process {
      "sh",
      "-c",
      "cat /proc/loadavg | awk '{print $1,$2,$3}'"
    }
  end

  if not success then
    wez.log_error(stderr)
    return ""
  end

  stored_cpu = utilities._trim(stdout)
  last_update = os.time()
  return stored_cpu
end

M.get_cpu_usage = get_cpu_usage
return M
