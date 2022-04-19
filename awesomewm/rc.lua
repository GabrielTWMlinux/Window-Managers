-- if LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

------------------------------------------------
------------------ LIBRARIES -------------------
------------------------------------------------

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local volume_control = require("volume-control")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")


------------------------------------------------
------------------- ERRORS ---------------------
------------------------------------------------


-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}





------------------------------------------------
------------------- OPTIONS --------------------
------------------------------------------------

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "Dark/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. "vim"
browser = "firefox"
fm = "nautilus"

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
}
-- }}}





------------------------------------------------
------------------- WIDGETS --------------------
------------------------------------------------

-- Separator Blanc
tbox_separator2 = wibox.widget.textbox("")


-- Separator
tbox_separator = wibox.widget.textbox(" | ")

-- define your volume control, using default settings:
volumecfg = volume_control({})


-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()




------------------------------------------------
-------------------- WIBAR ---------------------
------------------------------------------------

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                           if client.focus then
                                                 client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
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

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7" }, s, awful.layout.layouts[1])

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.focused,
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, visible = false })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
	    s.mylayoutbox,
	    tbox_separator,
	    s.mytaglist,
	    tbox_separator2,
	    s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
	    volumecfg.widget,
	    tbox_separator,
	    mytextclock,
	    tbox_separator2,
            wibox.widget.systray(),
        },
    }
end)
-- }}}





------------------------------------------------
----------------- KEYBINDINGS ------------------
------------------------------------------------

-- {{{ Key bindings
globalkeys = gears.table.join(
    
    -- Standard program
    awful.key({ modkey,           }, "F1" , function () awful.spawn(browser) end,
    	      {description = "open a browser", group = "launcher"}),
    awful.key({ modkey,           }, "F2" , function () awful.spawn(fm) end,
    	      {description = "open a file manager", group = "launcher"}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    
    awful.key({ modkey         },   "a",      function () awful.spawn("alacritty -e pulsemixer") end,
    	{description = "exec pulsemixer", group = "Personal launchers"}),
    awful.key({ modkey,         },  "f",       function () awful.spawn("alacritty -e ranger") end,
        {descrption = "Open ranger", group = "Personal launchers"}),
    awful.key({ modkey         },   "p",      function () awful.spawn("rofi -show drun ") end,
       {description = "rofi-apps", group = "Personal launchers"}),
    awful.key({ modkey         },   "r",      function () awful.spawn("/home/gabriel/Scripts/rofi-files") end,
        {description = "Search files", group = "Personal launchers"}),
    awful.key({ modkey         },   "t",      function () awful.spawn("alacritty -e htop") end,
        {description = "Open htop", group = "Personal launchers"}),
    awful.key({ modkey         },    "w",     function () awful.spawn("/home/gabriel/Scripts/windowlocation") end,
       {description = "exec udates", group = "Personal lahnchers"}),	
    awful.key({ modkey		},   "x",	function () awful.spawn("/home/gabriel/Scripts/power-menu.sh") end,
	{description = "Rofi power menu", group = "Personal launchers"}),

    awful.key({ "Shift"         },   "b",      function () awful.spawn("/home/gabriel/Scripts/ram") end,
	{description = "exec ram", group = "Personal launchers"}),
    awful.key({ "Shift"         },   "C",      function () awful.spawn("/home/gabriel/Scripts/cpu") end,
        {descrition = "exec cpu", group = "Personal launchers"}),
    awful.key({ "Shift"         },   "d",      function () awful.spawn("/home/gabriel/Scripts/time") end,
        {descrition = "exec time_date", group = "Personal launchers"}),
    awful.key({ "Shift"         },   "m",      function () awful.spawn("/home/gabriel/Scripts/volume+") end,
        {description = "exec volup", group = "Personal launchers"}),
    awful.key({ "Shift"         },   "n",      function () awful.spawn("/home/gabriel/Scripts/volume-") end,
        {descritipn = "exec voldown", group = "Personal launchers"}),
    awful.key({ "Shift"         },   "s",      function () awful.spawn("/home/gabriel/Scripts/screenshot") end,
        {description = "Screenshot", group = "Personal launchers"}),
    awful.key({ "Shift"         },   "t",      function () awful.spawn("/home/gabriel/Scripts/weather-notify") end,
        {description = "Weather", group = "Personal launchers"}),
    awful.key({ "Shift"         },    "u",     function () awful.spawn("/home/gabriel/Scripts/xbps-update") end,
       {description = "exec udates", group = "Personal lahnchers"}),	

    
    -- Show/Hide Wibox
    awful.key({ modkey, "Shift" }, "p", function ()
         for s in screen do
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                    s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
            end
         end,
              {description = "toggle wibox", group = "awesome"}),


    -- Control Clients
    awful.key({ "Control",           }, "j",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ "Control",           }, "k",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({}, "F9", function() xrandr.xrandr() end),	
    

    -- Layout Manipulation
    awful.key({ modkey,           }, "Left", function () awful.client.focus.byidx( 1) end,
        {description = "focus next by index", group = "client"}),
    awful.key({ modkey,          }, "Right", function () awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}),

    awful.key({ modkey, "Shift"   }, "Right", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Left", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"})


)

clientkeys = gears.table.join(
    
    -- Close Clients
    awful.key({ modkey,		  }, "q",      function (c) c:kill()             end,
              {description = "close", group = "client"}),


    -- Layout Manipulation
    awful.key({ modkey, "Shift"   }, "f", function (c) c.fullscreen = not c.fullscreen c:raise() end,
       	      {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey, 	  }, "n",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, 	  }, ",", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "m", function (c) c.maximized = not c.maximized c:raise() end,
              {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control"   }, "m",function (c) c.maximized_vertical = not c.maximized_vertical c:raise() end,
              {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Control"   }, "n",function (c) c.maximized_horizontal = not c.maximized_horizontal c:raise() end,
              {description = "(un)maximize horizontally", group = "client"}),

    awful.key({ modkey, "Control" }, "Up", function (c)
      if c.floating then
        c:relative_move( 0, 0, 0, -10)
      else
        awful.client.incwfact(0.025)
      end
    end,
    {description = "Floating Resize Vertical -", group = "client"}),
    awful.key({ modkey, "Control" }, "Down", function (c)
      if c.floating then
        c:relative_move( 0, 0, 0,  10)
      else
        awful.client.incwfact(-0.025)
      end
    end,
    {description = "Floating Resize Vertical +", group = "client"}),
    awful.key({ modkey, "Control" }, "Left", function (c)
      if c.floating then
        c:relative_move( 0, 0, -10, 0)
      else
        awful.tag.incmwfact(-0.025)
      end
    end,
    {description = "Floating Resize Horizontal -", group = "client"}),
    awful.key({ modkey, "Control" }, "Right", function (c)
      if c.floating then
        c:relative_move( 0, 0,  10, 0)
      else
        awful.tag.incmwfact(0.025)
      end
    end,
    {description = "Floating Resize Horizontal +", group = "client"})

    )

-- Bind all key numbers to tags.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)


-- Set keys
root.keys(globalkeys)
-- }}}

