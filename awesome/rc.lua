-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local battery = require("power_widget")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

naughty.config.defaults['icon_size'] = 100

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
--beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/custom/theme.lua")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/purple/theme.lua")
--beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/custom/custom_theme.lua")
--beautiful.init(gears.filesystem.get_themes_dir() .. "xresources/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating,
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- Autostart commands
awful.spawn('nm-applet')
awful.spawn('autorandr --change')

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    {
        "hotkeys", function()
        hotkeys_popup.show_help(nil, awful.screen.focused())
    end
    },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    {
        "quit", function()
        awesome.quit()
    end
    },
}

mymainmenu = awful.menu({
    items = {
        { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "open terminal", terminal }
    }
})

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

--power.warning_config = {
--  percentage = 10,
--  message = "The battery is getting low",
--  preset = {
--    shape = gears.shape.rounded_rect,
--    timeout = 12,
--    bg = "#FFFF00",
--    fg = "#000000",
--  },
--}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()
awful.key({ "Mod1" }, "space", function()
    mykeyboardlayout.next_layout();
end)

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

mybattery = battery.get_widget(wibox, "BAT1")

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(awful.button({}, 1, function(t)
    t:view_only()
end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t)
        awful.tag.viewnext(t.screen)
    end),
    awful.button({}, 5, function(t)
        awful.tag.viewprev(t.screen)
    end))

local tasklist_buttons = gears.table.join(awful.button({}, 1, function(c)
    if c == client.focus then
        c.minimized = true
    else
        c:emit_signal("request::activate",
            "tasklist",
            { raise = true })
    end
end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

layouts = awful.layout.layouts
my_tags = {
    tags = {
        {
            names = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" },
            layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] },
        },
        {
            names = { "11", "12", "13", "14", "15", "16", "17", "18", "19", "20" },
            layout = { layouts[3], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] },
        }
    }
}

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    local screen_index = s.index
    awful.tag(my_tags.tags[screen_index].names, s, my_tags.tags[screen_index].layout)

    -- Create a promptbox for each screen
    --s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(awful.button({}, 1,
        function()
            awful.layout.inc(1)
        end),
        awful.button({}, 3, function()
            awful.layout.inc(-1)
        end),
        awful.button({}, 4, function()
            awful.layout.inc(1)
        end),
        awful.button({}, 5, function()
            awful.layout.inc(-1)
        end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen = s,
        --        filter = awful.widget.taglist.filter.all,
        filter = function(t) return t.selected or #t:clients() > 0 end,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            -- Left widgets
            layout = wibox.layout.fixed.horizontal,
	    -- mylauncher,
            s.mytaglist,
        },
        s.mytasklist, -- Middle widget
        {
            -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mybattery,
	    mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3, function()
    mymainmenu:toggle()
end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(awful.key({ modkey, }, "s", hotkeys_popup.show_help,
    { description = "show help", group = "awesome" }),
    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),

    awful.key({ modkey, }, "j",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }),
    awful.key({ modkey, }, "k",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }),
    awful.key({ modkey, }, "w", function()
        mymainmenu:show()
    end,
        { description = "show main menu", group = "awesome" }),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function()
        awful.client.swap.byidx(1)
    end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function()
        awful.client.swap.byidx(-1)
    end,
        { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function()
        awful.screen.focus_relative(1)
    end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function()
        awful.screen.focus_relative(-1)
    end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ modkey, }, "Return", function()
        awful.spawn(terminal)
    end,
        { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "e", awesome.quit,
        { description = "quit awesome", group = "awesome" }),


    awful.key({ modkey, }, "l", function()
        awful.tag.incmwfact(0.05)
    end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey, }, "h", function()
        awful.tag.incmwfact(-0.05)
    end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift" }, "h", function()
        awful.tag.incnmaster(1, nil, true)
    end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "l", function()
        awful.tag.incnmaster(-1, nil, true)
    end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h", function()
        awful.tag.incncol(1, nil, true)
    end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l", function()
        awful.tag.incncol(-1, nil, true)
    end,
        { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey, }, "space", function()
        awful.layout.inc(1)
    end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function()
        awful.layout.inc(-1)
    end,
        { description = "select previous", group = "layout" }),

    awful.key({ modkey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal("request::activate", "key.unminimize", { raise = true })
            end
        end,
        { description = "restore minimized", group = "client" }),

    --
    awful.key({ modkey }, "d", function()
        awful.spawn("rofi -show drun")
    end,
        { description = "run rofi", group = "launcher" }),

    awful.key({ modkey }, "x",
        function()
            awful.prompt.run {
                prompt = "Run Lua code: ",
                textbox = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        { description = "lua execute prompt", group = "awesome" }),

    awful.key({ modkey}, "c", awful.placement.centered),

    -- Menubar
    awful.key({ modkey }, "p", function()
        menubar.show()
    end,
        { description = "show the menubar", group = "launcher" }),

    -- Lock screen
    awful.key({ modkey, "Control" }, "l", function()
        -- awful.spawn("gdmflexiserver")
        awful.spawn("xscreensaver-command --lock")
    end,
        { description = "Lock the screen", group = "screen" }))

clientkeys = gears.table.join(awful.key({ modkey, }, "f",
    function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end,
    { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Shift" }, "c", function(c)
        c:kill()
    end,
        { description = "close", group = "client" }),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function(c)
        c:swap(awful.client.getmaster())
    end,
        { description = "move to master", group = "client" }),
    awful.key({ modkey, }, "o", function(c)
        c:move_to_screen()
    end,
        { description = "move to screen", group = "client" }),
    awful.key({ modkey, }, "t", function(c)
        c.ontop = not c.ontop
    end,
        { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey, }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "(un)maximize", group = "client" }),
    awful.key({ modkey, "Control" }, "m",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        { description = "(un)maximize vertically", group = "client" }),
    awful.key({ modkey, "Shift" }, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        { description = "(un)maximize horizontally", group = "client" }))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.

