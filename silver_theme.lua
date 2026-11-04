local lwtk           = require("lwtk")
local Color          = lwtk.Color
local get            = lwtk.StyleRef.get

local BACKGROUND     = Color "120000" -- Fundo puro escuro
local FIELD          = Color "240000" -- Áreas de texto
local BUTTON         = Color "380000" -- Botões
local BUTTON_HOVER   = Color "5c0000" -- Mouse por cima
local BUTTON_PRESSED = Color "8a0000" -- Clique
local TEXT           = Color "ffcccc" -- Branco avermelhado
local TEXT_DISABLED  = Color "4d1a1a" -- Texto desativado
local BORDER         = Color "4d0000" -- Bordas
local ACCENT         = Color "ff3333" -- Vermelho sangue

return {
    { "BackgroundColor",                            BACKGROUND },
    { "TextColor",                                  TEXT },
    { "AccentColor",                                ACCENT },
    { "CursorColor",                                Color "00000000" },
    { "CursorColor:focused",                        ACCENT },
    { "BorderColor@Box",                            BORDER },
    { "TextColor@TitleText",                        ACCENT },
    { "TextSize@FieldLabel",                        18 },
    { "TextSize@FieldValue",                        14 },
    { "BackgroundColor@TextInput",                  FIELD },
    { "BorderColor@TextInput",                      BORDER },
    { "BorderColor@TextInput:focused",              get "AccentColor" },
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