local function client_status(client)

    local layout = awful.layout.get(mouse.screen)

    if (layout == awful.layout.suit.floating) or (client and client.floating) then
        return "floating"
    end

    if layout == awful.layout.suit.max then
        return "max"
    end

    return "other"

end




------------------------------------------------
-------------------- RULES ---------------------
------------------------------------------------

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = 1,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},


}
-- }}}





-------------------------------------------------
-------------------- SIGNALS --------------------
-------------------------------------------------

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)


-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}





-------------------------------------------------
--------------------- GAPS ----------------------
-------------------------------------------------

beautiful.useless_gap = 13

--beautiful.gap_single_client   = false

-- No borders when rearranging only 1 non-floating or maximized client
-- screen.connect_signal("arrange", function (s)
--    local only_one = #s.tiled_clients == 1
--    for _, c in pairs(s.clients) do
--        if only_one and not c.floating or c.maximized then
--            c.border_width = 0
--        else
--            c.border_width = beautiful.border_width -- your border width
--        end
--    end
-- end)



------------------------------------------------
-------------------- START ---------------------
------------------------------------------------

awful.spawn.with_shell('polkit-xfce-authentication-agent-1')
awful.spawn.with_shell('nitrogen --restore')
awful.spawn.with_shell('xset r rate 300 50')
awful.spawn.with_shell('xset s off')
awful.spawn.with_shell('xset -dpms')
awful.spawn.with_shell('numlockx on')
awful.spawn.with_shell('picom --experimental-backends') 
