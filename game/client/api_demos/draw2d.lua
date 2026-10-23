--[[
Draw2D API Examples
-------------------

Visual reference for the Modit Draw2D API, covering shape rendering, text,
colour handling, and clipping.

### Functions

-- Set the active drawing colour.
-- colour: RGBA table {r, g, b, a}, or separate r, g, b, a values.
modit.draw2d.set_colour(colour)

-- Clear the drawing target with the specified colour.
-- colour: RGBA colour table.
modit.draw2d.clear(colour)

-- Draw a line between two points.
-- x1, y1: Starting coordinates.
-- x2, y2: Ending coordinates.
modit.draw2d.line(x1, y1, x2, y2)

-- Draw a filled rectangle.
-- x, y: Top-left coordinates.
-- width, height: Rectangle dimensions.
modit.draw2d.rect(x, y, width, height)

-- Draw a rectangle outline.
-- x, y: Top-left coordinates.
-- width, height: Rectangle dimensions.
modit.draw2d.rect_lines(x, y, width, height)

-- Draw a rectangle outline with configurable thickness.
-- x, y, width, height: Rectangle bounds.
-- line_thickness: Outline thickness.
modit.draw2d.rect_lines_ex(x, y, width, height, line_thickness)

-- Draw a filled rounded rectangle.
-- x, y, width, height: Rectangle bounds.
-- roundness: Corner curvature.
-- segments: Number of segments used to render rounded corners.
modit.draw2d.rect_rounded(x, y, width, height, roundness, segments)

-- Draw a rounded rectangle outline.
-- x, y, width, height: Rectangle bounds.
-- roundness: Corner curvature.
-- segments: Number of segments used to render rounded corners.
-- line_thickness: Outline thickness.
modit.draw2d.rect_rounded_lines(x, y, width, height, roundness, segments, line_thickness)

-- Draw a filled circle.
-- center_x, center_y: Circle centre.
-- radius: Circle radius.
modit.draw2d.circle(center_x, center_y, radius)

-- Draw a circle outline.
-- center_x, center_y: Circle centre.
-- radius: Circle radius.
modit.draw2d.circle_lines(center_x, center_y, radius)

-- Draw a filled triangle.
-- x1, y1, x2, y2, x3, y3: Coordinates of the three vertices.
modit.draw2d.triangle(x1, y1, x2, y2, x3, y3)

-- Draw a triangle outline.
-- x1, y1, x2, y2, x3, y3: Coordinates of the three vertices.
modit.draw2d.triangle_lines(x1, y1, x2, y2, x3, y3)

-- Draw an ellipse.
-- center_x, center_y: Ellipse centre.
-- radius_x, radius_y: Horizontal and vertical radii.
modit.draw2d.ellipse(center_x, center_y, radius_x, radius_y)

-- Draw a regular polygon.
-- center_x, center_y: Polygon centre.
-- sides: Number of sides.
-- radius: Distance from the centre to each vertex.
-- rotation: Polygon rotation.
modit.draw2d.polygon(center_x, center_y, sides, radius, rotation)

-- Draw text at the specified position and size.
-- text: String to render.
-- x, y: Text position.
-- size: Font size.
modit.draw2d.text(text, x, y, size)

-- Measure text without rendering it.
-- text: String to measure.
-- size: Font size.
-- Returns: Text width and height.
modit.draw2d.measure_text(text, size)

-- Push a clipping region onto the clip stack.
-- x, y: Top-left coordinates.
-- width, height: Clip dimensions.
modit.draw2d.push_clip(x, y, width, height)

-- Get the active clipping region.
-- Returns: x, y, width, height.
modit.draw2d.get_clip()

-- Remove the current clipping region and restore the previous region.
modit.draw2d.pop_clip()

-- Clear clipping state.
modit.draw2d.reset_clip()
]]

--- @section Imports

--- UI Helpers shared by tests
--- @see client.ui_helpers
local _ui = require("client.ui_helpers")

--- @section Initialisation

local m = {}

--- Localizing global API references caches table lookups for improved performance
local _draw = modit.draw2d

local _theme = _ui.theme
local _demo = _ui.demo

--- @section Test Functions

