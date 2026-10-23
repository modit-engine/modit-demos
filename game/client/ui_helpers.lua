--- @file client/ui_helpers.lua
--- @description Collection of UI helpers for demo suites.


local _draw = modit.draw2d
local m = {}

--- @section Theme

m.theme = {
    bg_main = {22, 22, 22, 255},
    bg_panel = {31, 30, 30, 255},
    bg_hover = {50, 48, 48, 255},
    bg_overlay = {0, 0, 0, 127},
    bg_input = {17, 17, 17, 255},

    text_primary = {245, 245, 245, 255},
    text_secondary = {180, 180, 180, 255},
    text_tertiary = {102, 102, 102, 255},

    accent = {77, 203, 194, 255},
    accent2 = {49, 145, 138, 255},
    accent3 = {181, 50, 50, 255},
    accent4 = {102, 102, 102, 255},

    green = {105, 205, 125, 255},
    red = {235, 75, 75, 255},
    orange = {245, 155, 65, 255},

    border_dark = {0, 0, 0, 127},
    border_light = {255, 255, 255, 25},
    border_accent = {77, 203, 194, 255},
    border_dashed = {102, 102, 102, 255},
    border_transparent = {0, 0, 0, 0},

    scrollbar_track = {255, 255, 255, 64},
    scrollbar_thumb = {77, 203, 194, 204},
}

--- @section Test Colours

m.demo = {
    red = {235, 75, 75, 255},
    orange = {245, 155, 65, 255},
    yellow = {245, 210, 85, 255},
    green = {105, 205, 125, 255},
    cyan = {75, 205, 220, 255},
    blue = {90, 145, 245, 255},
    purple = {180, 115, 235, 255},
    pink = {240, 125, 185, 255},
    white = {245, 245, 245, 255},
    grey = {140, 145, 155, 255},
}

--- @section Shared Helpers

function m.set_colour(colour)
    _draw.set_colour(colour)
end

function m.heading(text, x, y, size)
    m.set_colour(m.theme.accent)
    _draw.text(text, x, y, size or 18)
end

function m.label(text, x, y, size)
    m.set_colour(m.theme.text_secondary)
    _draw.text(text, x, y, size or 13)
end

function m.value(text, x, y)
    m.set_colour(m.theme.text_primary)
    _draw.text(tostring(text), x, y, 14)
end

function m.status(text, active, x, y)
    if active then
        m.set_colour(m.theme.green)
    else
        m.set_colour(m.theme.text_tertiary)
    end
    _draw.text(text, x, y, 13)
end

function m.panel_box(x, y, w, h, variant)
    variant = variant or "normal"

    if variant == "input" then
        m.set_colour(m.theme.bg_input)
    elseif variant == "hover" then
        m.set_colour(m.theme.bg_hover)
    else
        m.set_colour(m.theme.bg_panel)
    end

    _draw.rect(x, y, w, h)

    if variant == "accent" then
        m.set_colour(m.theme.border_accent)
    elseif variant == "subtle" then
        m.set_colour(m.theme.border_dark)
    else
        m.set_colour(m.theme.border_light)
    end

    _draw.rect_lines(x, y, w, h)
end

function m.button_box(text, x, y, w, h)
    m.set_colour(m.theme.bg_hover)
    _draw.rect(x, y, w, h)

    m.set_colour(m.theme.border_light)
    _draw.rect_lines(x, y, w, h)

    m.set_colour(m.theme.text_primary)
    _draw.text(text, x + 10, y + 8, 13)
end

function m.swatch(name, colour, x, y, w, h)
    m.set_colour(colour)
    _draw.rect(x, y, w, h)

    m.set_colour(m.theme.border_light)
    _draw.rect_lines(x, y, w, h)

    m.label(name, x, y + h + 5)
end

function m.draw_header(title, subtitle)
    m.set_colour(m.theme.text_primary)
    _draw.text(title, 30, 22, 25)

    m.set_colour(m.theme.text_secondary)
    _draw.text(subtitle, 30, 51, 14)

    m.set_colour(m.theme.border_accent)
    _draw.rect(30, 72, 1220, 2)
end

function m.draw_footer(footer_text)
    m.set_colour(m.theme.border_light)
    _draw.line(30, 690, 1250, 690)

    m.set_colour(m.theme.text_tertiary)
    _draw.text(footer_text, 30, 698, 13)
end

return m