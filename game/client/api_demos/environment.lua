--[[
Modit Environment API Examples
------------------------------

Visual reference for scene environment controls: lighting, sun settings, shadows
(blob, projected, map), sky gradients, post-processing, and water animation.

### Caveats & Technical Notes
- **Shadow Maps ("map")**: Require `modit.model` meshes (`_model.draw`) for both casters and receiving surfaces (like the ground) because they hook into `MESH_FRAGMENT` to sample the depth texture. `_draw3d` primitives bypass this shader and cannot receive shadow maps.
- **Projected Shadows ("projected")**: Flatten casters along the sun vector onto a ground plane using `_env.shadow_pass(draw_casters, ground_y)`.
- **Blob Shadows ("blob")**: Render screen-space / geometric disc shadows using `_env.draw_blob_shadow(x, y, z, radius)`.

### Functions

-- Set sun direction and colour.
modit.environment.set_sun(dx, dy, dz, r, g, b)

-- Set ambient light colour.
modit.environment.set_ambient(r, g, b)

-- Set distance fog parameters.
modit.environment.set_fog(near, far, r, g, b)

-- Set shadow mode ("off", "blob", "projected", "map"), strength, and range.
modit.environment.set_shadows(mode, strength, range)

-- Set sky colors (top and horizon RGB).
modit.environment.set_sky(tr, tg, tb, hr, hg, hb)

-- Enable or disable post-processing settings.
modit.environment.enable_postfx(opts)
modit.environment.disable_postfx()

-- Set up and control water surface settings.
modit.environment.set_water(opts)
modit.environment.set_water_enabled(flag)
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
local _env = modit.environment
local _model = modit.model

local _theme = _ui.theme

--- @section State

local cam = nil
local rot_angle = 0.0
local cam_distance = 14.0
local cam_height = 6.0

local lighting_enabled = true
local sky_enabled = true
local water_enabled_flag = true
local grid_enabled_flag = true
local postfx_enabled_flag = false

local shadow_modes_list = { "off", "blob", "projected", "map" }
local shadow_mode_index = 1
local current_shadow_mode = "off"
local shadow_strength_val = 0.6

local CUBE_MODEL = { key = "cube", x = 0, y = 0, z = 0, scale = { x = 2, y = 2, z = 2 }, tint = { 235, 75, 75, 255 } }
local SPHERE_L = { key = "throw_sphere", x = -4.5, y = 1.0, z = 0, scale = { x = 0.8, y = 0.8, z = 0.8 }, tint = { 75, 145, 245, 255 } }
local SPHERE_R = { key = "throw_sphere", x = 4.5, y = 1.0, z = 0, scale = { x = 0.8, y = 0.8, z = 0.8 }, tint = { 245, 210, 85, 255 } }
local GROUND_MODEL = { key = "ground_plane", x = 0, y = -1.2, z = 0, scale = { x = 18.0, y = 0.05, z = 18.0 }, tint = { 40, 45, 55, 255 } }

--- @section Test Functions

local function draw_casters()
    CUBE_MODEL.x, CUBE_MODEL.y, CUBE_MODEL.z = 0, 1.0, 0
    _model.draw(CUBE_MODEL)
    _model.draw(SPHERE_L)
    _model.draw(SPHERE_R)
end

local function draw_scene_3d()
    _model.draw(GROUND_MODEL)

    if grid_enabled_flag then
        _draw3d.set_colour(70, 80, 100, 255)
        _draw3d.grid(20, 1.0)
    end

    if current_shadow_mode == "projected" then
        _env.shadow_pass(draw_casters, -1.2)
    end
    
    draw_casters()

    _draw3d.set_colour(255, 255, 255, 255)
    _draw3d.cube_wires(0, 1.0, 0, 2.1, 2.1, 2.1)

    if current_shadow_mode == "blob" then
        _env.draw_blob_shadow(-4.5, 0.0, 0, 0.8)
        _env.draw_blob_shadow(4.5, 0.0, 0, 0.8)
    end

    if water_enabled_flag then
        _env.draw_water()
    end
end

local function draw_hud_overlay()
    _ui.panel_box(30, 90, 304, 200, "normal")

    _ui.label("Environment Controls & Lighting Setup", 42, 103, 11)
    
    _ui.button_box(lighting_enabled and "Lighting: ON" or "Lighting: OFF", 42, 125, 137, 26)
    _ui.button_box(sky_enabled and "Sky: ON" or "Sky: OFF", 185, 125, 137, 26)

    _ui.button_box(water_enabled_flag and "Water: ON" or "Water: OFF", 42, 159, 137, 26)
    _ui.button_box(grid_enabled_flag and "Grid: ON" or "Grid: OFF", 185, 159, 137, 26)

    _ui.button_box(postfx_enabled_flag and "PostFX: ON" or "PostFX: OFF", 42, 193, 137, 26)

    _ui.button_box("Shadows: " .. string.upper(current_shadow_mode), 42, 227, 280, 26)

    _ui.label("A/D: Rotate | W/S: Zoom camera", 42, 267, 11)

    if _input.mouse_pressed(0) then
        if _input.mouse_in_rect(42, 125, 137, 26) then
            lighting_enabled = not lighting_enabled
            if not lighting_enabled then
                _env.reset_lighting()
            end
        elseif _input.mouse_in_rect(185, 125, 137, 26) then
            sky_enabled = not sky_enabled
            if sky_enabled then
                _env.reset_sky()
            else
                _env.set_sky(15, 15, 20, 15, 15, 20)
            end
        elseif _input.mouse_in_rect(42, 159, 137, 26) then
            water_enabled_flag = not water_enabled_flag
            _env.set_water_enabled(water_enabled_flag)
        elseif _input.mouse_in_rect(185, 159, 137, 26) then
            grid_enabled_flag = not grid_enabled_flag
        elseif _input.mouse_in_rect(42, 193, 137, 26) then
            postfx_enabled_flag = not postfx_enabled_flag
            if postfx_enabled_flag then
                _env.enable_postfx({ pixel_size = 2, colour_levels = 32 })
            else
                _env.disable_postfx()
            end
        elseif _input.mouse_in_rect(42, 227, 280, 26) then
            shadow_mode_index = (shadow_mode_index % #shadow_modes_list) + 1
            current_shadow_mode = shadow_modes_list[shadow_mode_index]
            _env.set_shadows(current_shadow_mode, shadow_strength_val, 40)
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

    local FACES = {
        { { 1, 0, 0 }, { 0, 0, -1 }, { 0, 1, 0 } },
        { { -1, 0, 0 }, { 0, 0, 1 }, { 0, 1, 0 } },
        { { 0, 1, 0 }, { 1, 0, 0 }, { 0, 0, -1 } },
        { { 0, -1, 0 }, { 1, 0, 0 }, { 0, 0, 1 } },
        { { 0, 0, 1 }, { 1, 0, 0 }, { 0, 1, 0 } },
        { { 0, 0, -1 }, { -1, 0, 0 }, { 0, 1, 0 } },
    }
    local CORNERS = { { -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 } }
    local TRIANGLE_CORNERS = { 1, 2, 3, 1, 3, 4 }
    local cube_vertices = {}
    for _, face in ipairs(FACES) do
        local n, u, v = face[1], face[2], face[3]
        for _, ci in ipairs(TRIANGLE_CORNERS) do
            local corner = CORNERS[ci]
            for comp = 1, 3 do
                cube_vertices[#cube_vertices + 1] = (n[comp] + u[comp] * corner[1] + v[comp] * corner[2]) * 0.5
            end
        end
    end
    _model.build({ key = "cube", vertices = cube_vertices })
    _model.build({ key = "ground_plane", vertices = cube_vertices })

    local sphere_vertices = {}
    local rings, segments, radius = 10, 16, 0.5
    local function point(ring, segment)
        local phi = math.pi * ring / rings
        local theta = 2 * math.pi * segment / segments
        return { radius * math.sin(phi) * math.cos(theta), radius * math.cos(phi), radius * math.sin(phi) * math.sin(theta) }
    end
    local function add_triangle(a, b, c)
        for _, p in ipairs({ a, b, c }) do
            table.insert(sphere_vertices, p[1]); table.insert(sphere_vertices, p[2]); table.insert(sphere_vertices, p[3])
        end
    end
    for ring = 0, rings - 1 do
        for segment = 0, segments - 1 do
            local p00, p01 = point(ring, segment), point(ring, segment + 1)
            local p10, p11 = point(ring + 1, segment), point(ring + 1, segment + 1)
            if ring > 0 then add_triangle(p00, p10, p01) end
            if ring < rings - 1 then add_triangle(p01, p10, p11) end
        end
    end
    _model.build({ key = "throw_sphere", vertices = sphere_vertices })

    _env.set_sun(-0.4, -1, -0.3, 255, 242, 215)
    _env.set_ambient(100, 105, 125)
    _env.set_fog(40, 180)
    _env.set_sky(70, 120, 210, 190, 215, 240)
    _env.set_water({
        x = 0, y = 0.0, z = 0,
        size = 30,
        cell = 1.5,
        colour = { 30, 95, 150 },
        opacity = 0.7,
        amplitude = 0.15,
        frequency = 0.5,
        speed = 1.0
    })
    _env.set_water_enabled(true)
    _env.set_shadows("off", shadow_strength_val, 40)

    print("Modit Environment test suite loaded")
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
    
    if current_shadow_mode == "map" then
        _env.shadow_map_pass(cam, draw_casters)
    end

    _env.begin_scene(30, 35, 45)

    if sky_enabled then
        local width, height = _env.get_scene_size()
        _env.draw_sky(cam, width, height)
    end

    cam:begin_3d()
    if lighting_enabled then
        _env.begin_lighting(cam)
    end

    draw_scene_3d()

    if lighting_enabled then
        _env.finish_lighting()
    end
    cam:end_3d()

    _env.end_scene()

    cam:begin_2d()
    draw_hud_overlay()
    cam:end_2d()

    _ui.draw_header("MODIT.ENVIRONMENT API DEMO", "Lighting | Shadows (Blob, Projected, Map) | Sky | Water | PostFX")
    _ui.draw_footer("Modit Engine | Environment demo by Case")
end

function client.quit()
    _env.reset_lighting()
    _env.reset_sky()
    _env.reset_water()
    _env.reset_postfx()
end

return client