local function test_lines()
    _ui.heading("01 / Lines", 30, 85)
    _ui.panel_box(30, 119, 280, 128, "normal")

    _ui.set_colour(_demo.white)
    _draw.line(50, 145, 290, 145)
    _ui.label("line() / white horizontal", 50, 151)

    _ui.set_colour(_demo.orange)
    _draw.line(50, 184, 290, 222)
    _ui.label("line() / orange diagonal", 50, 226)

    _ui.set_colour(_demo.purple)
    _draw.line(50, 237, 290, 239)
end

local function test_rectangles()
    _ui.heading("02 / Rectangles", 335, 85)
    _ui.panel_box(335, 119, 280, 128, "hover")

    _ui.set_colour(_demo.red)
    _draw.rect(353, 139, 65, 43)
    _ui.label("rect() / filled", 353, 187)

    _ui.set_colour(_demo.green)
    _draw.rect_lines(435, 139, 65, 43)
    _ui.label("rect_lines()", 435, 187)

    _ui.set_colour(_demo.yellow)
    _draw.rect_lines_ex(520, 139, 72, 43, 4)
    _ui.label("rect_lines_ex()", 510, 187)
end

local function test_rounded_rectangles()
    _ui.heading("03 / Rounded Rectangles", 640, 85)
    _ui.panel_box(640, 119, 285, 128, "input")

    _ui.set_colour(_demo.purple)
    _draw.rect_rounded(660, 139, 105, 43, 0.35, 8)
    _ui.label("Filled / rounded", 660, 187)

    _ui.set_colour(_demo.pink)
    _draw.rect_rounded_lines(785, 139, 120, 43, 0.35, 8, 3)
    _ui.label("Rounded outline", 785, 187)
end

local function test_circles()
    _ui.heading("04 / Circles", 950, 85)
    _ui.panel_box(950, 119, 300, 128, "normal")

    _ui.set_colour(_demo.cyan)
    _draw.circle(1025, 159, 27)
    _ui.label("circle() / filled", 990, 199)

    _ui.set_colour(_demo.orange)
    _draw.circle_lines(1160, 159, 27)
    _ui.label("circle_lines()", 1123, 199)
end

local function test_triangles()
    _ui.heading("05 / Triangles", 30, 270)
    _ui.panel_box(30, 304, 280, 148, "hover")

    _ui.set_colour(_demo.orange)
    _draw.triangle(55, 386, 88, 326, 121, 386)
    _ui.label("triangle()", 47, 400)

    _ui.set_colour(_demo.cyan)
    _draw.triangle_lines(175, 386, 208, 326, 241, 386)
    _ui.label("triangle_lines()", 163, 400)
end

local function test_ellipses_and_polygons()
    _ui.heading("06 / Ellipse & Polygon", 335, 270)
    _ui.panel_box(335, 304, 280, 148, "input")

    _ui.set_colour(_demo.green)
    _draw.ellipse(405, 357, 48, 27)
    _ui.label("ellipse()", 382, 393)

    _ui.set_colour(_demo.pink)
    _draw.polygon(535, 357, 6, 33, 0)
    _ui.label("polygon()", 493, 393)
end

local function test_text_and_measurement()
    _ui.heading("07 / Text & Measurement", 640, 270)
    _ui.panel_box(640, 304, 285, 148, "normal")

    local message = "measure_text()"
    local size = 22
    local width, height = _draw.measure_text(message, size)

    _ui.set_colour(_demo.white)
    _draw.text(message, 660, 334, size)

    _ui.set_colour(_demo.red)
    _draw.rect_lines(660, 334, width, height)

    _ui.label("Measured bounds", 660, 371)
    _ui.label("Width: " .. tostring(width), 660, 393)
    _ui.label("Height: " .. tostring(height), 660, 414)

    _ui.set_colour(_demo.yellow)
    _draw.text("Small text / 12", 790, 421, 12)
end

