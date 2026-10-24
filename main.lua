local lwtk = require("lwtk")
local db = require("database")

local Column, Row = lwtk.Column, lwtk.Row
local listContainer = lwtk.Column
local diagram = lwtk.Column
local registeredMonsters = lwtk.Column
local combatStats = lwtk.Column
local buttons = lwtk.Column
local filterStats = lwtk.Column
local PushButton = lwtk.PushButton
local TextLabel = lwtk.TextLabel
local TitleText = lwtk.TitleText
local Space = lwtk.Space
local monster_list = {}
local actual_index = 1
local rendered_sheet = nil
local sheet_area = lwtk.Column {}

local name = lwtk.TextInput { text = "name" }
local category = lwtk.TextInput { text = "category" }
local description = lwtk.TextInput { text = "a description" }
local armor_class = lwtk.TextInput { text = 10 }
local hit_dice = lwtk.TextInput { text = 1 }
local thac0 = lwtk.TextInput { text = 20 }
local appearing = lwtk.TextInput { text = "N of Appearence" }
local saving_throws = lwtk.TextInput { text = "F1" }
local morale = lwtk.TextInput { text = 6 }
local move = lwtk.TextInput { text = 60 }
local intelligence = lwtk.TextInput { text = 10 }
local alignment = lwtk.TextInput { text = "neutral" }
local treasure = lwtk.TextInput { text = "B" }
local xp_value = lwtk.TextInput { text = 5 }
local number_of_attacks = lwtk.TextInput { text = 1 }
local damage = lwtk.TextInput { text = "1-6" }
local filterXpValue = lwtk.TextInput { text = "" }
local filterCategory = lwtk.TextInput { text = "" }

local app = lwtk.Application("Bestiary 1.0")
app:addStyle(require("dark_theme"))
local win = lwtk.Window


local function adder()
    local nameText = name.text or "name"
    local categoryText = category.text or "dragonkin"
    local descriptionText = description.text or "descriptions"
    local armor_classText = armor_class.text or 10
    local hit_diceText = hit_dice.text or 1
    local thac0Text = thac0.text or 20
    local appearingText = appearing.text or 6
    local saving_throwsText = saving_throws.text or "F1"
    local moraleText = morale.text or 8
    local moveText = move.text or 60
    local intelligenceText = intelligence.text or 10
    local alignmentText = alignment.text or "neutral"
    local treasureText = treasure.text or "B"
    local xp_valueText = xp_value.text or 5
    local number_of_attacksText = number_of_attacks.text or 1
    local damageText = damage.text or "1-6"

    local success, return_id = pcall(db.create,
        nameText,
        categoryText,
        descriptionText,
        armor_classText,
        hit_diceText,
        thac0Text,
        appearingText,
        saving_throwsText,
        moraleText,
        moveText,
        intelligenceText,
        alignmentText,
        treasureText,
        xp_valueText,
        number_of_attacksText,
        damageText
    )


    if success and return_id then
        print("Save with id:", return_id)
        return return_id
    else
        print("ERROR: ", return_id)
        return nil
    end
end

local function writter(m)
    if not m then return lwtk.Column {} end

    local registered1 = Column {
        lwtk.Box { Row {
            Column { Space {},
                TitleText { text = "GENERAL INFO" },
                TextLabel { text = "Name: " .. m.name },
                TextLabel { text = "Category: " .. m.category },
                TextLabel { text = "Alignment: " .. m.alignment },
                TextLabel { text = "Treasure: " .. m.treasure },
                TextLabel { text = "Appearing: " .. m.appearing },
                TextLabel { text = "Description:" },
                TextLabel { text = m.description },
                Space {},
            },
        } },
    }

    local registered2 = lwtk.Box { Column {
        TitleText { text = "COMBAT STATS" },
        TextLabel { text = "Armor Class: " .. tostring(m.armor_class) },
        TextLabel { text = "THAC0: " .. tostring(m.thac0) },
        TextLabel { text = "Hit Dice: " .. tostring(m.hit_dice) },
        TextLabel { text = "Damage: " .. tostring(m.damage) },
        TextLabel { text = "Move: " .. tostring(m.move) },
        TextLabel { text = "Morale: " .. tostring(m.morale) },
        TextLabel { text = "Intelligence: " .. tostring(m.intelligence) },
        TextLabel { text = "Saving Throws: " .. tostring(m.saving_throws) },
        TextLabel { text = "XP Value: " .. tostring(m.xp_value) },
        Space {},
    },
    }

    return Row { registered1, Space {}, registered2 }
