local sqlite3 = require("lsqlite3")
local db = sqlite3.open("monsters.db")

db:exec([[
	CREATE TABLE IF NOT EXISTS monsters (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	category TEXT NOT NULL,
    description TEXT NOT NULL,
    armor_class INTEGER NOT NULL DEFAULT 10,
    hit_dice INTEGER NOT NULL DEFAULT 1,
    thac0 INTEGER NOT NULL DEFAULT 20,
    appearing TEXT NOT NULL,
    saving_throws TEXT NOT NULL,
    morale INTEGER NOT NULL DEFAULT 6,
    move INTEGER NOT NULL DEFAULT 60,
    intelligence INTEGER NOT NULL DEFAULT 10,
    alignment TEXT NOT NULL,
    treasure TEXT NOT NULL,
    xp_value INTEGER NOT NULL DEFAULT 5,
    number_of_attacks INTEGER NOT NULL DEFAULT 1,
    damage TEXT NOT NULL	
]])

local M = {}

function M.get_all()
    local stmt = db:prepare(
        "SELECT id, name, category, description, armor_class, hit_dice, thac0, appearing, saving_throws, morale, intelligence, alignment, treasure, xp_value, number_of_attacks, damage FROM monsters")

    if not stmt then
        return nil
    end

    while stmt:step() == sqlite3.ROW do
        local row = stmt:get_named_values()
        table.insert(M, row)
    end

    stmt:finalize()
    return M
end

function M.create(name, category, description, armor_class, hit_dice, thac0, appearing, saving_throws, morale,
                  intelligence, alignment, treasure, xp_value, number_of_attacks, damage)
    local stmt = db:prepare(
        "INSERT INTO monsters (name, category, description, armor_class, hit_dice, thac0, appearing, saving_throws, morale, intelligence, alignment, treasure, xp_value, number_of_attacks, damage) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")

    if not stmt then
        return nil
    end

    stmt:bind_values(name, category, description, armor_class, hit_dice, thac0, appearing, saving_throws, morale,
        intelligence, alignment, treasure, xp_value, number_of_attacks, damage)

    local res = stmt:step()
    stmt:finalize()

    if res == sqlite3.DONE then
        return db:last_insert_rowid()
    end
    return nil
end

function M.delete(id)
    local stmt = db:prepare("DELETE FROM monsters WHERE id = ?")
    stmt:bind_values(id)
    local res = stmt:step()
    stmt:finalize()

    return res == sqlite3.DONE and db:changes() > 0
end

return M
