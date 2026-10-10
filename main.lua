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
local monsters = {}

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
    local intelligenceText = intelligence.text or 10
    local alignmentText = alignment.text or "neutral"
    local treasureText = treasure.text or "B"
    local xp_valueText = xp_value.text or 5
    local number_of_attacksText = number_of_attacks.text or 1
    local damageText = damage.text or "1-6"

    local id, err = pcall(db.create, {
        nameText,
        categoryText,
        descriptionText,
        armor_classText,
        hit_diceText,
        thac0Text,
        appearingText,
        saving_throwsText,
        moraleText,
        intelligenceText,
        alignmentText,
        treasureText,
        xp_valueText,
        number_of_attacksText,
        damageText
    })

    if id then
        print("Monster created!")
        table.insert(monsters, id)
    else
        print("ERROR: ", err)
    end
    return true
end

local function refresh()
    if #monsters > 0 then
        monsters = db.fetch_all()
        return monsters
    end

    if win.view then
        win.view:postRedisplay()
    end
end



local function writter()
    local registered1 = Column {
        Row {
            Column { Space {},
                TitleText { text = "GENERAL INFO" },
                TextLabel { text = "Name:" },
                TextLabel { text = name.text },
                TextLabel { text = "Category" },
                TextLabel { text = category.text },
                TextLabel { text = "Alignment" },
                TextLabel { text = alignment.text },
                TextLabel { text = "Treasure" },
                TextLabel { text = treasure.text },
                TextLabel { text = "Number of Appearence:" },
                TextLabel { text = appearing.text },
                Row {
                    TextLabel { text = "Description:" }
                },
                Row {
                    TextLabel { text = description.text },
                    Space {},
                },

            },
        },
        Space {},
    }

    local registered2 = Column {
        TitleText { text = "COMBAT STATS" },
        TextLabel { text = "Armor Class:" },
        TextLabel { text = tostring(armor_class.text) },
        TextLabel { text = "THAC0:" },
        TextLabel { text = tostring(thac0.text) },
        TextLabel { text = "Hit Dice:" },
        TextLabel { text = tostring(hit_dice.text) },
        TextLabel { text = "Damage:" },
        TextLabel { text = tostring(damage.text) },
        TextLabel { text = "Move:" },
        TextLabel { text = tostring(move.text) },
        TextLabel { text = "Morale:" },
        TextLabel { text = tostring(morale.text) },
        TextLabel { text = "Intelligence:" },
        TextLabel { text = tostring(intelligence.text) },
        TextLabel { text = "Saving Throws:" },
        TextLabel { text = saving_throws.text },
        TextLabel { text = "XP Value:" },
        TextLabel { text = tostring(xp_value.text) },
        Space {},
    }

    return Row { registered1, Space {}, registered2 }
end

listContainer = Column {
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
}

buttons = Row { PushButton {
    text = "Add",
    onClicked = function(self)
        local layout2 = writter()
        if adder() then
            self:byId("registered"):addChild(layout2)
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

filterStats = Column { Row { TextLabel { text = "Filter by XP Value:" } },
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

    }


}



combatStats = Column {
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
}

registeredMonsters = Column {
    id = "registered",
    Space {}, TitleText { text = "REGISTERED MONSTERS" },
    Row { PushButton {
        text = "<=",
        onClicked = function()
        end }, Space {}, Space {},
        PushButton {
            text = "=>",
            onClicked = function()
            end } },
    Space {},
    Space {},
    Space {},
    Space {},
    Space {},
    Space {},
    Space {},
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
    size = { 1200, 1900 },
    diagram,
}
win:show()
app:runEventLoop()