for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        --View tag only.
        awful.key({ modkey }, "" .. i,
            function()
                local tag = awful.tag.find_by_name(nil, tostring(i))
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "" .. i,
            function()
                if client.focus then
                    local tag = awful.tag.find_by_name(nil, tostring(i))
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }))
end

for i = 11, 19 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey, "Mod1" }, "" .. (i - 10),
            function()
                local tag = awful.tag.find_by_name(nil, tostring(i))
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ "Mod1", modkey, "Shift" }, "" .. (i - 10),
            function()
                if client.focus then
                    local tag = awful.tag.find_by_name(nil, tostring(i))
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }))
end

globalkeys = gears.table.join(globalkeys,
    --View tag only.
    awful.key({ modkey }, "" .. 0,
        function()
            local tag = awful.tag.find_by_name(nil, tostring(10))
            if tag then
                tag:view_only()
            end
        end,
        { description = "view tag #" .. 10, group = "tag" }),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "" .. 0,
        function()
            if client.focus then
                local tag = awful.tag.find_by_name(nil, tostring(10))
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
        { description = "move focused client to tag #" .. 10, group = "tag" }))

globalkeys = gears.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey, "Mod1" }, "" .. 0,
        function()
            local tag = awful.tag.find_by_name(nil, tostring(20))
            if tag then
                tag:view_only()
            end
        end,
        { description = "view tag #" .. 20, group = "tag" }),
    -- Move client to tag.
    awful.key({ "Mod1", modkey, "Shift" }, "" .. 0,
        function()
            if client.focus then
                local tag = awful.tag.find_by_name(nil, tostring(20))
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
        { description = "move focused client to tag #" .. 20, group = "tag" }))


globalkeys = gears.table.join(globalkeys,
    -- Brightness
    awful.key({ }, "XF86MonBrightnessDown", function ()
        awful.util.spawn("light -U 5") end,
	{ description = "Brightness down", group = "screen" }),
    awful.key({ }, "XF86MonBrightnessUp", function ()
        awful.util.spawn("light -A 5") end,
	{ description = "Brightness up", group = "screen" }),
    awful.key({ }, "XF86AudioRaiseVolume", function ()
        awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%") end,
	{ description = "Volume up", group = "audio" }),
    awful.key({ }, "XF86AudioLowerVolume", function ()
        awful.util.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%") end,
	{ description = "Volume down", group = "audio" }),
    awful.key({ }, "XF86AudioMute", function ()
        awful.util.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end,
	{ description = "Mute audio", group = "audio" }),
    awful.key({ }, "XF86AudioMicMute", function ()
        awful.util.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle") end,
	{ description = "Mute mic", group = "audio" }),
	
    awful.key({ }, "XF86AudioPlay", function ()
        awful.util.spawn("playerctl play-pause") end,
	{ description = "Audio play-pause", group = "audio" }),
    awful.key({ }, "XF86AudioNext", function ()
        awful.util.spawn("playerctl next") end,
	{ description = "Audio next", group = "audio" }),
    awful.key({ }, "XF86AudioPrev", function ()
        awful.util.spawn("playerctl prev") end,
	{ description = "Audio prev", group = "audio" }),


    awful.key({ "Shift", "Mod1" }, "v", function ()
        awful.util.spawn("rofi -modi \"clipboard:greenclip print\" -show clipboard -run-command '{cmd}'") end,
	{ description = "Show clipboard selection menu", group = "clipboard" }),

    awful.key({ "Shift", "Mod1" }, "p", function ()
        awful.util.spawn("rofi-pass") end,
	{ description = "Show pass selection menu", group = "password" }),

    awful.key({ }, "Print", function ()
        awful.util.spawn("flameshot gui") end,
	{ description = "Show screenshot tool gui", group = "screen" }),

    awful.key({ "Shift" }, "Print", function ()
        awful.util.spawn("gnome-screenshot -i") end,
	{ description = "Show Gnome screenshot tool gui", group = "screen" }),
	
    awful.key({ modkey, "Control" }, "d", function ()
        awful.util.spawn("xrandr --output eDP1 --off") end,
	{ description = "Disable laptop screen", group = "screen" }),

    awful.key({ modkey, "Control", "Shift" }, "d", function ()
        awful.util.spawn("autorandr --change") end,
	{ description = "Restore correct full displays layout (run autorandr)", group = "screen" })
)

