--[[
Modit Image API Examples
------------------------

Visual reference for loading single images and sprite sheets, drawing frames,
handling sprite animations, applying scale and color tinting, and memory cleanup.

### Functions

-- Load an image or sprite sheet instance from file or options table.
-- opts: String file path OR table `{ path, type?, frame_width?, frame_height?, animations? }`.
modit.image.load(opts)

-- Unload all cached images from memory.
modit.image.cleanup()

-- Get image dimensions in pixels.
-- Returns: width, height.
image:get_size()

-- Draw the full image at screen position with optional scaling and tinting.
-- x, y: Screen coordinates.
-- scale: Optional scale multiplier (default 1.0).
-- tint: Optional color tint table `{r, g, b, a}`.
image:draw(x, y, scale, tint)

-- Draw a specific rectangular source frame from the image sheet.
-- frame_x, frame_y: Top-left source frame offset in pixels.
-- frame_w, frame_h: Frame width and height in pixels.
-- x, y: Screen coordinates.
-- scale: Optional scale multiplier (default 1.0).
-- tint: Optional color tint table `{r, g, b, a}`.
image:draw_frame(frame_x, frame_y, frame_w, frame_h, x, y, scale, tint)

-- Draw a named animation frame from a configured sprite sheet instance.
-- anim: Animation string name.
-- frame_idx: 1-based frame index.
-- x, y: Screen coordinates.
-- scale: Optional scale multiplier (default 1.0).
-- tint: Optional color tint table `{r, g, b, a}`.
image:draw_sprite(anim, frame_idx, x, y, scale, tint)

-- Unload this image instance from VRAM and remove from cache.
image:unload()
]]

--- @section Imports

--- UI Helpers shared by tests
--- @see client.ui_helpers
local _ui = require("client.ui_helpers")

--- @section Initialisation

local client = {}

--- Localizing global API references caches table lookups for improved performance
local _draw = modit.draw2d
local _input = modit.input
local _image = modit.image

local _theme = _ui.theme
local _demo = _ui.demo

--- @section State

local img_icon = nil
local img_sprite = nil

local icon_visible = true
local icon_pulse = false
local timer = 0

local char_x = 880
local char_y = 280
local char_speed = 120
local current_anim = "idle_front"
local char_frame = 1
local anim_timer = 0
local anim_speed = 0.15

local anim_list = {
    "idle_front", "idle_back", "idle_right", "idle_left",
    "walk_front", "walk_back", "walk_right", "walk_left",
    "jump_front", "jump_back", "jump_right", "jump_left",
    "death_front", "death_back", "death_right", "death_left",
    "chop_front_left", "chop_front_right", "chop_back_right", "chop_back_left", "chop_right", "chop_left",
    "pickup_front", "pickup_back", "pickup_right", "pickup_left"
}
local anim_index = 1

--- @section Test Functions

