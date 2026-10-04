-- ============================================================
-- Monsters Compendium - For Distribution
-- Everything is a plain Lua table; no framework needed.
-- Environment variables (all optional):
--   MONSTERS_DATA_DIR    where monsters.db lives (default: per-user data folder)
--   MONSTERS_PORT        fixed port (default: pick a free one at startup)
--   MONSTERS_NO_BROWSER  set to anything to NOT open the browser automatically
-- ============================================================

local M = {}

local is_windows = package.config:sub(1, 1) == "\\"

local function sh(cmd)
  local p = io.popen(cmd)
  if not p then return nil end
  local out = p:read("*l")
  p:close()
  return out
end

local function join(...)
  return table.concat({ ... }, is_windows and "\\" or "/")
end

local function mkdir_p(path)
  if is_windows then
    os.execute('if not exist "' .. path .. '" mkdir "' .. path .. '"')
  else
    os.execute('mkdir -p "' .. path .. '"')
  end
end

-- User data must live OUTSIDE the install folder, so updating the
-- program never touches (or deletes) someone's campaign.
local function default_data_dir()
  if is_windows then
    return join(os.getenv("APPDATA") or ".", "MonstersCompendium")
  end
  local home = os.getenv("HOME") or "."
  if sh("uname -s") == "Darwin" then
    return join(home, "Library", "Application Support", "MonstersCompendium")
  end
  local base = os.getenv("XDG_DATA_HOME")
  if not base or base == "" then base = join(home, ".local", "share") end
  return join(base, "monsters-compendium")
end

M.os = is_windows and "windows" or (sh("uname -s") == "Darwin" and "macos" or "linux")

M.data_dir = os.getenv("MONSTERS_DATA_DIR") or default_data_dir()
mkdir_p(M.data_dir)

M.db_path = join(M.data_dir, "monsters.db")
M.port_file = join(M.data_dir, "server.port") -- lets a 2nd launch find the 1st
M.log_path = join(M.data_dir, "error.log")     -- unexpected errors end up here

-- Loopback only: the server is never reachable from other machines.
M.host = "127.0.0.1"
M.port = tonumber(os.getenv("MONSTERS_PORT")) -- nil = choose a free port
M.open_browser = os.getenv("MONSTERS_NO_BROWSER") == nil

return M
