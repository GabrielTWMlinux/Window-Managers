import os
import socket
import subprocess
from libqtile import bar, layout, widget, extension, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"
terminal = "alacritty"
browser = "firefox"
fm = "nautilus"
fm2 = "alacritty -e ranger"
monitor = "alacritty -e htop"

keys = [
    # Switch between windows
    Key([mod], "Left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "Left", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "Left", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "Right", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "Up", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "Down", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"], "Return", lazy.layout.toggle_split(),desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "F1", lazy.spawn(browser), desc="Launch browser"),
    Key([mod], "F2", lazy.spawn(fm), desc="Launch file manager"),
    Key([mod], "f", lazy.spawn(fm2), desc="Launch ranger"),
    Key([mod], "p", lazy.run_extension(extension.DmenuRun(
        dmenu_prompt="Run ",
        background="#16161E",
        foreground="#ffffff",
        selected_background="#3A575C",
        selected_foreground="#FFFFFF",
        font = "FontAwesome",
        fontsize = 14,
        ))),
    Key([mod], "t", lazy.spawn(monitor), desc="Launch htop"),
    Key(["shift"], "f", lazy.spawn("/home/gabriel/.config/Scripts/dmenu/dmenu-files"), desc="dmenu-files"),
    Key(["shift"], "m", lazy.spawn("/home/gabriel/.config/Scripts/notify/volume+"), desc="volume1"),
    Key(["shift"], "n", lazy.spawn("/home/gabriel/.config/Scripts/notify/volume-"), desc="volume2"),
    Key(["shift"], "p", lazy.spawn("/home/gabriel/.config/Scripts/dmenu/src-script"), desc="source scripts"),
    Key(["shift"], "s", lazy.spawn("/home/gabriel/.config/Scripts/screenshot"), desc="take screenshots"),
    Key(["shift"], "x", lazy.spawn("/home/gabriel/.config/Scripts/dmenu/dmenu_power"), desc="power-menu"),

    # Toggle between different layouts as defined below
    # Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

    Key([mod, "shift"], "n", lazy.group['music'].dropdown_toogle('tunes')),
]

groups = [Group(i) for i in "123456789"]

ScratchPad("music",[DropDown("tunes", "alacritty -e ncspot", x=0.33, y=0.02, width=0.35, height=0.95, on_focus_lost_hide=False)]),

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
        ]
    )


# Colors
colors = {
          'background': '#16161E',
          'foreground': '#ffffff',
          "black0": '#191E2A',
          "red0": '#FF3333',
          "green0": '#3A575C',
          "yellow0": '#FFA759',
          "blue0": '#345e81',
          "magenta0": '#FFD580',
          "cyan0": '#58838b',
          "white0": '#C7C7C7',
          "black1": '#686868',
          "red1": '#F27983',
          "green1": '#44666c',
          "yellow1": '#FFCC66',
          "blue1": '#5CCFE6',
          "magenta1": '#FFEE99',
          "cyan1": '#95E6CB',
          "white1": '#FFFFFF'
          }

layouts = [
    layout.Tile(border_focus="#75898c", margin = 8, border_width=2, ratio = 0.50),
    layout.Max(),
    layout.Floating()
    #layout.Stack(num_stacks=2),
    # layout.MonadTall(),
]

widget_defaults = dict(
    font="SymbolaRegular",
    fontsize=12,
    padding=1,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(
                    font = "SymbolaRegular",
                    fontsize = 12,
                    active = colors["green0"],
                    inactive = colors["white0"],
                    rounded = False,
                    foreground = colors["foreground"],
                    background = colors["background"],
                    ),
                widget.TextBox(
                    font = "SymbolaRegular",
                    fontsize = 12,
                    text = " | ",
                    foreground = colors["foreground"],
                    background = colors["background"],
                    padding = 5,
                       ),
                widget.CurrentLayout(
                    foreground = colors["foreground"],
                    background = colors["background"],
                    padding = 5,
                    font = "SymbolaRegular",
                    fontsize = 12,
                        ),
                widget.TextBox(
                    font = "SymbolaRegular",
                    fontsize = 12,
                    text = " | ",
                    foreground = colors["foreground"],
                    background = colors["background"],
                    padding = 5,
                       ),
                widget.WindowName(
                    font = "SymbolaRegular",
                    foreground = colors["cyan0"],
                    background = colors["background"],
                    padding = 5,
                    fontsize = 12,
                    ),
                widget.TextBox(
                    font = "SymbolaRegular",
                    fontsize = 12,
                    text = "  ",
                    foreground = colors["green1"],
                    background = colors["background"],
                    padding = 1,
                       ),
                widget.Volume(
                    font = "SymbolaRegular",
                    fontsize = 12,
                    fmt = "{}  ",
                    update_intervl = 1,
                    foreground = colors["foreground"],
                    background = colors["background"],
                    padding = 1,
                       ),
                widget.TextBox(
                    font = "SymbolaRegular",
                    fontsize = 12,
                    text = "  ",
                    foreground = colors["green1"],
                    background = colors["background"],
                    padding = 1,
                       ),
                widget.Clock(
                    format="%d %B %Y, %A %H:%M",
                    font = "SymbolaRegular",
                    foreground = colors["foreground"],
                    background = colors["background"],
                    fontsize = 12,
                    padding = 5,
                    ),
                widget.Systray(),
            ],
            24,
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
reconfigure_screens = True

@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call([home])

wmname = "LG3D"
