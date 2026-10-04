-- ============================================================
-- Monsters Compendium - data layer (SQLite)
--
-- Rules followed here:
--   * every query that includes user data uses bound parameters
--     (?, :name). User text is NEVER concatenated into SQL.
--   * the schema version lives in PRAGMA user_version, so newer
--     program versions can upgrade older databases in place.
-- ============================================================

local ok, sqlite3 = pcall(require, "lsqlite3complete")
if not ok then sqlite3 = require("lsqlite3") end

local unpack = table.unpack or unpack

local M = {}

-- ------------------------------------------------------------
-- Fields, defaults and normalization
-- ------------------------------------------------------------
M.FIELDS = {
  "name", "category", "description", "armor_class", "hit_dice", "thac0",
  "appearing", "saving_throws", "morale", "move", "intelligence",
  "alignment", "treasure", "xp_value", "number_of_attacks", "damage",
}

local IS_TEXT = {
  name = true, category = true, description = true, saving_throws = true,
  alignment = true, treasure = true, damage = true,
}

-- One place for defaults
M.DEFAULTS = {
  category = "Beast", description = "", armor_class = 10, hit_dice = 1,
  thac0 = 20, appearing = 1, saving_throws = "F1", morale = 8, move = 90,
  intelligence = 10, alignment = "Neutral", treasure = "B", xp_value = 5,
  number_of_attacks = 1, damage = "1-6",
}

local function clean(s)
  -- drop control characters, but keep tab/newline/carriage return
  return (s:gsub("[%z\1-\8\11\12\14-\31\127]", ""))
end

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Turns arbitrary input (form fields, JSON, widget text) into a complete,
-- safe record: text trimmed and length-limited, numbers parsed, blanks
-- replaced by defaults. Returns nil + message if the name is missing.
function M.normalize(input)
  input = input or {}
  local name = input.name
  if type(name) ~= "string" and type(name) ~= "number" then name = "" end
  name = trim(clean(tostring(name)))
  if name == "" then return nil, "The 'name' field is required" end

  local m = { name = name:sub(1, 200) }
  for _, f in ipairs(M.FIELDS) do
    if f ~= "name" then
      local v = input[f]
      if IS_TEXT[f] then
        if type(v) == "string" or type(v) == "number" then
          v = trim(clean(tostring(v)))
        else
          v = ""
        end
        if v == "" then v = M.DEFAULTS[f] end
        m[f] = v:sub(1, f == "description" and 4000 or 200)
      else
        local n = tonumber(v)
        -- reject NaN, infinities and absurd values
        if n and n == n and math.abs(n) <= 1e9 then
          m[f] = math.floor(n)
        else
          m[f] = M.DEFAULTS[f]
        end
      end
    end
  end
  return m
end

-- ------------------------------------------------------------
-- Schema migrations (index = schema version)
-- ------------------------------------------------------------
local MIGRATIONS = {
  [1] = [[
    CREATE TABLE monsters_compendium (
      id                INTEGER PRIMARY KEY AUTOINCREMENT,
      name              TEXT    NOT NULL,
      category          TEXT    DEFAULT 'Beast',
      description       TEXT,
      armor_class       INTEGER DEFAULT 10,
      hit_dice          INTEGER DEFAULT 1,
      thac0             INTEGER DEFAULT 20,
      appearing         INTEGER DEFAULT 1,
      saving_throws     TEXT    NOT NULL,
      morale            INTEGER DEFAULT 8,
      move              INTEGER DEFAULT 90,
      intelligence      INTEGER DEFAULT 10,
      alignment         TEXT    NOT NULL,
      treasure          TEXT    NOT NULL,
      xp_value          INTEGER DEFAULT 5,
      number_of_attacks INTEGER DEFAULT 1,
      damage            TEXT    NOT NULL
    );
  ]],
}

local function migrate(db)
  local version = 0
  for row in db:nrows("PRAGMA user_version") do version = row.user_version end

  if version > #MIGRATIONS then
    error("This database was created by a newer version of the program.")
  end

  for v = version + 1, #MIGRATIONS do
    db:exec("BEGIN")
    local rc = db:exec(MIGRATIONS[v])
    if rc ~= sqlite3.OK then
      local msg = db:errmsg()
      db:exec("ROLLBACK")
      error("Migration " .. v .. " failed: " .. msg)
    end
    db:exec("PRAGMA user_version = " .. v) -- v is our own integer, not user data
    db:exec("COMMIT")
  end