local function test_single_image(dt)
    _ui.heading("01 / Single Image & Controls", 30, 88)
    _ui.panel_box(30, 120, 580, 540, "normal")

    _ui.label("Display area:", 50, 138)

    _ui.set_colour(_theme.bg_hover)
    _draw.rect(50, 160, 540, 320)
    _ui.set_colour(_theme.border_light)
    _draw.rect_lines(50, 160, 540, 320)

    if img_icon and icon_visible then
        local base_scale = 1.0
        if icon_pulse then
            base_scale = 1.0 + math.sin(timer * 5) * 0.25
        end

        local width, height = img_icon:get_size()
        local render_w = width * base_scale
        local render_h = height * base_scale
        local draw_x = 320 - (render_w / 2)
        local draw_y = 320 - (render_h / 2)

        local active_tint = icon_pulse and { r = 255, g = 200, b = 100, a = 255 } or { r = 255, g = 255, b = 255, a = 255 }
        img_icon:draw(draw_x, draw_y, base_scale, active_tint)
    elseif not img_icon then
        _ui.set_colour(_theme.red)
        _draw.text("Image Unloaded", 250, 310, 16)
    else
        _ui.set_colour(_theme.text_secondary)
        _draw.text("Image Hidden", 260, 310, 16)
    end

    _ui.button_box(img_icon and "Unload Image" or "Load Image", 50, 500, 120, 32)
    _ui.button_box(icon_visible and "Hide Image" or "Show Image", 180, 500, 120, 32)
    _ui.button_box(icon_pulse and "Stop Pulse" or "Pulse Scale", 310, 500, 120, 32)
    _ui.button_box("Reset Effects", 440, 500, 120, 32)

    if img_icon then
        local w, h = img_icon:get_size()
        _ui.label("Dimensions: " .. tostring(w) .. "x" .. tostring(h) .. " px", 50, 550)
    else
        _ui.label("Dimensions: N/A", 50, 550)
    end

    if _input.mouse_pressed(0) then
        if _input.mouse_in_rect(50, 500, 120, 32) then
            if img_icon then
                img_icon:unload()
                img_icon = nil
            else
                img_icon = _image.load("game/assets/images/modit_icon.png")
            end
        elseif _input.mouse_in_rect(180, 500, 120, 32) then
            icon_visible = not icon_visible
        elseif _input.mouse_in_rect(310, 500, 120, 32) then
            icon_pulse = not icon_pulse
        elseif _input.mouse_in_rect(440, 500, 120, 32) then
            icon_pulse = false
            icon_visible = true
        end
    end
end

