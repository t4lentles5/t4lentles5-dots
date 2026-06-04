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
            "pink": '#ff79c6',
            "yellow": '#ea9a23',
            "orange": '#ffb86c',
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
            "pink": '#db2777',
            "yellow": '#daa92e',
            "orange": '#ea580c',
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
            "pink": "#ff007f",
            "yellow": "#e0af68",
            "orange": "#ff9e64",
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
            "pink": "#e01a55",
            "yellow": "#8c6c3e",
            "orange": "#b15c00",
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
            "pink": "#f5c2e7",
            "yellow": "#f9e2af",
            "orange": "#fab387",
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
            "pink": "#ea76cb",
            "yellow": "#df8e1d",
            "orange": "#fe640b",
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
            "pink": "#b16286",
            "yellow": "#fabd2f",
            "orange": "#fe8019",
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
            "pink": "#8f3f71",
            "yellow": "#d79921",
            "orange": "#d65d0e",
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
            "pink": "#ebbcba",
            "yellow": "#f6c177",
            "orange": "#f6c177",
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
            "pink": "#d7827e",
            "yellow": "#ea9d34",
            "orange": "#ea9d34",
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
            "pink": "#d27e99",
            "yellow": "#dca561",
            "orange": "#ffa066",
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
            "pink": "#b35b79",
            "yellow": "#77713f",
            "orange": "#e98a00",
            "blue": "#4d699b",
            "green": "#6f894e"
        }
    }]
    property string currentScheme: "Default"
    property color bg: themes[0].dark.bg
    property color bgSecondary: themes[0].dark.bgSecondary
    property color orange: themes[0].dark.orange || themes[0].dark.yellow
    property color pink: themes[0].dark.pink || themes[0].dark.red
    property color fg: themes[0].dark.fg
    property color muted: themes[0].dark.muted
    property color border: Qt.rgba(1, 1, 1, 0.15)
    property color cyan: themes[0].dark.cyan
    property color purple: themes[0].dark.purple
    property color red: themes[0].dark.red
    property color yellow: themes[0].dark.yellow
    property color blue: themes[0].dark.blue
    property color blueArch: "#0a9cf5"
    property color green: themes[0].dark.green
    property bool generateFromWallpaper: false
    property var wallpaperColors: null
    property Process saver
    property Process loader
    property Process wallpaperLoader
    property Process kittyProc
    property Process gtkProc
    property Process nvimProc
    property Process yaziProc
    property Process generatorProc
    property Process notifyProc
    property Process hyprProc
    property Process starshipProc

    function applyScheme(scheme) {
        currentScheme = scheme.name;
        bg = scheme.bg;
        bgSecondary = scheme.bgSecondary;
        orange = scheme.orange || scheme.yellow || "#ea9a23";
        pink = scheme.pink || scheme.red || "#e52e4f";
        fg = scheme.fg;
        muted = scheme.muted;
        cyan = scheme.cyan;
        purple = scheme.purple;
        red = scheme.red;
        yellow = scheme.yellow;
        blue = scheme.blue;
        green = scheme.green;
        let brightness = getBrightness(bg);
        border = brightness > 0.5 ? Qt.rgba(0, 0, 0, 0.2) : Qt.rgba(1, 1, 1, 0.15);
        saveScheme();
        applyKittyTheme();
        applyGtkMode();
        applyNvimTheme(scheme.name);
        applyYaziTheme();
        applyHyprlandTheme();
        applyStarshipTheme();
        notifyProc.command = ["notify-send", "Color Scheme", "Applied scheme: " + scheme.name, "-i", "color-management", "-a", "Quickshell"];
        notifyProc.startDetached();
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
        let brightness = getBrightness(bg);
        let isDark = brightness <= 0.5;
        let darkVal = isDark ? "1" : "0";
        let gsVal = isDark ? "prefer-dark" : "prefer-light";
        let gtkThemeName = isDark ? "catppuccin-mocha-mauve-standard+default" : "catppuccin-latte-mauve-standard+default";
        let home = Quickshell.env("HOME");
        let configDir = home + "/.config/gtk-4.0";
        let gtk3File = home + "/.config/gtk-3.0/gtk.css";
        let gtk4Css = "@define-color window_bg_color " + sanitizeColor(bg) + ";\n" + "@define-color window_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color view_bg_color " + sanitizeColor(bg) + ";\n" + "@define-color view_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color headerbar_bg_color " + sanitizeColor(bgSecondary) + ";\n" + "@define-color headerbar_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color sidebar_bg_color " + sanitizeColor(bgSecondary) + ";\n" + "@define-color sidebar_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color sidebar_backdrop_bg_color " + sanitizeColor(bgSecondary) + ";\n" + "@define-color sidebar_backdrop_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color popover_bg_color " + sanitizeColor(bgSecondary) + ";\n" + "@define-color popover_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color card_bg_color " + sanitizeColor(bgSecondary) + ";\n" + "@define-color card_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color accent_color " + sanitizeColor(purple) + ";\n" + "@define-color accent_bg_color " + sanitizeColor(purple) + ";\n" + "@define-color accent_fg_color " + sanitizeColor(bg) + ";\n" + "@define-color destructive_bg_color " + sanitizeColor(red) + ";\n" + "@define-color success_bg_color " + sanitizeColor(green) + ";\n" + "@define-color warning_bg_color " + sanitizeColor(orange) + ";\n\n" + ":root {\n" + "  --window-bg-color: " + sanitizeColor(bg) + ";\n" + "  --window-fg-color: " + sanitizeColor(fg) + ";\n" + "  --view-bg-color: " + sanitizeColor(bg) + ";\n" + "  --view-fg-color: " + sanitizeColor(fg) + ";\n" + "  --headerbar-bg-color: " + sanitizeColor(bgSecondary) + ";\n" + "  --headerbar-fg-color: " + sanitizeColor(fg) + ";\n" + "  --sidebar-bg-color: " + sanitizeColor(bgSecondary) + ";\n" + "  --sidebar-fg-color: " + sanitizeColor(fg) + ";\n" + "  --sidebar-backdrop-bg-color: " + sanitizeColor(bgSecondary) + ";\n" + "  --sidebar-backdrop-fg-color: " + sanitizeColor(fg) + ";\n" + "  --popover-bg-color: " + sanitizeColor(bgSecondary) + ";\n" + "  --popover-fg-color: " + sanitizeColor(fg) + ";\n" + "  --card-bg-color: " + sanitizeColor(bgSecondary) + ";\n" + "  --card-fg-color: " + sanitizeColor(fg) + ";\n" + "  --accent-color: " + sanitizeColor(purple) + ";\n" + "  --accent-bg-color: " + sanitizeColor(purple) + ";\n" + "  --accent-fg-color: " + sanitizeColor(bg) + ";\n" + "  --destructive-bg-color: " + sanitizeColor(red) + ";\n" + "  --success-bg-color: " + sanitizeColor(green) + ";\n" + "  --warning-bg-color: " + sanitizeColor(orange) + ";\n" + "}\n";
        let gtkBorder = getSolidBorder(bg, isDark);
        let gtk3Css = "@define-color theme_bg_color " + sanitizeColor(bg) + ";\n" + "@define-color theme_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color theme_base_color " + sanitizeColor(bg) + ";\n" + "@define-color theme_text_color " + sanitizeColor(fg) + ";\n" + "@define-color theme_selected_bg_color " + sanitizeColor(purple) + ";\n" + "@define-color theme_selected_fg_color " + sanitizeColor(bg) + ";\n" + "@define-color theme_unfocused_bg_color " + sanitizeColor(bg) + ";\n" + "@define-color theme_unfocused_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color theme_unfocused_base_color " + sanitizeColor(bg) + ";\n" + "@define-color theme_unfocused_text_color " + sanitizeColor(fg) + ";\n" + "@define-color theme_unfocused_selected_bg_color " + sanitizeColor(purple) + ";\n" + "@define-color theme_unfocused_selected_fg_color " + sanitizeColor(bg) + ";\n" + "@define-color bg_color " + sanitizeColor(bg) + ";\n" + "@define-color fg_color " + sanitizeColor(fg) + ";\n" + "@define-color base_color " + sanitizeColor(bg) + ";\n" + "@define-color text_color " + sanitizeColor(fg) + ";\n" + "@define-color selected_bg_color " + sanitizeColor(purple) + ";\n" + "@define-color selected_fg_color " + sanitizeColor(bg) + ";\n" + "@define-color borders " + gtkBorder + ";\n" + "@define-color border_color " + gtkBorder + ";\n" + "@define-color unfocused_borders " + gtkBorder + ";\n" + "@define-color unfocused_border_color " + gtkBorder + ";\n" + "@define-color wm_border_color " + gtkBorder + ";\n" + "@define-color window_outline_color " + gtkBorder + ";\n" + "@define-color headerbar_bg_color " + sanitizeColor(bgSecondary) + ";\n" + "@define-color headerbar_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color titlebar_bg_color " + sanitizeColor(bgSecondary) + ";\n" + "@define-color titlebar_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color titlebar_text_color " + sanitizeColor(fg) + ";\n" + "@define-color titlebar_unfocused_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color titlebar_unfocused_text_color " + sanitizeColor(fg) + ";\n" + "@define-color sidebar_bg_color " + sanitizeColor(bgSecondary) + ";\n" + "@define-color sidebar_fg_color " + sanitizeColor(fg) + ";\n" + "@define-color tooltip_bg_color " + sanitizeColor(bgSecondary) + ";\n" + "@define-color tooltip_fg_color " + sanitizeColor(fg) + ";\n" + ".background, .background.csd { background-color: " + sanitizeColor(bg) + "; color: " + sanitizeColor(fg) + "; }\n" + ".view, iconview, textview text { background-color: " + sanitizeColor(bg) + "; color: " + sanitizeColor(fg) + "; }\n" + ".gtkstyle-fallback { background-color: " + sanitizeColor(bg) + "; color: " + sanitizeColor(fg) + "; }\n" + "list { background-color: " + sanitizeColor(bg) + "; }\n" + "row { background-color: transparent; }\n";
        let gtk4BaseImport = isDark ? '@import url("' + home + '/.themes/catppuccin-mocha-mauve-standard+default/gtk-4.0/gtk.css");\n' : '@import url("' + home + '/.themes/catppuccin-latte-mauve-standard+default/gtk-4.0/gtk.css");\n';
        let gtk4BaseImportDark = isDark ? '@import url("' + home + '/.themes/catppuccin-mocha-mauve-standard+default/gtk-4.0/gtk-dark.css");\n' : '@import url("' + home + '/.themes/catppuccin-latte-mauve-standard+default/gtk-4.0/gtk-dark.css");\n';
        let gtk4CssContent = gtk4BaseImport + gtk4Css;
        let gtk4CssContentDark = gtk4BaseImportDark + gtk4Css;
        let themeDir = home + "/.themes/" + gtkThemeName + "/gtk-4.0";
        let bashCmd = "rm -rf '" + configDir + "/assets' '" + configDir + "/gtk.css' '" + configDir + "/gtk-dark.css'; " + "ln -sf '" + themeDir + "/assets' '" + configDir + "/assets'; " + "cat > '" + configDir + "/gtk.css' << 'GTKCSSEOF'\n" + gtk4CssContent + "GTKCSSEOF\n" + "cat > '" + configDir + "/gtk-dark.css' << 'GTKCSSEOF'\n" + gtk4CssContentDark + "GTKCSSEOF\n" + "cat > '" + gtk3File + "' << 'GTK3CSSEOF'\n" + gtk3Css + "GTK3CSSEOF\n" + "sed -i 's/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=" + darkVal + "/' '" + home + "/.config/gtk-3.0/settings.ini' '" + configDir + "/settings.ini' 2>/dev/null; " + "sed -i 's/^gtk-theme-name=.*/gtk-theme-name=" + gtkThemeName + "/' '" + home + "/.config/gtk-3.0/settings.ini' '" + configDir + "/settings.ini' 2>/dev/null; " + "gsettings set org.gnome.desktop.interface color-scheme '" + gsVal + "'; " + "gsettings set org.gnome.desktop.interface gtk-theme '" + gtkThemeName + "'; killall -q nautilus || true;";
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

    function getSolidBorder(c, isDark) {
        let s = sanitizeColor(c);
        let r = 0, g = 0, b = 0;
        if (s.startsWith("#") && s.length === 7) {
            r = parseInt(s.substring(1, 3), 16);
            g = parseInt(s.substring(3, 5), 16);
            b = parseInt(s.substring(5, 7), 16);
        }
        let mixR, mixG, mixB;
        if (isDark) {
            mixR = Math.round(0.85 * r + 0.15 * 255);
            mixG = Math.round(0.85 * g + 0.15 * 255);
            mixB = Math.round(0.85 * b + 0.15 * 255);
        } else {
            mixR = Math.round(0.8 * r);
            mixG = Math.round(0.8 * g);
            mixB = Math.round(0.8 * b);
        }
        let hexR = mixR.toString(16).padStart(2, '0');
        let hexG = mixG.toString(16).padStart(2, '0');
        let hexB = mixB.toString(16).padStart(2, '0');
        return "#" + hexR + hexG + hexB;
    }

    function getBrightness(c) {
        let s = String(c);
        let r = 0, g = 0, b = 0;
        if (s.startsWith("#")) {
            if (s.length === 7) {
                r = parseInt(s.substring(1, 3), 16) / 255;
                g = parseInt(s.substring(3, 5), 16) / 255;
                b = parseInt(s.substring(5, 7), 16) / 255;
            } else if (s.length === 9) {
                r = parseInt(s.substring(3, 5), 16) / 255;
                g = parseInt(s.substring(5, 7), 16) / 255;
                b = parseInt(s.substring(7, 9), 16) / 255;
            } else if (s.length === 4) {
                r = parseInt(s.substring(1, 2) + s.substring(1, 2), 16) / 255;
                g = parseInt(s.substring(2, 3) + s.substring(2, 3), 16) / 255;
                b = parseInt(s.substring(3, 4) + s.substring(3, 4), 16) / 255;
            }
        } else if (typeof c === "object" && c.r !== undefined) {
            r = c.r;
            g = c.g;
            b = c.b;
        }
        return r * 0.299 + g * 0.587 + b * 0.114;
    }

    function applyNvimTheme(schemeName) {
        let nvimTheme = "default";
        let brightness = getBrightness(bg);
        let background = brightness > 0.5 ? "light" : "dark";
        let qs_colors = "vim.g.qs_colors = {\n" + "  bg = \"" + sanitizeColor(bg) + "\",\n" + "  bgSecondary = \"" + sanitizeColor(bgSecondary) + "\",\n" + "  fg = \"" + sanitizeColor(fg) + "\",\n" + "  muted = \"" + sanitizeColor(muted) + "\",\n" + "  cyan = \"" + sanitizeColor(cyan) + "\",\n" + "  purple = \"" + sanitizeColor(purple) + "\",\n" + "  red = \"" + sanitizeColor(red) + "\",\n" + "  yellow = \"" + sanitizeColor(yellow) + "\",\n" + "  blue = \"" + sanitizeColor(blue) + "\",\n" + "  green = \"" + sanitizeColor(green) + "\"\n" + "}\n";
        let luaContent = "vim.opt.background = \"" + background + "\"\n" + qs_colors + "pcall(vim.cmd.colorscheme, \"" + nvimTheme + "\")";
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

    function hyprColor(c, alpha = "") {
        let s = String(c);
        if (s.startsWith("#"))
            s = s.substring(1);

        if (s.length === 8) {
            let a = s.substring(0, 2);
            let rgb = s.substring(2);
            if (alpha !== "")
                return "rgba(" + rgb + alpha + ")";
            else
                return "rgb(" + rgb + ")";
        }
        if (alpha !== "")
            return "rgba(" + s + alpha + ")";
        else
            return "rgb(" + s + ")";
    }

    function applyHyprlandTheme() {
        let home = Quickshell.env("HOME");
        let content = "# Generated by Quickshell Theme service\n" + "$bg = " + hyprColor(bg) + "\n" + "$bg_alpha = " + hyprColor(bg, "ee") + "\n" + "$bgSecondary = " + hyprColor(bgSecondary) + "\n" + "$bgSecondary_alpha = " + hyprColor(bgSecondary, "ee") + "\n" + "$fg = " + hyprColor(fg) + "\n" + "$muted = " + hyprColor(muted) + "\n" + "$muted_alpha = " + hyprColor(muted, "aa") + "\n" + "$cyan = " + hyprColor(cyan) + "\n" + "$purple = " + hyprColor(purple) + "\n" + "$purple_alpha = " + hyprColor(purple, "ee") + "\n" + "$red = " + hyprColor(red) + "\n" + "$red_alpha = " + hyprColor(red, "ee") + "\n" + "$yellow = " + hyprColor(yellow) + "\n" + "$orange = " + hyprColor(orange) + "\n" + "$blue = " + hyprColor(blue) + "\n" + "$green = " + hyprColor(green) + "\n";
        hyprProc.running = false;
        hyprProc.command = ["bash", "-c", "mkdir -p '" + home + "/.config/hypr' && echo '" + content + "' > '" + home + "/.config/hypr/colors.conf'"];
        hyprProc.running = true;
    }

    function applyStarshipTheme() {
        let home = Quickshell.env("HOME");
        let starshipFile = home + "/.config/starship/starship.toml";
        let toml = "# --- Quickshell Palette ---\n[palettes.quickshell]\n" + "bg = \"" + sanitizeColor(bg) + "\"\n" + "bgSecondary = \"" + sanitizeColor(bgSecondary) + "\"\n" + "fg = \"" + sanitizeColor(fg) + "\"\n" + "muted = \"" + sanitizeColor(muted) + "\"\n" + "cyan = \"" + sanitizeColor(cyan) + "\"\n" + "purple = \"" + sanitizeColor(purple) + "\"\n" + "red = \"" + sanitizeColor(red) + "\"\n" + "pink = \"" + sanitizeColor(pink) + "\"\n" + "yellow = \"" + sanitizeColor(yellow) + "\"\n" + "orange = \"" + sanitizeColor(orange) + "\"\n" + "blue = \"" + sanitizeColor(blue) + "\"\n" + "green = \"" + sanitizeColor(green) + "\"\n";
        let bashCmd = "sed -i '/# --- Quickshell Palette ---/,$d' '" + starshipFile + "'; " + "echo '" + toml + "' >> '" + starshipFile + "'";
        starshipProc.running = false;
        starshipProc.command = ["bash", "-c", bashCmd];
        starshipProc.running = true;
    }

    function saveScheme() {
        let obj = {
            "name": currentScheme,
            "generateFromWallpaper": generateFromWallpaper,
            "bg": "" + bg,
            "bgSecondary": "" + bgSecondary,
            "orange": "" + orange,
            "pink": "" + pink,
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

    function generateTheme(wallpaperPath) {
        let home = Quickshell.env("HOME");
        generatorProc.running = false;
        generatorProc.command = ["python3", home + "/.config/quickshell/Scripts/generate_theme.py", wallpaperPath];
        generatorProc.running = true;
    }

    function loadScheme() {
        loader.running = false;
        loader.running = true;
        wallpaperLoader.running = false;
        wallpaperLoader.running = true;
    }

    Component.onCompleted: loadScheme()

    generatorProc: Process {
        id: generatorProc

        onExited: function(exitCode) {
            if (exitCode === 0) {
                root.loadScheme();
                if (root.generateFromWallpaper) {
                    notifyProc.command = ["notify-send", "Color Scheme", "Generated & Applied from Wallpaper", "-i", "color-management", "-a", "Quickshell"];
                    notifyProc.startDetached();
                }
            }
        }

        stderr: StdioCollector {
            id: generatorError
        }

        stdout: StdioCollector {
            id: generatorOutput
        }

    }

    saver: Process {
    }

    loader: Process {
        command: ["cat", Quickshell.env("HOME") + "/.cache/quickshell/colorscheme.json"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    let colors = JSON.parse(loaderOutput.text);
                    if (colors.generateFromWallpaper !== undefined)
                        root.generateFromWallpaper = colors.generateFromWallpaper;

                    if (colors.name)
                        root.currentScheme = colors.name;

                    if (colors.bg)
                        root.bg = colors.bg;

                    if (colors.bgSecondary)
                        root.bgSecondary = colors.bgSecondary;

                    if (colors.orange)
                        root.orange = colors.orange;
                    else if (colors.yellow)
                        root.orange = colors.yellow;
                    if (colors.pink)
                        root.pink = colors.pink;
                    else if (colors.red)
                        root.pink = colors.red;
                    if (colors.fg)
                        root.fg = colors.fg;

                    if (colors.muted)
                        root.muted = colors.muted;

                    if (colors.cyan)
                        root.cyan = colors.cyan;

                    if (colors.purple)
                        root.purple = colors.purple;

                    if (colors.red)
                        root.red = colors.red;

                    if (colors.yellow)
                        root.yellow = colors.yellow;

                    if (colors.blue)
                        root.blue = colors.blue;

                    if (colors.green)
                        root.green = colors.green;

                    let brightness = root.getBrightness(root.bg);
                    root.border = brightness > 0.5 ? Qt.rgba(0, 0, 0, 0.2) : Qt.rgba(1, 1, 1, 0.15);
                    root.applyKittyTheme();
                    root.applyGtkMode();
                    root.applyNvimTheme(root.currentScheme);
                    root.applyYaziTheme();
                    root.applyHyprlandTheme();
                    root.applyStarshipTheme();
                } catch (e) {
                    root.applyScheme(root.themes[0].dark);
                }
            } else {
                root.applyScheme(root.themes[0].dark);
            }
        }

        stdout: StdioCollector {
            id: loaderOutput
        }

    }

    wallpaperLoader: Process {
        command: ["cat", Quickshell.env("HOME") + "/.cache/quickshell/wallpaper_colorscheme.json"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    root.wallpaperColors = JSON.parse(wallpaperLoaderOutput.text);
                } catch (e) {
                }
            }
        }

        stdout: StdioCollector {
            id: wallpaperLoaderOutput
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

    notifyProc: Process {
    }

    hyprProc: Process {
    }

    starshipProc: Process {
    }

}
