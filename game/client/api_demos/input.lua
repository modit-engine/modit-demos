--[[
Modit Input API Examples
------------------------

Visual reference for keyboard input, text input, clipboard access, mouse
position and buttons, cursor control, and mapped actions.

### Functions

-- Check if a key is currently held down.
-- key: String name of the key (e.g., "w", "space").
modit.input.key_down(key)

-- Check if a key was pressed this frame.
-- key: String name of the key.
modit.input.key_pressed(key)

-- Check if a key was released this frame.
-- key: String name of the key.
modit.input.key_released(key)

-- Check if a key is pressed or repeating this frame.
-- key: String name of the key.
modit.input.key_pressed_repeat(key)

-- Get typed character code for the current frame.
modit.input.get_char()

-- Get text from the system clipboard.
modit.input.get_clipboard()

-- Set text to the system clipboard.
-- text: String value to copy.
modit.input.set_clipboard(text)

-- Get current mouse position coordinates.
modit.input.get_mouse_position()

-- Get mouse X coordinate.
modit.input.get_mouse_x()

-- Get mouse Y coordinate.
modit.input.get_mouse_y()

-- Get mouse movement delta since last frame.
modit.input.get_mouse_delta()

-- Get mouse wheel scroll amount.
modit.input.get_mouse_wheel()

-- Set absolute mouse position on screen.
-- x, y: Target screen coordinates.
modit.input.set_mouse_position(x, y)

-- Check if mouse cursor is inside a screen rectangle.
-- x, y, w, h: Top-left bounds and dimensions.
modit.input.mouse_in_rect(x, y, w, h)

-- Check if a mouse button was pressed this frame.
-- button: Button index (0 = left, 1 = right, 2 = middle).
modit.input.mouse_pressed(button)

-- Check if a mouse button is held down.
-- button: Button index.
modit.input.mouse_down(button)

-- Check if a mouse button was released this frame.
-- button: Button index.
modit.input.mouse_released(button)

-- Set active window cursor icon.
-- name: String name of cursor style.
modit.input.set_cursor(name)

-- Make mouse cursor visible.
modit.input.show_cursor()

-- Hide mouse cursor.
modit.input.hide_cursor()

-- Lock mouse cursor to window center.
modit.input.lock_mouse()

-- Unlock mouse cursor.
modit.input.unlock_mouse()

-- Map an input action to a set of keys/buttons.
-- name: Action identifier string.
-- bindings: Table or array of key strings.
-- owner: Ownership identifier string.
modit.input.map_action(name, bindings, owner)

-- Check if a mapped action was pressed this frame.
-- name: Action identifier string.
modit.input.action_pressed(name)

-- Check if a mapped action is currently held down.
-- name: Action identifier string.
modit.input.action_down(name)

-- Check if a mapped action was released this frame.
-- name: Action identifier string.
modit.input.action_released(name)

-- Get how long a mapped action has been held down.
-- name: Action identifier string.
modit.input.get_action_hold_time(name)

-- Clear all actions owned by a specific module/owner.
-- owner: Owner identifier string.
modit.input.clear_owner_actions(owner)

-- Clear all registered actions.
modit.input.clear_actions()
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

local _theme = _ui.theme
local _demo = _ui.demo

--- @section State

local mouse_x = 0
local mouse_y = 0
local mouse_dx = 0
local mouse_dy = 0
local mouse_wheel = 0

local nav_x = 620
local nav_y = 195

local clipboard_text = ""
local cursor_hidden = false
local mouse_locked = false

local action_owner = "input_demo"
local action_name = "input_demo_jump"
local cursor_toggle_key = "f1"

--- @section Test Functions

local function test_keyboard()
    _ui.heading("01 / Keyboard", 30, 88)
    _ui.panel_box(30, 120, 385, 170, "normal")

    _ui.label("Hold these keys to test key_down()", 48, 136)

    _ui.status("W", _input.key_down("w"), 48, 164)
    _ui.status("A", _input.key_down("a"), 92, 164)
    _ui.status("S", _input.key_down("s"), 136, 164)
    _ui.status("D", _input.key_down("d"), 180, 164)
    _ui.status("SPACE", _input.key_down("space"), 224, 164)
    _ui.status("SHIFT", _input.key_down("leftshift"), 310, 164)

    _ui.label("Pressed this frame", 48, 196)

    _ui.status("A pressed", _input.key_pressed("a"), 48, 219)
    _ui.status("A repeat", _input.key_pressed_repeat("a"), 160, 219)
    _ui.status("A released", _input.key_released("a"), 270, 219)

    _ui.label("Action: hold SPACE", 48, 253)

    _ui.status("action_down", _input.action_down(action_name), 48, 272)
    _ui.status("action_pressed", _input.action_pressed(action_name), 160, 272)
    _ui.status("action_released", _input.action_released(action_name), 285, 272)
end

local function test_arrow_navigation()
    _ui.heading("02 / Arrow Key Navigation", 435, 88)
    _ui.panel_box(435, 120, 385, 170, "hover")

    _ui.label("Use arrow keys to move the marker", 453, 136)

    _ui.set_colour(_theme.bg_hover)
    _draw.rect(475, 160, 285, 100)

    _ui.set_colour(_theme.border_light)
    _draw.rect_lines(475, 160, 285, 100)

    _ui.set_colour(_theme.accent)
    _draw.rect(nav_x - 5, nav_y - 5, 10, 10)

    _ui.label("X:", 453, 267)
    _ui.value(nav_x, 475, 267)

    _ui.label("Y:", 535, 267)
    _ui.value(nav_y, 557, 267)
end

local function test_mouse_position()
    _ui.heading("03 / Mouse Position", 840, 88)
    _ui.panel_box(840, 120, 410, 170, "input")

    _ui.label("get_mouse_position()", 858, 139)
    _ui.label("X:", 858, 164)
    _ui.value(mouse_x, 882, 164)
    _ui.label("Y:", 958, 164)
    _ui.value(mouse_y, 982, 164)

    _ui.label("get_mouse_x()", 858, 194)
    _ui.value(_input.get_mouse_x(), 970, 194)

    _ui.label("get_mouse_y()", 858, 216)
    _ui.value(_input.get_mouse_y(), 970, 216)

    _ui.label("get_mouse_delta()", 858, 238)
    _ui.value(tostring(mouse_dx) .. ", " .. tostring(mouse_dy), 1005, 238)

    _ui.label("get_mouse_wheel()", 858, 260)
    _ui.value(mouse_wheel, 1005, 260)
end

local function test_mouse_buttons()
    _ui.heading("04 / Mouse Buttons", 30, 315)
    _ui.panel_box(30, 347, 385, 145, "normal")

    _ui.label("Press and hold mouse buttons", 48, 365)

    _ui.status("Left down", _input.mouse_down(0), 48, 391)
    _ui.status("Left pressed", _input.mouse_pressed(0), 175, 391)
    _ui.status("Left released", _input.mouse_released(0), 295, 391)

    _ui.status("Right down", _input.mouse_down(1), 48, 417)
    _ui.status("Middle down", _input.mouse_down(2), 175, 417)

    _ui.set_colour(_theme.bg_hover)
    _draw.rect(48, 445, 180, 30)

    if _input.mouse_in_rect(48, 445, 180, 30) then
        _ui.set_colour(_theme.green)
    else
        _ui.set_colour(_theme.text_secondary)
    end

    _draw.text("mouse_in_rect()", 57, 453, 13)
end

local function test_clipboard()
    _ui.heading("05 / Clipboard", 435, 315)
    _ui.panel_box(435, 347, 385, 145, "hover")

    _ui.label("Clipboard API", 453, 365)

    _ui.button_box("Copy test text", 453, 388, 160, 32)
    _ui.button_box("Read clipboard", 625, 388, 177, 32)

    _ui.label("Clipboard contents:", 453, 432)
    _ui.value(clipboard_text, 453, 454)

    if _input.mouse_pressed(0) then
        if _input.mouse_in_rect(453, 388, 160, 32) then
            _input.set_clipboard("Modit Input API test")
        elseif _input.mouse_in_rect(625, 388, 177, 32) then
            clipboard_text = _input.get_clipboard() or ""
        end
    end
end

local function test_cursor_control()
    _ui.heading("06 / Cursor Control", 840, 315)
    _ui.panel_box(840, 347, 410, 145, "input")

    _ui.label("F1 always restores cursor visibility", 858, 365)

    _ui.status("Hidden", cursor_hidden, 858, 393)
    _ui.status("Locked", mouse_locked, 958, 393)

    _ui.button_box("Show cursor", 858, 444, 105, 30)
    _ui.button_box("Hide cursor", 971, 444, 105, 30)
    _ui.button_box("Lock / Unlock", 1084, 444, 148, 30)

    if _input.mouse_pressed(0) then
        if _input.mouse_in_rect(858, 444, 105, 30) then
            _input.show_cursor()
            _input.unlock_mouse()

            cursor_hidden = false
            mouse_locked = false
        elseif _input.mouse_in_rect(971, 444, 105, 30) then
            _input.hide_cursor()

            cursor_hidden = true
            mouse_locked = false
        elseif _input.mouse_in_rect(1084, 444, 148, 30) then
            if mouse_locked then
                _input.unlock_mouse()
                _input.show_cursor()

                mouse_locked = false
                cursor_hidden = false
            else
                _input.lock_mouse()

                mouse_locked = true
                cursor_hidden = true
            end
        end
    end
end

local function test_mouse_position_control()
    _ui.heading("07 / Mouse Position Control", 30, 515)
    _ui.panel_box(30, 547, 385, 115, "normal")

    _ui.label("set_mouse_position(x, y)", 48, 565)
    _ui.label("Move cursor to screen centre", 48, 589)

    _ui.button_box("Move to centre", 48, 612, 180, 30)

    if _input.mouse_pressed(0)
        and _input.mouse_in_rect(48, 612, 180, 30) then
        _input.set_mouse_position(640, 360)
    end
end

local function test_action_hold_time()
    _ui.heading("08 / Action Hold Time", 435, 515)
    _ui.panel_box(435, 547, 385, 115, "hover")

    _ui.label("get_action_hold_time()", 453, 565)
    _ui.value(_input.get_action_hold_time(action_name), 453, 591)
    _ui.label("Hold SPACE to see the duration increase", 453, 620)
end

local function test_cursor_icon()
    _ui.heading("09 / Cursor Icon", 840, 515)
    _ui.panel_box(840, 547, 410, 115, "input")

    _ui.label("set_cursor(name)", 858, 565)
    _ui.label("F1 restores cursor visibility", 858, 589)

    _ui.button_box("Default cursor", 858, 612, 150, 30)

    if _input.mouse_pressed(0)
        and _input.mouse_in_rect(858, 612, 150, 30) then
        _input.set_cursor("default")
    end
end

--- @section Lifecycle

function m.init()
    _input.map_action(action_name, {"space"}, action_owner)
    _input.show_cursor()
    _input.unlock_mouse()
end

function m.update(dt)
    mouse_x, mouse_y = _input.get_mouse_position()
    mouse_dx, mouse_dy = _input.get_mouse_delta()
    mouse_wheel = _input.get_mouse_wheel()

    if _input.key_pressed("arrowleft") then
        nav_x = nav_x - 20
    end

    if _input.key_pressed("arrowright") then
        nav_x = nav_x + 20
    end

    if _input.key_pressed("arrowup") then
        nav_y = nav_y - 20
    end

    if _input.key_pressed("arrowdown") then
        nav_y = nav_y + 20
    end

    nav_x = math.max(485, math.min(750, nav_x))
    nav_y = math.max(175, math.min(250, nav_y))

    if _input.key_pressed(cursor_toggle_key) then
        _input.show_cursor()
        _input.unlock_mouse()

        cursor_hidden = false
        mouse_locked = false
    end
end

function m.draw()
    _draw.clear(_theme.bg_main)
    _ui.draw_header("MODIT.INPUT API DEMO", "Keyboard | Mouse | Actions - F1: Restore cursor")

    test_keyboard()
    test_arrow_navigation()
    test_mouse_position()

    test_mouse_buttons()
    test_clipboard()
    test_cursor_control()

    test_mouse_position_control()
    test_action_hold_time()
    test_cursor_icon()

    _ui.draw_footer("Modit Engine | Input demo by Case")
end

function m.quit()
    _input.clear_owner_actions(action_owner)
    _input.show_cursor()
    _input.unlock_mouse()
end

return m