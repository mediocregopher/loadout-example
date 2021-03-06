-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local function debug(msg)
    if not msg then msg = "" end
    naughty.notify({ text = "debug: " .. msg })
end

local function info(msg)
    naughty.notify({ text = msg })
end

require("bat")
require("pulseaudio")
muteAll() -- pre-emptively mute all mics, just in-case

-- for sanity
local home_dir = os.getenv("HOME").."/"
local conf_dir = home_dir..".config/awesome/"

-- {{{ Naughty config (the notification library)
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.width = 250
naughty.config.defaults.icon=conf_dir .. "helper.png"
naughty.config.defaults.icon_size = 75
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
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
                         text = err })
        in_error = false
    end)
end
-- }}}


local beautiful = require("beautiful")

-- {{{ Wallpaper
-- we do this here, before the theme is loaded, because our theme depends on
-- knowing what our wallpaper is, cause this shit is cray
local wp_dir = home_dir.."Wallpapers"
function rand_wp()
    local ls = io.popen("ls " .. wp_dir .. " | shuf -n1")
    local wp = ls:read("*l")
    return wp_dir .. '/' .. wp
end

function rand_wp_lock()
    awful.spawn(conf_dir.."bin/random_i3lock.sh "..wp_dir, false)
end

local wp = rand_wp()
local imgavg = io.popen("cat " .. wp .. " | " .. conf_dir .. "/bin/imgavg")
local avgcolor = imgavg:read()
local comcolor = imgavg:read()
imgavg:close()

for s = 1, screen.count() do
    gears.wallpaper.maximized(wp, s, true)
end
-- }}}

require("theme/theme")
local theme = load_theme(avgcolor, comcolor)
beautiful.init(theme)

