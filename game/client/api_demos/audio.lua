--[[
Modit Audio API Examples
------------------------

Visual reference for loading sound effects and music tracks, playing audio,
adjusting volume and pitch, global music controls, and memory cleanup.

### Functions

-- Load a sound effect from file.
-- path: File path to audio file.
modit.audio.load_sound(path)

-- Load a music track from file.
-- path: File path to audio file.
modit.audio.load_music(path)

-- Play sound effect handle.
sound:play()

-- Set sound effect volume (0.0 to 1.0).
sound:set_volume(volume)

-- Set sound effect pitch (1.0 is normal).
sound:set_pitch(pitch)

-- Unload sound effect from memory.
sound:unload()

-- Play music track with optional loop flag.
-- loop: boolean
music:play(loop)

-- Set music track volume (0.0 to 1.0).
music:set_volume(volume)

-- Set music track pitch (1.0 is normal).
music:set_pitch(pitch)

-- Unload music track from memory.
music:unload()

-- Stop currently playing music.
modit.audio.stop_music()

-- Pause currently playing music.
modit.audio.pause_music()

-- Resume paused music.
modit.audio.resume_music()

-- Check if music stream is currently playing.
modit.audio.is_music_playing()

-- Unload every sound and track.
modit.audio.cleanup()
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
local _audio = modit.audio

local _theme = _ui.theme
local _demo = _ui.demo

--- @section State

local sfx_headshot = nil
local sfx_slick = nil
local mus_drums = nil

local headshot_volume = 1.0
local slick_volume = 1.0
local music_volume = 1.0
local is_playing_music = false

--- @section Test Functions

local function test_sound_effects()
    _ui.heading("01 / Sound Effects (SFX)", 30, 88)
    _ui.panel_box(30, 120, 580, 240, "normal")

    _ui.label("headshot.ogg & slick.ogg controls", 50, 138)

    _ui.status("SFX 1 Loaded", sfx_headshot ~= nil, 50, 170)
    _ui.status("SFX 2 Loaded", sfx_slick ~= nil, 310, 170)

    _ui.button_box("Play Headshot", 50, 210, 130, 32)
    _ui.button_box("Play Slick", 190, 210, 110, 32)
    _ui.button_box(sfx_headshot and "Unload SFX" or "Load SFX", 310, 210, 130, 32)

    _ui.label("Headshot Vol:", 50, 265)
    _ui.value(string.format("%.2f", headshot_volume), 160, 265)

    _ui.label("Slick Vol:", 310, 265)
    _ui.value(string.format("%.2f", slick_volume), 400, 265)

    if _input.mouse_pressed(0) then
        if _input.mouse_in_rect(50, 210, 130, 32) and sfx_headshot then
            sfx_headshot:play()
        elseif _input.mouse_in_rect(190, 210, 110, 32) and sfx_slick then
            sfx_slick:play()
        elseif _input.mouse_in_rect(310, 210, 130, 32) then
            if sfx_headshot then
                sfx_headshot:unload()
                sfx_slick:unload()
                sfx_headshot, sfx_slick = nil, nil
            else
                sfx_headshot = _audio.load_sound("game/assets/audio/headshot.ogg")
                sfx_slick = _audio.load_sound("game/assets/audio/slick.ogg")
            end
        end
    end
end

local function test_music_tracks()
    _ui.heading("02 / Music Streaming (Horde Drums)", 640, 88)
    _ui.panel_box(640, 120, 580, 240, "hover")

    _ui.label("horde_drums.ogg controls", 660, 138)

    _ui.status("Music Loaded", mus_drums ~= nil, 660, 170)
    _ui.status("Playing", is_playing_music, 800, 170)

    _ui.button_box("Play Music", 660, 210, 100, 32)
    _ui.button_box("Pause", 770, 210, 80, 32)
    _ui.button_box("Resume", 860, 210, 90, 32)
    _ui.button_box("Stop", 960, 210, 70, 32)
    _ui.button_box(mus_drums and "Unload" or "Load", 1040, 210, 140, 32)

    _ui.label("Music Volume:", 660, 265)
    _ui.value(string.format("%.2f", music_volume), 780, 265)

    if _input.mouse_pressed(0) then
        if _input.mouse_in_rect(660, 210, 100, 32) and mus_drums then
            mus_drums:play(true)
        elseif _input.mouse_in_rect(770, 210, 80, 32) then
            _audio.pause_music()
        elseif _input.mouse_in_rect(860, 210, 90, 32) then
            _audio.resume_music()
        elseif _input.mouse_in_rect(960, 210, 70, 32) then
            _audio.stop_music()
        elseif _input.mouse_in_rect(1040, 210, 140, 32) then
            if mus_drums then
                mus_drums:unload()
                mus_drums = nil
            else
                mus_drums = _audio.load_music("game/assets/audio/horde_drums.ogg")
            end
        end
    end
end

local function test_audio_lifecycle()
    _ui.heading("03 / Cleanup & Global State", 30, 380)
    _ui.panel_box(30, 412, 1190, 140, "normal")

    _ui.label("audio.cleanup() / Global Management", 50, 430)
    _ui.label("Unloads all active sounds and music tracks globally from memory.", 50, 456, 12)

    _ui.button_box("Cleanup All Audio", 50, 495, 180, 32)

    if _input and _input.mouse_pressed(0) then
        if _input.mouse_in_rect(50, 495, 180, 32) then
            _audio.cleanup()
            sfx_headshot = nil
            sfx_slick = nil
            mus_drums = nil
            headshot_volume = 1.0
            slick_volume = 1.0
            music_volume = 1.0
        end
    end
end

--- @section Lifecycle

function client.init()
    -- Load sound effects and music tracks
    sfx_headshot = _audio.load_sound("game/assets/audio/headshot.ogg")
    sfx_slick = _audio.load_sound("game/assets/audio/slick.ogg")
    mus_drums = _audio.load_music("game/assets/audio/horde_drums.ogg")

    print("Modit Audio test suite loaded")
end

function client.update(dt)
    is_playing_music = _audio.is_music_playing()
end

function client.draw()
    _draw.clear(_theme.bg_main)
    _ui.draw_header("MODIT.AUDIO API DEMO", "Sound Effects | Music Streams | Volume | Cleanup")

    test_sound_effects()
    test_music_tracks()
    test_audio_lifecycle()

    _ui.draw_footer("Modit Engine | Audio demo by Case")
end

function client.quit()
    if sfx_headshot then sfx_headshot:unload() end
    if sfx_slick then sfx_slick:unload() end
    if mus_drums then mus_drums:unload() end
    _audio.cleanup()
end

return client