--[[
Modit Font API Examples
-----------------------

Visual reference for loading fonts, getting cached fonts, measuring text,
drawing with custom font handles, and cleaning up font caches.

### Functions

-- Load a font from file at a specified pixel size.
-- path: File path to TTF/OTF font.
-- size: Font pixel height.
-- codepoints: Optional table of specific codepoints to load.
modit.font.load(path, size, codepoints)

-- Get a cached font instance, loading on demand if necessary.
-- size: Font pixel height.
-- path: Optional file path (defaults to engine default font).
modit.font.get(size, path)

-- Measure text width using the cached default font.
-- size: Font pixel height.
-- text: String to measure.
modit.font.width(size, text)

-- Unload every cached font from memory.
modit.font.cleanup()

-- Draw text using this font instance and current colour.
-- text: String to render.
-- x, y: Screen coordinates.
font:draw(text, x, y)

-- Measure text width using this specific font instance.
-- text: String to measure.
font:measure(text)

-- Unload this font instance and clear its cache entry.
font:unload()
]]

--- @section Imports

--- UI Helpers shared by tests
--- @see client.ui_helpers
local _ui = require("client.ui_helpers")

--- @section Initialisation

local m = {}

--- Localizing global API references caches table lookups for improved performance
local _draw = modit.draw2d
local _input = modit.input
local _font = modit.font

local _theme = _ui.theme
local _demo = _ui.demo

--- @section State

local font_1, font_2, font_3 = nil, nil, nil
local err_1, err_2, err_3 = "", "", ""

local cached_font = nil
local measured_width_custom = 0
local measured_width_global = 0

--- @section Test Functions

local function test_font_loading()
    _ui.heading("01 / Font Loading", 30, 88)
    _ui.panel_box(30, 120, 385, 170, "normal")

    _ui.label("font.load() status / handles", 48, 136)

    _ui.status("Font 1", font_1 ~= nil, 48, 164)
    if not font_1 and err_1 ~= "" then
        _ui.label("Err: " .. tostring(err_1), 48, 184, 11)
    end

    _ui.status("Font 2", font_2 ~= nil, 48, 210)
    if not font_2 and err_2 ~= "" then
        _ui.label("Err: " .. tostring(err_2), 48, 230, 11)
    end

    _ui.status("Font 3", font_3 ~= nil, 48, 256)
    if not font_3 and err_3 ~= "" then
        _ui.label("Err: " .. tostring(err_3), 48, 276, 11)
    end
end

local function test_font_caching()
    _ui.heading("02 / Font Caching (get)", 435, 88)
    _ui.panel_box(435, 120, 385, 170, "hover")

    _ui.label("font.get(size, path)", 453, 136)
    _ui.status("Cached Default Font", cached_font ~= nil, 453, 164)

    _ui.label("Loads on demand and caches", 453, 196)
    _ui.label("Defaults to engine font if path nil", 453, 216)
end

local function test_font_drawing()
    _ui.heading("03 / Drawing & Measurement", 840, 88)
    _ui.panel_box(840, 120, 410, 170, "input")

    _ui.label("font:draw() samples:", 858, 136)

    if font_1 then
        _ui.set_colour(_theme.text_primary)
        font_1:draw("Font 1: The quick brown fox", 858, 158)
    end

    if font_2 then
        _ui.set_colour(_theme.accent)
        font_2:draw("Font 2: The quick brown fox", 858, 185)
    end

    if font_3 then
        _ui.set_colour(_theme.green)
        font_3:draw("Font 3: The quick brown fox", 858, 215)
    end

    _ui.label("Measured Width (Font 1):", 858, 245)
    _ui.value(measured_width_custom, 1030, 245)

    _ui.label("font.width() (global helper):", 858, 267)
    _ui.value(measured_width_global, 1050, 267)
end

local function test_font_lifecycle()
    _ui.heading("04 / Cleanup & Unload", 30, 315)
    _ui.panel_box(30, 347, 385, 145, "normal")

    _ui.label("font:unload() / font.cleanup()", 48, 365)
    _ui.label("Unloads individual handles or clears all", 48, 391, 12)

    _ui.button_box("Cleanup All Fonts", 48, 430, 160, 32)

    if _input and _input.mouse_pressed(0) then
        if _input.mouse_in_rect(48, 430, 160, 32) then
            _font.cleanup()
            font_1, font_2, font_3 = nil, nil, nil
        end
    end
end

--- @section Lifecycle

function m.init()
    font_1, err_1 = _font.load("game/assets/fonts/JetBrainsMono-Bold.ttf", 16)
    font_2, err_2 = _font.load("game/assets/fonts/Roboto-Regular.ttf", 20)
    font_3, err_3 = _font.load("game/assets/fonts/Slapstick.ttf", 14)

    cached_font = _font.get(16)

    if font_1 then
        measured_width_custom = font_1:measure("Font 1: The quick brown fox")
    end
    measured_width_global = _font.width(16, "Font 1: The quick brown fox")

    print("Modit Font test suite loaded")
end

function m.update(dt)
end

function m.draw()
    _draw.clear(_theme.bg_main)
    _ui.draw_header("MODIT.FONT API DEMO", "Load | Get | Measure | Draw | Cleanup")

    test_font_loading()
    test_font_caching()
    test_font_drawing()
    test_font_lifecycle()

    _ui.draw_footer("Modit Engine | Font demo by Case")
end

function m.quit()
    if font_1 then font_1:unload() end
    if font_2 then font_2:unload() end
    if font_3 then font_3:unload() end
    _font.cleanup()
end

return m