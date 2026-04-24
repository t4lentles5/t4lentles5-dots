import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {
    id: root

    property var themes: [{
        "name": "Default",
        "dark": {
            "name": "Default",
            "bg": '#030107',
            "bgSecondary": '#12121b',
            "fg": '#d1d1d1',
            "muted": '#484d69',
            "cyan": '#72cbff',
            "purple": '#a77ef5',
            "red": '#e52e4f',
            "yellow": '#f0a32f',
            "blue": '#5b70db',
            "green": '#86c93f'
        },
        "light": {
            "name": "Default Light",
            "bg": '#e8dbff',
            "bgSecondary": '#ede6fb',
            "fg": '#1e1a2e',
            "muted": '#6b6489',
            "cyan": '#1e8fbc',
            "purple": '#7040e8',
            "red": '#c41840',
            "yellow": '#a67a0a',
            "blue": '#3f52c4',
            "green": '#4a9a28'
        }
    }, {
        "name": "Tokyo Night",
        "dark": {
            "name": "Tokyo Night",
            "bg": "#1a1b26",
            "bgSecondary": "#24283b",
            "fg": "#c0caf5",
            "muted": "#565f89",
            "cyan": "#7dcfff",
            "purple": "#bb9af7",
            "red": "#f7768e",
            "yellow": "#e0af68",
            "blue": "#7aa2f7",
            "green": "#9ece6a"
        },
        "light": {
            "name": "Tokyo Night Day",
            "bg": "#e1e2e7",
            "bgSecondary": "#c4c8da",
            "fg": "#3760bf",
            "muted": "#848cb5",
            "cyan": "#007197",
            "purple": "#9854f1",
            "red": "#f52a65",
            "yellow": "#8c6c3e",
            "blue": "#2e7de9",
            "green": "#587539"
        }
    }, {
        "name": "Catppuccin",
        "dark": {
            "name": "Catppuccin Mocha",
            "bg": "#1e1e2e",
            "bgSecondary": "#313244",
            "fg": "#cdd6f4",
            "muted": "#6c7086",
            "cyan": "#89dceb",
            "purple": "#cba6f7",
            "red": "#f38ba8",
            "yellow": "#f9e2af",
            "blue": "#89b4fa",
            "green": "#a6e3a1"
        },
        "light": {
            "name": "Catppuccin Latte",
            "bg": "#eff1f5",
            "bgSecondary": "#ccd0da",
            "fg": "#4c4f69",
            "muted": "#9ca0b0",
            "cyan": "#04a5e5",
            "purple": "#8839ef",
            "red": "#d20f39",
            "yellow": "#df8e1d",
            "blue": "#1e66f5",
            "green": "#40a02b"
        }
    }, {
        "name": "Gruvbox",
        "dark": {
            "name": "Gruvbox Dark",
            "bg": "#1d2021",
            "bgSecondary": "#3c3836",
            "fg": "#ebdbb2",
            "muted": "#665c54",
            "cyan": "#8ec07c",
            "purple": "#d3869b",
            "red": "#fb4934",
            "yellow": "#fabd2f",
            "blue": "#83a598",
            "green": "#b8bb26"
        },
        "light": {
            "name": "Gruvbox Light",
            "bg": "#fbf1c7",
            "bgSecondary": "#ebdbb2",
            "fg": "#3c3836",
            "muted": "#928374",
            "cyan": "#427b58",
            "purple": "#8f3f71",
            "red": "#cc241d",
            "yellow": "#d79921",
            "blue": "#458588",
            "green": "#98971a"
        }
    }, {
        "name": "Rosé Pine",
        "dark": {
            "name": "Rose Pine",
            "bg": "#191724",
            "bgSecondary": "#1f1d2e",
            "fg": "#e0def4",
            "muted": "#6e6a86",
            "cyan": "#9ccfd8",
            "purple": "#c4a7e7",
            "red": "#eb6f92",
            "yellow": "#f6c177",
            "blue": "#31748f",
            "green": "#9ccfd8"
        },
        "light": {
            "name": "Rose Pine Dawn",
            "bg": "#faf4ed",
            "bgSecondary": "#f2e9e1",
            "fg": "#575279",
            "muted": "#9893a5",
            "cyan": "#56949f",
            "purple": "#907aa9",
            "red": "#b4637a",
            "yellow": "#ea9d34",
            "blue": "#286983",
            "green": "#56949f"
        }
    }, {
        "name": "Kanagawa",
        "dark": {
            "name": "Kanagawa",
            "bg": "#1f1f28",
            "bgSecondary": "#2a2a37",
            "fg": "#dcd7ba",
            "muted": "#727169",
            "cyan": "#7fb4ca",
            "purple": "#957fb8",
            "red": "#c34043",
            "yellow": "#dca561",
            "blue": "#7e9cd8",
            "green": "#76946a"
        },
        "light": {
            "name": "Kanagawa Lotus",
            "bg": "#f2ecbc",
            "bgSecondary": "#e5ddb0",
            "fg": "#545464",
            "muted": "#8a8980",
            "cyan": "#6693bf",
            "purple": "#b35b79",
            "red": "#c84053",
            "yellow": "#77713f",
            "blue": "#4d699b",
            "green": "#6f894e"
        }
    }]
    property string currentScheme: "Default"
    property color bg: themes[0].dark.bg
    property color bgSecondary: themes[0].dark.bgSecondary
    property color fg: themes[0].dark.fg
    property color muted: themes[0].dark.muted
    property color border: Qt.rgba(1, 1, 1, 0.05)
    property color cyan: themes[0].dark.cyan
    property color purple: themes[0].dark.purple
    property color red: themes[0].dark.red
    property color yellow: themes[0].dark.yellow
    property color blue: themes[0].dark.blue
    property color blueArch: "#0a9cf5"
    property color green: themes[0].dark.green
    property bool _wasDark: true
    property Process saver
    property Process loader
    property Process kittyProc
    property Process gtkProc
    property Process nvimProc
    property Process yaziProc

    function applyScheme(scheme) {
        currentScheme = scheme.name;
        bg = scheme.bg;
        bgSecondary = scheme.bgSecondary;
        fg = scheme.fg;
        muted = scheme.muted;
        cyan = scheme.cyan;
        purple = scheme.purple;
        red = scheme.red;
        yellow = scheme.yellow;
        blue = scheme.blue;
        green = scheme.green;
        let brightness = bg.r * 0.299 + bg.g * 0.587 + bg.b * 0.114;
        border = brightness > 0.5 ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.05);
        saveScheme();
        applyKittyTheme();
        applyGtkMode();
        applyNvimTheme(scheme.name);
        applyYaziTheme();
    }

    function applyKittyTheme() {
        let home = Quickshell.env("HOME");
        let c0 = muted;
        let c7 = fg;
        let c8 = muted;
        let c15 = fg;
        let theme = "" + "foreground              " + fg + "\n" + "background              " + bg + "\n" + "selection_foreground    " + bg + "\n" + "selection_background    " + purple + "\n" + "cursor                  " + fg + "\n" + "cursor_text_color       " + bg + "\n" + "url_color               " + blue + "\n" + "active_border_color     " + purple + "\n" + "inactive_border_color   " + muted + "\n" + "bell_border_color       " + yellow + "\n" + "active_tab_foreground   " + bg + "\n" + "active_tab_background   " + purple + "\n" + "inactive_tab_foreground " + fg + "\n" + "inactive_tab_background " + bg + "\n" + "tab_bar_background      " + bg + "\n" + "color0  " + c0 + "\n" + "color8  " + c8 + "\n" + "color1  " + red + "\n" + "color9  " + red + "\n" + "color2  " + green + "\n" + "color10 " + green + "\n" + "color3  " + yellow + "\n" + "color11 " + yellow + "\n" + "color4  " + blue + "\n" + "color12 " + blue + "\n" + "color5  " + purple + "\n" + "color13 " + purple + "\n" + "color6  " + cyan + "\n" + "color14 " + cyan + "\n" + "color7  " + c7 + "\n" + "color15 " + c15 + "\n" + "color16 " + bgSecondary + "\n";
        kittyProc.running = false;
        kittyProc.command = ["bash", "-c", "echo '" + theme + "' > '" + home + "/.config/kitty/theme.conf' && kill -SIGUSR1 $(pidof kitty) 2>/dev/null || true"];
        kittyProc.running = true;
    }

    function applyGtkMode() {
        let brightness = bg.r * 0.299 + bg.g * 0.587 + bg.b * 0.114;
        let isDark = brightness <= 0.5;
        let modeChanged = (isDark !== _wasDark);
        _wasDark = isDark;
        let darkVal = isDark ? "1" : "0";
        let gsVal = isDark ? "prefer-dark" : "prefer-light";
        let gtkThemeName = isDark ? "catppuccin-mocha-mauve-standard+default" : "catppuccin-latte-mauve-standard+default";
        let home = Quickshell.env("HOME");
        let themeDir = "/usr/share/themes/" + gtkThemeName + "/gtk-4.0";
        let configDir = home + "/.config/gtk-4.0";
        let bashCmd = "sed -i 's/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=" + darkVal + "/' '" + home + "/.config/gtk-3.0/settings.ini' '" + configDir + "/settings.ini' 2>/dev/null; " + "sed -i 's/^gtk-theme-name=.*/gtk-theme-name=" + gtkThemeName + "/' '" + home + "/.config/gtk-3.0/settings.ini' '" + configDir + "/settings.ini' 2>/dev/null; " + "gsettings set org.gnome.desktop.interface color-scheme '" + gsVal + "'; " + "gsettings set org.gnome.desktop.interface gtk-theme '" + gtkThemeName + "'; " + "rm -rf '" + configDir + "/assets' '" + configDir + "/gtk.css' '" + configDir + "/gtk-dark.css'; " + "ln -sf '" + themeDir + "/assets' '" + configDir + "/assets'; " + "ln -sf '" + themeDir + "/gtk.css' '" + configDir + "/gtk.css'; " + "ln -sf '" + themeDir + "/gtk-dark.css' '" + configDir + "/gtk-dark.css'" + (modeChanged ? "; killall -q nautilus || true" : "");
        gtkProc.running = false;
        gtkProc.command = ["bash", "-c", bashCmd];
        gtkProc.running = true;
    }

    function sanitizeColor(c) {
        let s = String(c);
        if (s.startsWith("#") && s.length > 7)
            return "#" + s.substring(s.length - 6);

        return s;
    }

    function applyNvimTheme(schemeName) {
        let nvimTheme = "";
        let background = "dark";
        switch (schemeName) {
        case "Default":
            nvimTheme = "default";
            break;
        case "Default Light":
            nvimTheme = "default";
            background = "light";
            break;
        case "Tokyo Night":
            nvimTheme = "tokyonight-night";
            break;
        case "Tokyo Night Day":
            nvimTheme = "tokyonight-day";
            background = "light";
            break;
        case "Catppuccin Mocha":
            nvimTheme = "catppuccin-mocha";
            break;
        case "Catppuccin Latte":
            nvimTheme = "catppuccin-latte";
            background = "light";
            break;
        case "Gruvbox Dark":
            nvimTheme = "gruvbox";
            break;
        case "Gruvbox Light":
            nvimTheme = "gruvbox";
            background = "light";
            break;
        case "Rose Pine":
            nvimTheme = "rose-pine-main";
            break;
        case "Rose Pine Dawn":
            nvimTheme = "rose-pine-dawn";
            background = "light";
            break;
        case "Kanagawa":
            nvimTheme = "kanagawa-wave";
            break;
        case "Kanagawa Lotus":
            nvimTheme = "kanagawa-lotus";
            background = "light";
            break;
        default:
            nvimTheme = "default";
            break;
        }
        let qs_colors = "vim.g.qs_colors = {\n" + "  bg = \"" + sanitizeColor(bg) + "\",\n" + "  bgSecondary = \"" + sanitizeColor(bgSecondary) + "\",\n" + "  fg = \"" + sanitizeColor(fg) + "\",\n" + "  muted = \"" + sanitizeColor(muted) + "\",\n" + "  cyan = \"" + sanitizeColor(cyan) + "\",\n" + "  purple = \"" + sanitizeColor(purple) + "\",\n" + "  red = \"" + sanitizeColor(red) + "\",\n" + "  yellow = \"" + sanitizeColor(yellow) + "\",\n" + "  blue = \"" + sanitizeColor(blue) + "\",\n" + "  green = \"" + sanitizeColor(green) + "\"\n" + "}\n";
        let styleVar = "";
        if (nvimTheme.startsWith("tokyonight-")) {
            let style = nvimTheme.replace("tokyonight-", "");
            styleVar = "vim.g.tokyonight_style = \"" + style + "\"\n";
        }
        let luaContent = "vim.opt.background = \"" + background + "\"\n" + qs_colors + styleVar + "pcall(vim.cmd.colorscheme, \"" + nvimTheme + "\")";
        let home = Quickshell.env("HOME");
        nvimProc.running = false;
        nvimProc.command = ["bash", "-c", "mkdir -p '" + home + "/.cache/quickshell' && echo '" + luaContent + "' > '" + home + "/.cache/quickshell/nvim_theme.lua'"];
        nvimProc.running = true;
    }

    function applyYaziTheme() {
        let home = Quickshell.env("HOME");
        let toml = "[manager]\n" + "cwd = { fg = \"cyan\" }\n" + "hovered = { fg = \"" + sanitizeColor(bg) + "\", bg = \"blue\" }\n" + "tab_active = { fg = \"" + sanitizeColor(bg) + "\", bg = \"blue\" }\n" + "tab_inactive = { fg = \"" + sanitizeColor(fg) + "\", bg = \"16\" }\n" + "border_style = { fg = \"bright-black\" }\n\n" + "[mode]\n" + "normal_main = { fg = \"" + sanitizeColor(bg) + "\", bg = \"blue\", bold = true }\n" + "normal_alt = { fg = \"blue\", bg = \"16\" }\n" + "select_main = { fg = \"" + sanitizeColor(bg) + "\", bg = \"green\", bold = true }\n" + "select_alt = { fg = \"green\", bg = \"16\" }\n" + "unset_main = { fg = \"" + sanitizeColor(bg) + "\", bg = \"magenta\", bold = true }\n" + "unset_alt = { fg = \"magenta\", bg = \"16\" }\n\n" + "[status]\n" + "separator_open  = \"\"\n" + "separator_close = \"\"\n" + "separator_style = { fg = \"16\", bg = \"16\" }\n" + "mode_normal = { fg = \"" + sanitizeColor(bg) + "\", bg = \"blue\", bold = true }\n" + "mode_select = { fg = \"" + sanitizeColor(bg) + "\", bg = \"green\", bold = true }\n" + "mode_unset  = { fg = \"" + sanitizeColor(bg) + "\", bg = \"magenta\", bold = true }\n" + "progress_label = { fg = \"" + sanitizeColor(fg) + "\", bold = true }\n" + "progress_normal = { fg = \"blue\", bg = \"16\" }\n" + "progress_error = { fg = \"red\", bg = \"16\" }\n" + "permissions_t = { fg = \"blue\" }\n" + "permissions_r = { fg = \"yellow\" }\n" + "permissions_w = { fg = \"red\" }\n" + "permissions_x = { fg = \"green\" }\n" + "permissions_s = { fg = \"bright-black\" }\n";
        yaziProc.running = false;
        yaziProc.command = ["bash", "-c", "mkdir -p '" + home + "/.config/yazi' && echo '" + toml + "' > '" + home + "/.config/yazi/theme.toml' && ya emit reload"];
        yaziProc.running = true;
    }

    function saveScheme() {
        let obj = {
            "name": currentScheme,
            "bg": "" + bg,
            "bgSecondary": "" + bgSecondary,
            "fg": "" + fg,
            "muted": "" + muted,
            "cyan": "" + cyan,
            "purple": "" + purple,
            "red": "" + red,
            "yellow": "" + yellow,
            "blue": "" + blue,
            "green": "" + green
        };
        let json = JSON.stringify(obj);
        let home = Quickshell.env("HOME");
        saver.running = false;
        saver.command = ["bash", "-c", "mkdir -p '" + home + "/.cache/quickshell' && echo '" + json + "' > '" + home + "/.cache/quickshell/colorscheme.json'"];
        saver.running = true;
    }

    function loadScheme() {
        loader.running = false;
        loader.running = true;
    }

    Component.onCompleted: loadScheme()

    saver: Process {
    }

    loader: Process {
        command: ["cat", Quickshell.env("HOME") + "/.cache/quickshell/colorscheme.json"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    let colors = JSON.parse(loaderOutput.text);
                    if (Theme.name)
                        root.currentScheme = Theme.name;

                    if (Theme.bg)
                        root.bg = Theme.bg;

                    if (Theme.bgSecondary)
                        root.bgSecondary = Theme.bgSecondary;

                    if (Theme.fg)
                        root.fg = Theme.fg;

                    if (Theme.muted)
                        root.muted = Theme.muted;

                    if (Theme.cyan)
                        root.cyan = Theme.cyan;

                    if (Theme.purple)
                        root.purple = Theme.purple;

                    if (Theme.red)
                        root.red = Theme.red;

                    if (Theme.yellow)
                        root.yellow = Theme.yellow;

                    if (Theme.blue)
                        root.blue = Theme.blue;

                    if (Theme.green)
                        root.green = Theme.green;

                    let brightness = root.bg.r * 0.299 + root.bg.g * 0.587 + root.bg.b * 0.114;
                    root.border = brightness > 0.5 ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.05);
                    root.applyKittyTheme();
                    root.applyGtkMode();
                    root.applyNvimTheme(root.currentScheme);
                    root.applyYaziTheme();
                } catch (e) {
                    console.log("Colors: Error parsing config, using default");
                    root.applyScheme(root.themes[0].dark);
                }
            } else {
                console.log("Colors: No config found, using default");
                root.applyScheme(root.themes[0].dark);
            }
        }

        stdout: StdioCollector {
            id: loaderOutput
        }

    }

    kittyProc: Process {
    }

    gtkProc: Process {
    }

    nvimProc: Process {
    }

    yaziProc: Process {
    }

}
