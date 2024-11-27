local wez = require "wezterm"
local utilities = require "bar.utilities"

local M = {}

local last_update = 0
local stored_memory = ""

-- Get memory usage
local function get_memory_usage()
  if utilities._wait(5, last_update) then
    return stored_memory
  end

  local success, stdout, stderr
  if wez.target_triple == "x86_64-apple-darwin" or wez.target_triple == "aarch64-apple-darwin" then
    success, stdout, stderr = wez.run_child_process {
      "sh",
      "-c",
      "memory_pressure | grep 'System-wide memory free percentage:' | awk '{print int((100-$5))}'"
    }
    if success then
      local used_percent = utilities._trim(stdout)
      -- Get total memory in GB
      success, stdout, stderr = wez.run_child_process {
        "sh",
        "-c",
        "sysctl -n hw.memsize | awk '{printf \"%.1f\", $1/1024/1024/1024}'"
      }
      if success then
        local total = utilities._trim(stdout)
        local used = string.format("%.1f", total * used_percent / 100)
        stored_memory = used .. "/" .. total .. "G"
      end
    end
  else
    -- Linux memory info
    success, stdout, stderr = wez.run_child_process {
      "sh",
      "-c",
      "free -g | awk 'NR==2 {printf \"%.1f/%.1f\", $3, $2}'"
    }
    if success then
      stored_memory = utilities._trim(stdout) .. "G"
    end
  end

  if not success then
    wez.log_error(stderr)
    return ""
  end

  last_update = os.time()
  return stored_memory
end

M.get_memory_usage = get_memory_usage
return M