local function test_sprite_sheet(dt)
    _ui.heading("02 / Sprite Sheet & Animations", 640, 88)
    _ui.panel_box(640, 120, 580, 540, "normal")

    _ui.label("WASD to move | Cycle animations with buttons", 660, 138)

    _ui.set_colour(_theme.bg_hover)
    _draw.rect(660, 160, 540, 320)
    _ui.set_colour(_theme.border_light)
    _draw.rect_lines(660, 160, 540, 320)

    if img_sprite then
        img_sprite:draw_sprite(current_anim, char_frame, char_x, char_y, 6)
    else
        _ui.set_colour(_theme.red)
        _draw.text("Sprite Sheet Unloaded", 830, 310, 16)
    end

    _ui.label("Current Animation:", 660, 500)
    _ui.value(current_anim, 800, 500)

    _ui.button_box("Prev Anim", 660, 535, 110, 32)
    _ui.button_box("Next Anim", 780, 535, 110, 32)
    _ui.button_box(img_sprite and "Unload Sprite" or "Reload Sprite", 900, 535, 140, 32)

    _ui.label("Position X:", 660, 600)
    _ui.value(math.floor(char_x), 740, 600)
    _ui.label("Position Y:", 820, 600)
    _ui.value(math.floor(char_y), 900, 600)

    if _input.mouse_pressed(0) then
        if _input.mouse_in_rect(660, 535, 110, 32) then
            anim_index = anim_index - 1
            if anim_index < 1 then anim_index = #anim_list end
            current_anim = anim_list[anim_index]
            char_frame = 1
        elseif _input.mouse_in_rect(780, 535, 110, 32) then
            anim_index = (anim_index % #anim_list) + 1
            current_anim = anim_list[anim_index]
            char_frame = 1
        elseif _input.mouse_in_rect(900, 535, 140, 32) then
            if img_sprite then
                img_sprite:unload()
                img_sprite = nil
            else
                img_sprite = _image.load({
                    path = "game/assets/images/rpg_base_character_16.png",
                    type = "sprite",
                    frame_width = 16,
                    frame_height = 16,
                    animations = {
                        idle_front = { y = 0, frames = 2 },
                        idle_back = { y = 1, frames = 2 },
                        idle_right = { y = 2, frames = 2 },
                        idle_left = { y = 3, frames = 2 },
                        walk_front = { y = 4, frames = 4 },
                        walk_back = { y = 5, frames = 4 },
                        walk_right = { y = 6, frames = 4 },
                        walk_left = { y = 7, frames = 4 },
                        jump_front = { y = 8, frames = 4 },
                        jump_back = { y = 9, frames = 4 },
                        jump_right = { y = 10, frames = 4 },
                        jump_left = { y = 11, frames = 4 },
                        death_front = { y = 12, frames = 4 },
                        death_back = { y = 13, frames = 4 },
                        death_right = { y = 14, frames = 4 },
                        death_left = { y = 15, frames = 4 },
                        chop_front_left = { y = 16, frames = 4 },
                        chop_front_right = { y = 17, frames = 4 },
                        chop_back_right = { y = 18, frames = 4 },
                        chop_back_left = { y = 19, frames = 4 },
                        chop_right = { y = 20, frames = 4 },
                        chop_left = { y = 21, frames = 4 },
                        pickup_front = { y = 22, frames = 4 },
                        pickup_back = { y = 23, frames = 4 },
                        pickup_right = { y = 24, frames = 4 },
                        pickup_left = { y = 25, frames = 4 },
                    }
                })
            end
        end
    end
end

--- @section Lifecycle

function client.init()
    img_icon = _image.load("game/assets/images/modit_icon.png")

    img_sprite = _image.load({
        path = "game/assets/images/rpg_base_character_16.png",
        type = "sprite",
        frame_width = 16,
        frame_height = 16,
        animations = {
            idle_front = { y = 0, frames = 2 },
            idle_back = { y = 1, frames = 2 },
            idle_right = { y = 2, frames = 2 },
            idle_left = { y = 3, frames = 2 },
            walk_front = { y = 4, frames = 4 },
            walk_back = { y = 5, frames = 4 },
            walk_right = { y = 6, frames = 4 },
            walk_left = { y = 7, frames = 4 },
            jump_front = { y = 8, frames = 4 },
            jump_back = { y = 9, frames = 4 },
            jump_right = { y = 10, frames = 4 },
            jump_left = { y = 11, frames = 4 },
            death_front = { y = 12, frames = 4 },
            death_back  = { y = 13, frames = 4 },
            death_right = { y = 14, frames = 4 },
            death_left  = { y = 15, frames = 4 },
            chop_front_left = { y = 16, frames = 4 },
            chop_front_right = { y = 17, frames = 4 },
            chop_back_right = { y = 18, frames = 4 },
            chop_back_left = { y = 19, frames = 4 },
            chop_right = { y = 20, frames = 4 },
            chop_left = { y = 21, frames = 4 },
            pickup_front = { y = 22, frames = 4 },
            pickup_back = { y = 23, frames = 4 },
            pickup_right = { y = 24, frames = 4 },
            pickup_left = { y = 25, frames = 4 },
        }
    })

    print("Modit Image test suite loaded")
end

function client.update(dt)
    dt = dt or 0.016
    timer = timer + dt
    local moving = false

    if _input.key_down("w") or _input.key_down("arrowup") then
        char_y = char_y - char_speed * dt
        current_anim = "walk_back"
        moving = true
    elseif _input.key_down("s") or _input.key_down("arrowdown") then
        char_y = char_y + char_speed * dt
        current_anim = "walk_front"
        moving = true
    elseif _input.key_down("a") or _input.key_down("arrowleft") then
        char_x = char_x - char_speed * dt
        current_anim = "walk_left"
        moving = true
    elseif _input.key_down("d") or _input.key_down("arrowright") then
        char_x = char_x + char_speed * dt
        current_anim = "walk_right"
        moving = true
    end

    char_x = math.max(680, math.min(1150, char_x))
    char_y = math.max(180, math.min(420, char_y))

    anim_timer = anim_timer + dt
    if anim_timer >= anim_speed then
        anim_timer = 0
        local max_frames = 4
        if current_anim:match("^idle_") then max_frames = 2 end
        char_frame = (char_frame % max_frames) + 1
    end
end

function client.draw()
    _draw.clear(_theme.bg_main)
    _ui.draw_header("MODIT.IMAGE API DEMO", "Single Image | Sprite Sheets | Full Animations | Controls")

    test_single_image(0.016)
    test_sprite_sheet(0.016)

    _ui.draw_footer("Modit Engine | Image demo by Case")
end

function client.quit()
    if img_icon then img_icon:unload() end
    if img_sprite then img_sprite:unload() end
    _image.cleanup()
end

return client