end

-- ------------------------------------------------------------
-- Store object
-- ------------------------------------------------------------
local Store = {}
Store.__index = Store

local COLUMNS = table.concat(M.FIELDS, ", ")
local PLACEHOLDERS = ":" .. table.concat(M.FIELDS, ", :")
local INSERT_SQL = "INSERT INTO monsters_compendium (" .. COLUMNS ..
  ") VALUES (" .. PLACEHOLDERS .. ")"

function M.open(path)
  local db, _, msg = sqlite3.open(path)
  if not db then error("Cannot open database: " .. tostring(msg)) end
  db:busy_timeout(3000)
  db:exec("PRAGMA journal_mode = WAL")
  db:exec("PRAGMA foreign_keys = ON")
  migrate(db)
  return setmetatable({ db = db }, Store)
end

function Store:close()
  self.db:close()
end

-- Runs a SELECT and returns a list of row tables.
function Store:_rows(sql, args)
  local stmt = self.db:prepare(sql)
  if not stmt then
    io.stderr:write("[db] prepare failed: ", self.db:errmsg(), "\n")
    return {}
  end
  if args and #args > 0 then stmt:bind_values(unpack(args)) end
  local rows = {}
  for row in stmt:nrows() do rows[#rows + 1] = row end
  stmt:finalize()
  return rows
end

-- Escapes %, _ and \ so user text is matched literally by LIKE.
local function like_escape(s)
  return (s:gsub("[\\%%_]", "\\%0"))
end

local ORDERS = {
  weakest = "ORDER BY xp_value ASC, id DESC", -- default (old web behaviour)
  newest  = "ORDER BY id DESC",               -- old desktop behaviour
}

-- filters (all optional): name, category, min_xp, max_xp, order
function Store:search(f)
  f = f or {}
  local where, args = {}, {}

  if f.name and f.name ~= "" then
    where[#where + 1] = "name LIKE ? ESCAPE '\\'"
    args[#args + 1] = "%" .. like_escape(f.name) .. "%"
  end
  if f.category and f.category ~= "" then
    where[#where + 1] = "category = ? COLLATE NOCASE"
    args[#args + 1] = f.category
  end
  if tonumber(f.min_xp) then
    where[#where + 1] = "xp_value >= ?"
    args[#args + 1] = tonumber(f.min_xp)
  end
  if tonumber(f.max_xp) then
    where[#where + 1] = "xp_value <= ?"
    args[#args + 1] = tonumber(f.max_xp)
  end

  -- Only fixed SQL fragments are concatenated here; every value is bound.
  local sql = "SELECT * FROM monsters_compendium"
  if #where > 0 then sql = sql .. " WHERE " .. table.concat(where, " AND ") end
  sql = sql .. " " .. (ORDERS[f.order] or ORDERS.weakest)
  return self:_rows(sql, args)
end

function Store:categories()
  local out = {}
  for _, r in ipairs(self:_rows(
    "SELECT DISTINCT category FROM monsters_compendium ORDER BY category COLLATE NOCASE")) do
    out[#out + 1] = r.category
  end
  return out
end

function Store:get(id)
  id = tonumber(id)
  if not id then return nil end
  return self:_rows("SELECT * FROM monsters_compendium WHERE id = ?", { id })[1]
end

-- Returns the saved record (with its new id), or nil + error message.
function Store:insert(input)
  local m, err = M.normalize(input)
  if not m then return nil, err end

  local stmt = self.db:prepare(INSERT_SQL)
  if not stmt then
    io.stderr:write("[db] prepare failed: ", self.db:errmsg(), "\n")
    return nil, "Database error"
  end
  stmt:bind_names(m)
  local rc = stmt:step()
  stmt:finalize()
  if rc ~= sqlite3.DONE then
    io.stderr:write("[db] insert failed: ", self.db:errmsg(), "\n")
    return nil, "Database error"
  end
  m.id = self.db:last_insert_rowid()
  return m
end

-- Returns true if a row was actually deleted.
function Store:delete(id)
  id = tonumber(id)
  if not id then return false end
  local stmt = self.db:prepare("DELETE FROM monsters_compendium WHERE id = ?")
  if not stmt then return false end
  stmt:bind_values(id)
  stmt:step()
  stmt:finalize()
  return self.db:changes() > 0
end

return M
