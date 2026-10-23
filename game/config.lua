return {

    -- Window & Display Settings
    window = {
        title = "Modit Demos",
        icon = "game/assets/modit_icon.png",
        size = {
            width = 1280,
            height = 720,
        },
        console = false,
        flags = {
            vsync_hint = true,
            fullscreen_mode = false,
            resizable = true,
            undecorated = false,
            transparent = false,
            hidden = false,
            minimized = false,
            maximized = false,
            unfocused = false,
            topmost = false,
            always_run = false,
            highdpi = false,
            mouse_passthrough = false,
            borderless_windowed_mode = false,
            msaa_4x_hint = true,
            interlaced_hint = false,
        },
        fps = {
            draw = false,
            target = 144,
        }
    },

    -- Engine Modules (Opt-out)
    modules = {
        -- Client Subsystems
        audio = true,
        camera = true,
        canvas = true,
        draw2d = true,
        draw3d = true,
        environment = true,
        font = true,
        image = true,
        input = true,
        model = true, -- @todo full model demo: is only enabled for shadow maps in environment demo

        -- Shared Utilities
        command = false,
        filesystem = false,
        hook = false,
        mat4 = false,
        math = false,
        mods = false,
        network = false,
        physics = false,
        runtime = false,
        string = false,
        table = false,
        timestamp = false,
        vector = false,
        server_console = false,

        -- UI Framework
        ui = false
    },

    -- Modding Support
    modding = {
        enabled = false,
        blacklisted_modules = {}, -- e.g. { "environment" }
    },

    -- Headless Server Support
    server = {
        enabled = false,
        tick_rate = 30,
        port = 7777
    },

    -- Build / Packaging Settings
    build = {
        icons = {
            windows = {
                client_exe = nil,
                server_exe = nil,
            }
        },
        
        engine_assets = {
            fonts = false
        },
        
        external_saves = {
            enabled = false,
            directory = "saves",
            files = {},
        },
    }
}
