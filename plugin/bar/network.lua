local wez = require "wezterm"
local utilities = require "bar.utilities"

local M = {}

local last_update = 0
local stored_ip = ""

-- Get primary IP address
local function get_ip_address()
  if utilities._wait(30, last_update) then
    return stored_ip
  end

  local success, stdout, stderr
  if wez.target_triple == "x86_64-apple-darwin" or wez.target_triple == "aarch64-apple-darwin" then
    success, stdout, stderr = wez.run_child_process {
      "sh",
      "-c",
      "ipconfig getifaddr en0 || ipconfig getifaddr en1"
    }
  else
    -- Linux
    success, stdout, stderr = wez.run_child_process {
      "sh",
      "-c",
      "hostname -I | awk '{print $1}'"
    }
  end

  if not success then
    wez.log_error(stderr)
    return ""
  end

  stored_ip = utilities._trim(stdout)
  last_update = os.time()
  return stored_ip
end

M.get_ip_address = get_ip_address
return M