-- {{{ Variable definitions
function terminal(profile)
    return "konsole --hide-tabbar --hide-menubar --profile " ..  profile .. ".profile"
end

-- This is used later as the default terminal and editor to run.
terminal_dark = terminal("shell-dark")
terminal_light = terminal("shell-light")

editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal_dark .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}


-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal_dark -- Set the terminal for applications that require it

-- {{{ Wibox

-- {{{ Battery widget
local battimerintvl = 4
batwidget = wibox.widget.textbox("")
battimer = gears.timer({ timeout = battimerintvl })
battimer:connect_signal("timeout",
    function()
        local batlevel, charging = batteryInfo()
        if batlevel == nil then batlevel = "unk" end
        if (tonumber(batlevel) < 10) then
            naughty.notify({
                preset = naughty.config.presets.critical,
                title="ALERT",
                text="BATTERY LEVEL LOW",
                timeout=battimerintvl-1,
            })
        end
        if charging then
            batwidget:set_markup('bat:'..batlevel)
        else
            batwidget:set_markup('<b>bat:'..batlevel..'</b>')
        end
    end)
battimer:start()
-- }}}

-- {{{ sysstats widget
sysstatswidget = wibox.widget.textbox("")
sysstatstimer = gears.timer({ timeout = 1 })
sysstatstimer:connect_signal("timeout",
    function()
        local sysstats = "??? STATS ???"
        local f_sysstats = io.open("/tmp/sysstats")
        if f_sysstats then
            c_sysstats = f_sysstats:read()
            f_sysstats:close()
            if c_sysstats then sysstats = c_sysstats end
        end
        sysstatswidget:set_markup(sysstats)
    end)
sysstatstimer:start()
-- }}}

-- {{{ notifier for when my mic isn't muted
local unmuteNot
mutechecktimer = gears.timer({ timeout = 0.5 })
mutechecktimer:connect_signal("timeout",
    function()
        local anyUnmuted = unmuted()
        if unmuteNot and not anyUnmuted then
            naughty.destroy(unmuteNot, naughty.notificationClosedReason.dismissedByUser)
            unmuteNot = nil
        elseif not unmuteNot and anyUnmuted then
            unmuteNot = naughty.notify({
                preset = naughty.config.presets.critical,
                text = "Mic is hot!",
                timeout = 0,
            })
        end
    end)
mutechecktimer:start()
-- }}}


-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibar({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylayoutbox[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_sep = "  |  "
    local right_layout = wibox.layout.fixed.horizontal()
    --right_layout:add(wibox.widget.textbox(right_sep))
    right_layout:add(sysstatswidget)
    right_layout:add(wibox.widget.textbox(right_sep))
    right_layout:add(batwidget)
    right_layout:add(wibox.widget.textbox(right_sep))
    right_layout:add(wibox.widget.systray())
    right_layout:add(wibox.widget.textbox(right_sep))
    right_layout:add(mytaglist[s])
    right_layout:add(wibox.widget.textbox(right_sep))
    right_layout:add(mytextclock)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

local function focused()
  return awful.screen.focused().index
end

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    -- awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),

    -- j and k are used for moving around windows and moving windows around
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),

    -- h and l are for resizing
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incnmaster(-1)      end),

    -- Space is for changing the layout
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),


    -- r is for restart, awesome or the whole computer
    awful.key({ modkey }, "r", awesome.restart),
    awful.key({ modkey, "Control" }, "r",
        function ()
            awful.spawn("systemctl reboot")
        end),

    -- Escape is for quitting, either the current program, all of awesome, or
    -- or all of everything (suspend) (current program is under clientkeys)
    awful.key({ modkey, "Control" }, "Escape", awesome.quit),
    awful.key({ modkey, "Control", "Shift" }, "Escape",
        function ()
            rand_wp_lock()
            awful.spawn("systemctl suspend")
        end),

    -- n is for minimizing and unminimizing (minimmize is implemented under
    -- clientkeys)
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey }, "p", function ()
        local screen = awful.screen.focused().index
        mywibox[screen].visible = true
        mypromptbox[screen]:run()
    end),

    --Terminal
    awful.key({ modkey }, "Return", function ()
        awful.spawn(terminal_dark)
    end),
    awful.key({ modkey, "Shift" }, "Return", function ()
        awful.spawn(terminal_light)
    end),

    --PrintScreen
    awful.key({}, "Print", false, function () awful.spawn(conf_dir.."bin/scrot-gobin.sh",false) end),
    awful.key({ "Control" }, "Print", function ()
        local scr_dir = home_dir..'Screenshots'
        awful.spawn("mkdir -p "..scr_dir, false)
        awful.spawn("scrot -e 'mv $f "..scr_dir.."/ 2>/dev/null'",false)
        naughty.notify({ text = "Screenshot taken" })
    end),

    --Lock screen
    awful.key({ modkey, "Control" }, "Delete", rand_wp_lock),

    --Chrome
    awful.key({ modkey }, "c", function ()
        info("starting chromium")
        awful.spawn("chromium --pinned-tab-count=10",false)
    end),

    --Hangouts
    awful.key({ modkey }, "h", function ()
        info("starting hangouts")
        awful.spawn("chromium '--profile-directory=Profile 1' --app-id=knipolnnllmklapflnccelgolnpehhpl",false)
    end),

    --Slack
    awful.key({ modkey }, "s", function ()
        info("starting slack")
        awful.spawn("slack",false)
    end),

    --Keybase
    awful.key({ modkey }, "b", function ()
        info("starting keybase")
        awful.spawn("run_keybase",false)
    end),

    awful.key( { }, "XF86AudioRaiseVolume", function()
        awful.spawn("/usr/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
        awful.spawn("/usr/bin/pactl set-sink-mute @DEFAULT_SINK@ 0", false)
    end),

    awful.key( { }, "XF86AudioLowerVolume", function()
        awful.spawn("/usr/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
        awful.spawn("/usr/bin/pactl set-sink-mute @DEFAULT_SINK@ 0", false)
    end),

    awful.key( { }, "XF86AudioMute", function()
        awful.spawn("/usr/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
    end),

    awful.key( { }, "XF86MonBrightnessUp", function()
        awful.spawn("/usr/bin/xbacklight -inc 5", false)
    end),

    awful.key( { }, "XF86MonBrightnessDown", function()
        awful.spawn("/usr/bin/xbacklight -dec 5", false)
    end),

    -- Push to talk
    awful.key( { modkey }, "q", function()
        awful.spawn("/usr/bin/pactl set-source-mute @DEFAULT_SOURCE@ 0")
    end,
        muteAll,
    { })
)

globalkeys = awful.util.table.join(globalkeys,
    awful.key( { modkey }, "a", function()
        info(tostring(os.time()))
    end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "Escape", function (c) c:kill() end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                            tag:view_only()
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local screen = awful.screen.focused()
                          local tag = screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } }
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            c:move_to_screen(awful.screen.focused())
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