-- Logic for laptop + external monitor setup
-- Once an external monitor disconnected, all tags should move to laptop display
-- Then an external monitor connected, all tags should move back
--moved_tags = {};

tag.connect_signal("request::screen", function(tag)
    for s in screen do
        if s ~= tag.screen then
            local same_name_tag = awful.tag.find_by_name(s, tag.name)
            if same_name_tag then
                tag:swap(same_name_tag)
            else
                tag.screen = s
                --                table.insert(moved_tags, tag.name)
            end
            return
        end
    end
end)

screen.connect_signal("added", awesome.restart)
--    function(s)
--    for screen_i in screen do
--        if screen_i ~= s then
--            for i, tag in ipairs(screen_i.tags) do
--                local same_tag_new_screen = awful.tag.find_by_name(s, tag.name)
--                if same_tag_new_screen then
--                    same_tag_new_screen:swap(tag)
--                    tag.volatile = true
--                    tag.screen = nil
--                    tag:delete()
--                end
--            end
--            for i, moved_tag in ipairs(moved_tags) do
--                local tag_by_name = awful.tag.find_by_name(screen_i, moved_tag)
--                local same_name_tag = awful.tag.find_by_name(s, moved_tag)
--                if same_name_tag then
--                    tag_by_name:swap(same_name_tag)
--                    tag_by_name:delete()
--                else
--                    tag_by_name.screen = s
--                end
--
--                table.remove(moved_tags, i)
--            end
--        end
--    end
--    for s in screen do
--        if s ~= tag.screen then
--            local same_name_tag = awful.tag.find_by_name(s, tag.name)
--            if same_name_tag then
--                tag:swap(same_name_tag)
--            else
--                tag.screen = s
--                table.insert(moved_tags, tag.name)
--            end
--        end
--    end
--end)

clientbuttons = gears.table.join(awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end))


-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA", -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
                ".arandr-wrapped",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin", -- kalarm.
                "Sxiv",
                "Wpa_gui",
                "veromix",
                "xtightvncviewer",
                "jetbrains-toolbox",
                "JetBrains Toolbox"
            },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester", -- xev.
                "JetBrains Toolbox"
            },
            role = {
                "AlarmWindow", -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = {
            floating = true,
            placement = awful.placement.centered
        }
    },

    -- Add titlebars to normal clients and dialogs
    --{ rule_any = {type = { "normal", "dialog" }
    --  }, properties = { titlebars_enabled = true }
    --},

    -- Remove titlebars
    {
        rule_any = {
            type = { "normal", "dialog" }
        },
        properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}
--
--


-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
            and not c.size_hints.user_position
            and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(awful.button({}, 1, function()
        c:emit_signal("request::activate", "titlebar", { raise = true })
        awful.mouse.client.move(c)
    end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(c)
        end))

    awful.titlebar(c):setup {
        {
            -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal
        },
        {
            -- Middle
            {
                -- Title
                align = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        {
            -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)


-- Hide border for floating or not tiling windows
screen.connect_signal("arrange", function (s)
    local max = s.selected_tag.layout.name == "max"
    local only_one = #s.tiled_clients == 1 -- use tiled_clients so that other floating windows don't affect the count
    -- but iterate over clients instead of tiled_clients as tiled_clients doesn't include maximized windows
    for _, c in pairs(s.clients) do
        if (max or only_one) and not c.floating or c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)
-- }}}
