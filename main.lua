local lwtk               = require("lwtk")
local db                 = require("database")
local u                  = lwtk.utf8

local Column, Row        = lwtk.Column, lwtk.Row
local listContainer      = lwtk.Column
local diagram            = lwtk.Column
local registeredMonsters = lwtk.Column
local combatStats        = lwtk.Column
local buttons            = lwtk.Column
local PushButton         = lwtk.PushButton
local TextLabel          = lwtk.TextLabel
local TitleText          = lwtk.TitleText
local Space              = lwtk.Space
local monster_list       = {}
local actual_index       = 1
local rendered_sheet     = nil
local sheet_area         = lwtk.Column {}
local name               = lwtk.TextInput()
local category           = lwtk.TextInput()
local description        = lwtk.TextInput()
local armor_class        = lwtk.TextInput()
local hit_dice           = lwtk.TextInput()
local thac0              = lwtk.TextInput()
local appearing          = lwtk.TextInput()
local saving_throws      = lwtk.TextInput()
local morale             = lwtk.TextInput()
local move               = lwtk.TextInput()
local intelligence       = lwtk.TextInput()
local alignment          = lwtk.TextInput()
local treasure           = lwtk.TextInput()
local xp_value           = lwtk.TextInput()
local number_of_attacks  = lwtk.TextInput()
local damage             = lwtk.TextInput()

local app                = lwtk.Application("Bestiary 1.0")
app:addStyle(require("silver_theme"))
local win = lwtk.Window

local function getText(widget, default)
    if not widget.text or widget.text == "" then
        return default
    end
    return widget.text
end

local function adder()
    local success, return_id = pcall(db.create,
        getText(name, "The Character's Name"),
        getText(category, "Creature Type"),
        getText(description, "A description and habits."),
        getText(armor_class, 10),
        getText(hit_dice, 1),
        getText(thac0, 20),
        getText(appearing, 2),
        getText(saving_throws, "F1"),
        getText(morale, 8),
        getText(move, 60),
        getText(intelligence, 10),
        getText(alignment, "neutral"),
        getText(treasure, "B"),
        getText(xp_value, 5),
        getText(number_of_attacks, 1),
        getText(damage, "1-6")
    )

    if success and return_id then
        print("Save with id:", return_id)
        return return_id
    else
        print("ERROR: ", return_id)
        return nil
    end
end

local function makeField(label, widget)
    return Row { TextLabel { text = label }, widget }
end

local function writter(m)
    if not m then return lwtk.Column {} end

    local registered1 = Column {
        Row {
            Column {

                TitleText { text = "GENERAL INFO" },
                TextLabel { style = { { "TextSize", 16 } }, text = "Name: " },
                TextLabel { style = { { "TextSize", 14 } }, text = m.name },
                TextLabel { style = { { "TextSize", 16 } }, text = "Category: " },
                TextLabel { style = { { "TextSize", 14 } }, text = m.category },
                TextLabel { style = { { "TextSize", 16 } }, text = "Alignment: " },
                TextLabel { style = { { "TextSize", 14 } }, text = m.alignment },
                TextLabel { style = { { "TextSize", 16 } }, text = "Treasure: " },
                TextLabel { style = { { "TextSize", 14 } }, text = m.treasure },
                TextLabel { style = { { "TextSize", 16 } }, text = "Appearing: " },
                TextLabel { style = { { "TextSize", 14 } }, text = m.appearing },
                TextLabel { style = { { "TextSize", 16 } }, text = "Description:" },
                TextLabel { style = { { "TextSize", 14 } }, text = m.description },
                Space {},
                Space {},
                Space {},
            },
        },
    }



    local registered2 = Column {
        TitleText { text = "COMBAT STATS" },
        TextLabel { style = { { "TextSize", 16 } }, text = "Armor Class:" },
        TextLabel { style = { { "TextSize", 14 } }, text = tostring(m.armor_class) },
        TextLabel { style = { { "TextSize", 16 } }, text = "THAC0:" },
        TextLabel { style = { { "TextSize", 14 } }, text = tostring(m.thac0) },
        TextLabel { style = { { "TextSize", 16 } }, text = "Hit Dice:" },
        TextLabel { style = { { "TextSize", 14 } }, text = tostring(m.hit_dice) },
        TextLabel { style = { { "TextSize", 16 } }, text = "Damage:" },
        TextLabel { style = { { "TextSize", 14 } }, text = tostring(m.damage) },
        TextLabel { style = { { "TextSize", 16 } }, text = "Move: " }, Space {},
        TextLabel { style = { { "TextSize", 14 } }, text = tostring(m.move) },
        TextLabel { style = { { "TextSize", 16 } }, text = "Morale:" }, Space {},
        TextLabel { style = { { "TextSize", 14 } }, text = tostring(m.morale) },
        TextLabel { style = { { "TextSize", 16 } }, text = "Intelligence: " },
        TextLabel { style = { { "TextSize", 14 } }, text = tostring(m.intelligence) },
        TextLabel { style = { { "TextSize", 16 } }, text = "Saving Throws:" },
        TextLabel { style = { { "TextSize", 14 } }, text = tostring(m.saving_throws) },
        TextLabel { style = { { "TextSize", 16 } }, text = "XP Value:" },
        TextLabel { style = { { "TextSize", 14 } }, text = tostring(m.xp_value) },
        Space {},
        Space {},
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

buttons = lwtk.Box { Row { PushButton {
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
            sheet_area:removeChild(rendered_sheet)
            if actual_index > 1 then
                actual_index = actual_index - 1
                update_sheet()
            end
        end
    },
    PushButton {
        text = "Edit",
        onClicked = function()
        end
    },
},
}

listContainer = lwtk.Box { Column {

    Column {
        TitleText { text = "GENERAL INFO" },
        Row { TextLabel { text = "Name:         " }, name },
        Row { TextLabel { text = "Category:   " }, category }, Space {},
        Row { TextLabel { text = "Alignment: " }, alignment }, Space {},
        Row { TextLabel { text = "Treasure:    " }, treasure }, Space {},
        Row { TextLabel { text = "N of App:     " }, appearing }, Space {},
        Row { TextLabel { text = "Description:" }, description, }, Space {},
    },
},
}

combatStats = lwtk.Box { Column {
    TitleText { text = "COMBAT STATS" },
    makeField("Armor Class:   ", armor_class),
    makeField("THAC0:        ", thac0),
    makeField("Hit Dice:      ", hit_dice),
    makeField("Damage:      ", damage),
    makeField("Move:      ", move),
    makeField("Morale:    ", morale),
    makeField("Intelligence:", intelligence),
    makeField("Saving Throws:", saving_throws),
    makeField("XP Value:", xp_value)
} }


registeredMonsters = Column {
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
            },
        },
        Space {},
        Space {},
        lwtk.Box {
            PushButton {
                text = "Help",
                onClicked = function()
                end
            },
        },
        Space {},
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
        combatStats,
        buttons
    },
    registeredMonsters }

win = app:newWindow {
    title = "Bestiary 1.0",
    diagram,
}
win:show()
app:runEventLoop()
