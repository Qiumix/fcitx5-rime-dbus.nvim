local api = vim.api

local rt = {}

local enabled = true
local os_type = nil
local dbus_fn = {}

local last_state_ascii = true
local augroup_name = "RimeAutoMode"
local group = api.nvim_create_augroup(augroup_name, { clear = true })

local last_esc_time = 0
local DOUBLE_CLICK_THRESHOLD = 250 * 1000000 -- 250ms

local function init_exec()
  if os_type == "linux" then
    if vim.fn.executable "busctl" ~= 1 then
      vim.notify("Rime-DBus: busctl command not found", vim.log.levels.ERROR)
      return false
    end

    dbus_fn.get_state = function()
      local out = vim.fn.system {
        "busctl",
        "--user",
        "call",
        "org.fcitx.Fcitx5",
        "/rime",
        "org.fcitx.Fcitx.Rime1",
        "IsAsciiMode",
      }
      return out:find "true" ~= nil
    end

    dbus_fn.set_state = function(state)
      local state_str = state and "true" or "false"
      vim.fn.system {
        "busctl",
        "--user",
        "call",
        "org.fcitx.Fcitx5",
        "/rime",
        "org.fcitx.Fcitx.Rime1",
        "SetAsciiMode",
        "b",
        state_str,
      }
    end
  elseif os_type == "bsd" then
    if vim.fn.executable "dbus-send" ~= 1 then
      vim.notify("Rime-DBus: dbus-send command not found", vim.log.levels.ERROR)
      return false
    end

    dbus_fn.get_state = function()
      local out = vim.fn.system {
        "dbus-send",
        "--session",
        "--dest=org.fcitx.Fcitx5",
        "--print-reply",
        "/rime",
        "org.fcitx.Fcitx.Rime1.IsAsciiMode",
      }
      return out:find "true" ~= nil
    end

    dbus_fn.set_state = function(state)
      local state_str = state and "true" or "false"
      vim.fn.system {
        "dbus-send",
        "--session",
        "--dest=org.fcitx.Fcitx5",
        "/rime",
        "org.fcitx.Fcitx.Rime1.SetAsciiMode",
        "boolean:" .. state_str,
      }
    end
  end

  return true
end

local function init_os()
  local judged = false
  local result = false
  return function()
    if judged then
      return result
    end
    judged = true
    if vim.fn.has "linux" == 1 and vim.fn.has "android" ~= 1 then
      os_type = "linux"
      result = init_exec()
    elseif vim.fn.has "bsd" == 1 or vim.fn.has "mac" == 1 then
      os_type = "bsd"
      result = init_exec()
    else
      result = false
    end
    return result
  end
end

local check_os_and_cmd = init_os()

rt.enable = function()
  enabled = true
end
rt.disable = function()
  enabled = false
end
rt.toggle = function()
  enabled = not enabled
end

rt.force_ascii = function()
  last_state_ascii = true
  dbus_fn.set_state(true)
end

rt.setup = function(opts)
  if not check_os_and_cmd() then
    enabled = false
    return
  end

  opts = opts or {}
  if opts.enabled ~= nil then
    enabled = opts.enabled
  end

  api.nvim_clear_autocmds { group = group }

  api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      if not enabled then
        return
      end
      last_state_ascii = dbus_fn.get_state()
      if not last_state_ascii then
        dbus_fn.set_state(true)
      end
    end,
    desc = "Ensure physical ASCII mode on leave",
  })

  api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      if not enabled then
        return
      end
      if not last_state_ascii then
        dbus_fn.set_state(last_state_ascii)
      end
    end,
    desc = "Restore previous Rime input state",
  })
end

return rt