local function test_colours()
    _ui.heading("08 / Colours & Alpha", 950, 270)
    _ui.panel_box(950, 304, 300, 148, "input")

    _draw.set_colour({235, 75, 75, 255})
    _draw.rect(968, 331, 52, 38)
    _ui.label("Table", 968, 374)

    _draw.set_colour(75, 145, 245, 255)
    _draw.rect(1037, 331, 52, 38)
    _ui.label("Numeric", 1037, 374)

    _draw.set_colour(245, 210, 85, 128)
    _draw.rect(1106, 331, 52, 38)
    _ui.label("Alpha 128", 1106, 374)

    _ui.set_colour(_theme.bg_hover)
    _draw.rect(1175, 331, 52, 38)

    _draw.set_colour(105, 205, 125, 0)
    _draw.rect(1175, 331, 52, 38)
    _ui.label("Alpha 0", 1175, 374)
end

local function test_clipping()
    _ui.heading("09 / Scissor Clipping", 30, 485)
    _ui.panel_box(30, 519, 380, 157, "normal")

    _ui.set_colour(_demo.yellow)
    _draw.rect_lines(50, 538, 340, 79)

    _draw.push_clip(50, 538, 340, 79)

    _ui.set_colour(_demo.red)
    _draw.rect(35, 550, 155, 55)

    _ui.set_colour(_demo.blue)
    _draw.circle(190, 577, 40)

    _draw.push_clip(220, 553, 120, 48)

    _ui.set_colour(_demo.green)
    _draw.rect(205, 543, 155, 75)

    local x, y, w, h = _draw.get_clip()

    _draw.pop_clip()
    _draw.pop_clip()

    _ui.label(
        "Clip: " .. tostring(x) .. ", " .. tostring(y)
            .. "  " .. tostring(w) .. "x" .. tostring(h),
        50, 625
    )
    _ui.label("push_clip / get_clip / pop_clip", 50, 649)
end

local function test_clip_reset()
    _ui.heading("10 / Reset Clipping", 445, 485)
    _ui.panel_box(445, 519, 285, 157, "hover")

    _draw.push_clip(465, 538, 70, 45)

    _ui.set_colour(_demo.red)
    _draw.rect(465, 538, 70, 45)

    _draw.reset_clip()

    _ui.set_colour(_demo.cyan)
    _draw.rect(555, 538, 135, 45)

    _ui.set_colour(_theme.border_dashed)
    _draw.rect_lines(555, 538, 135, 45)

    _ui.label("reset_clip()", 555, 591)
    _ui.label("Cyan shape is unclipped", 465, 615)
    _ui.label("Dashed colour / grey outline", 465, 641)
end

local function test_borders_and_overlays()
    _ui.heading("11 / Border Styles", 765, 485)
    _ui.panel_box(765, 519, 485, 157, "input")

    _ui.set_colour(_theme.border_dark)
    _draw.rect_lines(783, 538, 92, 42)
    _ui.label("border_dark", 783, 585)

    _ui.set_colour(_theme.border_light)
    _draw.rect_lines(891, 538, 92, 42)
    _ui.label("border_light", 891, 585)

    _ui.set_colour(_theme.border_accent)
    _draw.rect_lines(999, 538, 92, 42)
    _ui.label("border_accent", 999, 585)

    _ui.set_colour(_theme.border_dashed)
    _draw.rect_lines(1107, 538, 92, 42)
    _ui.label("border_dashed", 1107, 585)

    _ui.set_colour(_demo.purple)
    _draw.rect(783, 612, 92, 28)

    _ui.set_colour(_theme.bg_overlay)
    _draw.rect(783, 612, 92, 28)

    _ui.label("Overlay alpha over purple", 891, 618)
end

--- @section Lifecycle

function m.init()
    print("Modit Draw2D test suite loaded")
end

function m.update(dt)
end

function m.draw()
    _draw.clear(_theme.bg_main)
    _ui.draw_header("MODIT.DRAW2D API DEMO", "Draw2D visual reference")

    test_lines()
    test_rectangles()
    test_rounded_rectangles()
    test_circles()

    test_triangles()
    test_ellipses_and_polygons()
    test_text_and_measurement()
    test_colours()

    test_clipping()
    test_clip_reset()
    test_borders_and_overlays()

    _ui.draw_footer("Modit Engine | Draw2D demo by Case")
end

function m.quit()
end

return m