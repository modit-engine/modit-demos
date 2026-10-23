--- @file client/init.lua
--- @description Demo entry point.
--- Replace `active` for one of the other demos and run/reload client (saving auto reloads if demo is open)

--- @section Initilisation

local client = {}

local demos = {
    audio = require("client.api_demos.audio"),
    canvas = require("client.api_demos.canvas"),
    draw2d = require("client.api_demos.draw2d"),
    draw3d = require("client.api_demos.draw3d"),
    environment = require("client.api_demos.environment"),
    font = require("client.api_demos.font"),
    image = require("client.api_demos.image"),
    input = require("client.api_demos.input")
}

local active = "audio" --- Update this to the demo[key] above to test different demos
local demo = demos[active]

--- @section Lifecycle

function client.init()
    if demo and demo.init then demo.init() end
end

function client.update(dt)
    if demo and demo.update then demo.update(dt) end
end

function client.draw()
    if demo and demo.draw then demo.draw() end
end

function client.quit()
    if demo and demo.quit then demo.quit() end
end

return client