--[[
Modit Canvas API Examples
-------------------------

Visual reference for creating off-screen render targets (canvases), drawing
into them, clearing render targets, scaling, and rendering them onto the screen.

### Functions

-- Create a new off-screen render target.
-- width, height: Canvas dimensions in pixels.
modit.canvas.new(width, height)

-- Start drawing into this canvas and clear it with optional RGBA color.
-- r, g, b: Color components (0-255).
-- a: Alpha component (0-255, default 255).
canvas:begin(r, g, b, a)

-- Stop drawing into the canvas and return rendering to the screen.
canvas:finish()

-- Draw the canvas stretched into a specified rectangle bounds.
-- x, y, w, h: Top-left coordinates and dimensions.
canvas:draw(x, y, w, h)

-- Draw the canvas letterboxed into a rectangle, preserving its aspect ratio.
-- x, y, w, h: Container bounds.
canvas:draw_fit(x, y, w, h)

-- Convert screen coordinates to canvas coordinates.
-- sx, sy: Screen coordinates.
canvas:to_canvas(sx, sy)

-- Free the render target from VRAM.
canvas:free()
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
local _canvas = modit.canvas

local _theme = _ui.theme
local _demo = _ui.demo

--- @section State

local minimap_canvas = nil
local canvas_visible = true
local rotation_angle = 0
local mapped_cx, mapped_cy = 0, 0

--- @section Test Functions

local function test_canvas_rendering(dt)
    _ui.heading("01 / Offscreen Canvas & Minimap View", 30, 88)
    _ui.panel_box(30, 120, 580, 540, "normal")

    _ui.label("Rendering scene to off-screen texture:", 50, 138)

    _ui.set_colour(_theme.bg_hover)
    _draw.rect(50, 160, 540, 320)
    _ui.set_colour(_theme.border_light)
    _draw.rect_lines(50, 160, 540, 320)

    if minimap_canvas then
        minimap_canvas:begin(30, 35, 45, 255)

        _ui.set_colour(_demo.red)
        _draw.circle(128, 96, 24 + math.sin(rotation_angle * 3) * 6)

        _ui.set_colour(_demo.cyan)
        _draw.rect(180, 60, 40, 40)

        _ui.set_colour(_demo.green)
        _draw.line(20, 20, 236, 160)

        _ui.set_colour(_demo.yellow)
        _draw.polygon(128, 96, 3, 16, rotation_angle)

        minimap_canvas:finish()
    end

    if minimap_canvas and canvas_visible then
        minimap_canvas:draw_fit(70, 180, 500, 280)
    elseif not minimap_canvas then
        _ui.set_colour(_theme.red)
        _draw.text("Canvas Unloaded", 230, 310, 16)
    else
        _ui.set_colour(_theme.text_secondary)
        _draw.text("Canvas Hidden", 240, 310, 16)
    end

    _ui.button_box(minimap_canvas and "Free Canvas" or "New Canvas", 50, 500, 130, 32)
    _ui.button_box(canvas_visible and "Hide Canvas" or "Show Canvas", 190, 500, 130, 32)
    _ui.button_box("Reset View", 330, 500, 110, 32)

    if minimap_canvas then
        local w, h = minimap_canvas:get_size()
        _ui.label("Resolution: " .. tostring(w) .. "x" .. tostring(h) .. " px", 50, 550)
        _ui.label("Mapped Canvas X/Y:", 250, 550)
        _ui.value(math.floor(mapped_cx) .. ", " .. math.floor(mapped_cy), 410, 550)
    else
        _ui.label("Resolution: N/A", 50, 550)
    end

    if _input.mouse_pressed(0) then
        if _input.mouse_in_rect(50, 500, 130, 32) then
            if minimap_canvas then
                minimap_canvas:free()
                minimap_canvas = nil
            else
                minimap_canvas = _canvas.new(256, 192)
            end
        elseif _input.mouse_in_rect(190, 500, 130, 32) then
            canvas_visible = not canvas_visible
        elseif _input.mouse_in_rect(330, 500, 110, 32) then
            rotation_angle = 0
            canvas_visible = true
        end
    end
end

local function test_canvas_usage_info()
    _ui.heading("02 / Minimap & Integration Guide", 640, 88)
    _ui.panel_box(640, 120, 580, 540, "hover")

    _ui.label("How to use Canvas as a Minimap / PIP:", 660, 138)

    _ui.label("1. Create off-screen render target:", 660, 175)
    _ui.label("   local map = _canvas.new(256, 256)", 660, 198, 12)

    _ui.label("2. Begin drawing and clear render target:", 660, 235)
    _ui.label("   map:begin(r, g, b, a)", 660, 258, 12)
    _ui.label("   -- render world / entities here --", 660, 278, 12)
    _ui.label("   map:finish()", 660, 298, 12)

    _ui.label("3. Render fit or stretched on HUD:", 660, 335)
    _ui.label("   map:draw_fit(x, y, w, h)", 660, 358, 12)

    _ui.label("4. Map mouse input back to world coords:", 660, 395)
    _ui.label("   local cx, cy = map:to_canvas(mx, my)", 660, 418, 12)
end

--- @section Lifecycle

function client.init()
    minimap_canvas = _canvas.new(256, 192)
    print("Modit Canvas test suite loaded")
end

function client.update(dt)
    dt = dt or 0.016
    rotation_angle = rotation_angle + dt * 1.5

    if minimap_canvas then
        local mx, my = _input.get_mouse_position()
        local cx, cy = minimap_canvas:to_canvas(mx, my)
        if cx then
            mapped_cx, mapped_cy = cx, cy
        end
    end
end

function client.draw()
    _draw.clear(_theme.bg_main)
    _ui.draw_header("MODIT.CANVAS API DEMO", "Off-Screen Render Targets | Minimap | PIP Integration")

    test_canvas_rendering(0.016)
    test_canvas_usage_info()

    _ui.draw_footer("Modit Engine | Canvas demo by Case")
end

function client.quit()
    if minimap_canvas then minimap_canvas:free() end
end

return client