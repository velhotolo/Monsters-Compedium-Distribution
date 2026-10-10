local lwtk           = require("lwtk")
local Color          = lwtk.Color
local get            = lwtk.StyleRef.get

-- Palette: charcoal-blue background, parchment text, gold accent
local BACKGROUND     = Color "1d2026" -- window
local FIELD          = Color "272b33" -- text inputs
local BUTTON         = Color "2f343d"
local BUTTON_HOVER   = Color "3a404b" -- mouse over
local BUTTON_PRESSED = Color "454c59" -- being clicked
local TEXT           = Color "e6e1d6"
local TEXT_DISABLED  = Color "6b717c" -- disabled button
local BORDER         = Color "4a505c"
local GOLD           = Color "d9a441" -- titles, focus, cursor

return {
    -- General: apply to every widget
    { "BackgroundColor",                            BACKGROUND },
    { "TextColor",                                  TEXT },
    { "AccentColor",                                GOLD },
    { "CursorColor",                                Color "00000000" }, -- cursor hidden without focus
    { "CursorColor:focused",                        GOLD },
    { "BorderColor@Box",                            BORDER },

    -- Titles (TitleText) in gold
    { "TextColor@TitleText",                        GOLD },

    -- Text inputs
    { "BackgroundColor@TextInput",                  FIELD },
    { "BorderColor@TextInput",                      BORDER },
    { "BorderColor@TextInput:focused",              get "AccentColor" },

    -- Buttons, in each state
    { "BackgroundColor@PushButton",                 BUTTON },
    { "BackgroundColor@PushButton:hover",           BUTTON_HOVER },
    { "BackgroundColor@PushButton:pressed",         BUTTON_HOVER },
    { "BackgroundColor@PushButton:pressed+hover",   BUTTON_PRESSED },
    { "BackgroundColor@PushButton:default",         BUTTON },
    { "BackgroundColor@PushButton:default+hover",   BUTTON_HOVER },
    { "BackgroundColor@PushButton:default+pressed", BUTTON_PRESSED },
    { "BackgroundColor@PushButton:focused",         BUTTON },
    { "BackgroundColor@PushButton:focused+hover",   BUTTON_HOVER },
    { "BackgroundColor@PushButton:focused+pressed", BUTTON_PRESSED },
    { "TextColor@PushButton:disabled",              TEXT_DISABLED },
    { "BorderColor@PushButton",                     BORDER },
    { "BorderColor@PushButton:focused",             get "AccentColor" },
    { "BorderColor@PushButton:default",             get "AccentColor" },


}
