--[[
Modit Draw3D API Examples
-------------------------

Visual reference for 3D camera setup, rendering 3D primitives (cubes, spheres,
planes, lines, grids), color handling, and mixing 3D viewports with 2D HUD overlays.

### Functions

-- Create a new camera instance.
-- cfg: Optional configuration table `{ x, y, z, target_x, target_y, target_z, fov }`.
modit.camera.new(cfg)

-- Begin and end 3D rendering blocks.
camera:begin_3d()
camera:end_3d()

-- Begin and end 2D rendering blocks for HUD overlays.
camera:begin_2d()
camera:end_2d()

-- Set camera position and look-at target.
camera:set_position(x, y, z)
camera:set_target(x, y, z)

-- Draw 3D ground grid.
-- slices, spacing: Grid density and scale.
modit.draw3d.grid(slices, spacing)

-- Draw a 3D line between two points.
-- x1, y1, z1, x2, y2, z2: Start and end coordinates.
modit.draw3d.line(x1, y1, z1, x2, y2, z2)

-- Draw a filled 3D cube.
-- x, y, z, w, h, l: Center position and dimensions.
modit.draw3d.cube(x, y, z, w, h, l)

-- Draw a wireframe 3D cube.
-- x, y, z, w, h, l: Center position and dimensions.
modit.draw3d.cube_wires(x, y, z, w, h, l)

-- Draw a flat 3D plane.
-- x, y, z, w, l: Center position and size along X and Z axes.
modit.draw3d.plane(x, y, z, w, l)

-- Draw a filled 3D sphere.
-- x, y, z, radius: Center and radius.
modit.draw3d.sphere(x, y, z, radius)

-- Draw a wireframe 3D sphere.
-- x, y, z, radius, rings, slices: Center, radius, and tessellation details.
modit.draw3d.sphere_wires(x, y, z, radius, rings, slices)

-- Set active 3D draw color (RGBA numbers or color table).
modit.draw3d.set_colour(r, g, b, a)
]]

--- @section Imports

--- UI Helpers shared by tests
--- @see client.ui_helpers
local _ui = require("client.ui_helpers")

--- @section Initialisation

local client = {}

--- Localizing global API references caches table lookups for improved performance
local _draw2d = modit.draw2d
local _draw3d = modit.draw3d
local _camera = modit.camera
local _input = modit.input

local _theme = _ui.theme

--- @section State

local cam = nil
local rot_angle = 0.0
local cam_distance = 12.0
local cam_height = 5.0

-- Interactive toggles
local show_cubes = true
local show_spheres = true
local show_wires = true
local show_plane = true

--- @section Test Functions

local function draw_scene_3d()
    if show_plane then
        _draw3d.set_colour(45, 52, 64, 255)
        _draw3d.plane(0, -0.05, 0, 16.0, 16.0)
    end

    _draw3d.set_colour(70, 80, 100, 255)
    _draw3d.grid(20, 1.0)

    if show_cubes then
        _draw3d.set_colour(235, 75, 75, 255)
        _draw3d.cube(0, 1.2, 0, 2.4, 2.4, 2.4)
    end
    if show_wires then
        _draw3d.set_colour(255, 255, 255, 255)
        _draw3d.cube_wires(0, 1.2, 0, 2.5, 2.5, 2.5)
    end

    if show_spheres then
        _draw3d.set_colour(75, 145, 245, 255)
        _draw3d.sphere(-4.0, 1.5, 0, 0.9)

        _draw3d.set_colour(245, 210, 85, 255)
        _draw3d.sphere(4.0, 1.5, 0, 0.9)
    end

    local corners = { { -5, -5 }, { 5, -5 }, { -5, 5 }, { 5, 5 } }
    for _, pos in ipairs(corners) do
        _draw3d.set_colour(105, 205, 125, 255)
        _draw3d.cube_wires(pos[1], 1.5, pos[2], 1.2, 3.5, 1.2)
        _draw3d.sphere_wires(pos[1], 3.6, pos[2], 0.6, 12, 12)
    end

    _draw3d.set_colour(235, 120, 50, 255)
    _draw3d.line(0, 0.1, 0, 0, 4.0, 0)
end

local function draw_hud_overlay()
    _ui.panel_box(30, 115, 340, 135, "normal")

    _ui.label("A/D: Rotate | W/S: Zoom", 42, 128, 11)

    _ui.button_box("Cubes", 42, 150, 95, 26)
    _ui.button_box("Spheres", 145, 150, 95, 26)
    _ui.button_box("Wires", 248, 150, 105, 26)

    _ui.status("C", show_cubes, 42, 185)
    _ui.status("S", show_spheres, 145, 185)
    _ui.status("W", show_wires, 248, 185)

    _ui.label("Dist:", 42, 212, 11)
    _ui.value(string.format("%.1f", cam_distance), 75, 212)
    _ui.label("Ang:", 145, 212, 11)
    _ui.value(string.format("%.2f", rot_angle), 178, 212)

    if _input.mouse_pressed(0) then
        if _input.mouse_in_rect(42, 150, 95, 26) then
            show_cubes = not show_cubes
        elseif _input.mouse_in_rect(145, 150, 95, 26) then
            show_spheres = not show_spheres
        elseif _input.mouse_in_rect(248, 150, 105, 26) then
            show_wires = not show_wires
        end
    end
end

--- @section Lifecycle

function client.init()
    cam = _camera.new({
        x = 0, y = cam_height, z = cam_distance,
        target_x = 0, target_y = 1, target_z = 0,
        fov = 45
    })

    print("Modit Draw3D test suite loaded")
end

function client.update(dt)
    dt = dt or 0.016

    if _input.key_down("a") or _input.key_down("arrowleft") then
        rot_angle = rot_angle - 1.5 * dt
    elseif _input.key_down("d") or _input.key_down("arrowright") then
        rot_angle = rot_angle + 1.5 * dt
    end

    if _input.key_down("w") or _input.key_down("arrowup") then
        cam_distance = math.max(4.0, cam_distance - 6.0 * dt)
    elseif _input.key_down("s") or _input.key_down("arrowdown") then
        cam_distance = math.min(25.0, cam_distance + 6.0 * dt)
    end

    local cx = math.cos(rot_angle) * cam_distance
    local cz = math.sin(rot_angle) * cam_distance
    cam:set_position(cx, cam_height, cz)
end

function client.draw()
    _draw2d.clear(_theme.bg_main)
    _ui.draw_header("MODIT.DRAW3D API DEMO", "3D Primitives | Camera Passes | Ground Grids")

    cam:begin_3d()
    draw_scene_3d()
    cam:end_3d()

    cam:begin_2d()
    draw_hud_overlay()
    cam:end_2d()

    _ui.draw_footer("Modit Engine | Draw3D demo by Case")
end

function client.quit()
end

return client