end

local function update_sheet()
    if rendered_sheet then
        sheet_area:removeChild(rendered_sheet)
        rendered_sheet = nil
    end

    if #monster_list > 0 then
        local monster = monster_list[actual_index]
        rendered_sheet = writter(monster)
        sheet_area:addChild(rendered_sheet)
    end
end

listContainer = lwtk.Box { Column {
    Row {
        Column {
            TitleText { text = "GENERAL INFO" },
            TextLabel { text = "Name:" },
            name,
            TextLabel { text = "Category" },
            category,
            TextLabel { text = "Alignment" },
            alignment,
            TextLabel { text = "Treasure" },
            treasure,
            TextLabel { text = "Number of Appearence:" },
            appearing,
            Row {
                TextLabel { text = "Description:" }
            },
            Row {
                description, },
        },
    },
},
}

buttons = Row { PushButton {
    text = "Add",
    onClicked = function()
        local new_id = adder()
        if new_id then
            monster_list = db.get_all() or {}
            actual_index = #monster_list
            update_sheet()
        end
    end
},
    PushButton {
        text = "Remove",
        onClicked = function()
        end
    },
    PushButton {
        text = "Edit",
        onClicked = function()
        end
    },
}

filterStats = lwtk.Box { Column { Row { TextLabel { text = "Filter by XP Value:" } },
    Row { filterXpValue },
    Row {
        PushButton {
            text = "Search",
            onClicked = function()
            end
        },
        PushButton {
            text = "Clear",
            onClicked = function()
            end
        }
    },

    Row { TextLabel { text = "Filter by Category:" } },

    Row { filterCategory },

    Row { PushButton {
        text = "Search",
        onClicked = function()
        end
    }, PushButton {
        text = "Clear",
        onClicked = function()
        end },
    },
},
}

combatStats = lwtk.Box { Column {
    TitleText { text = "COMBAT STATS" },
    Space {},
    TextLabel { text = "Armor Class:" },
    armor_class,
    Space {},
    TextLabel { text = "THAC0:" },
    thac0,
    Space {},
    TextLabel { text = "Hit Dice:" },
    hit_dice,
    Space {},
    TextLabel { text = "Damage:" },
    damage,
    Space {},
    TextLabel { text = "Move:" },
    move,
    Space {},
    TextLabel { text = "Morale:" },
    morale,
    Space {},
    TextLabel { text = "Intelligence:" },
    intelligence,
    Space {},
    TextLabel { text = "Saving Throws:" },
    saving_throws,
    Space {},
    TextLabel { text = "XP Value:" },
    xp_value,
    Space {}
},
}

registeredMonsters = Column {
    id = "registered",
    TitleText { text = "REGISTERED MONSTERS" },
    sheet_area,
    Space {},
    Row { lwtk.Box {
        PushButton {
            text = "<=",
            onClicked = function()
                if actual_index > 1 then
                    actual_index = actual_index - 1
                    update_sheet()
                end
            end
        } },
        Space {},
        lwtk.Box {
            PushButton {
                text = "Get PDF",
                onClicked = function()
                end
            }, Space {},
        },
        lwtk.Box {
            PushButton {
                text = "=>",
                onClicked = function()
                    if actual_index < #monster_list then
                        actual_index = actual_index + 1
                        update_sheet()
                    end
                end
            },
        },
    },
}


diagram = Row {
    Column { listContainer,
        filterStats
    },
    Column { combatStats,
        buttons
    },
    registeredMonsters }



win = app:newWindow {
    title = "BESTIARY 1.0",
    diagram,
}
win:show()
app:runEventLoop()
