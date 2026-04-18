import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {
    id: root

    property string currentWallpaper: ""
    property bool syncEnabled: true
    property bool useGrowTransition: true
    property var pendingScheme: null
    property Process wallpaperApplyProc
    property Process wallpaperSaveProc
    property Process wallpaperLoader
    property Process randomWallpaperProc

    signal schemeNeededByName(string name)

    function applySchemeWithSync(scheme) {
        if (syncEnabled) {
            pendingScheme = scheme;
            let c = Qt.color(scheme.bg);
            let brightness = c.r * 0.299 + c.g * 0.587 + c.b * 0.114;
            let folder = (brightness <= 0.5) ? "Dark" : "Light";
            randomWallpaperProc.running = false;
            let current = root.currentWallpaper || "";
            let cmdStr = "f=$(find ~/Pictures/Wallpapers/" + folder + " -maxdepth 1 -type f ! -name '" + current + "' 2>/dev/null | shuf -n 1); ";
            cmdStr += "if [ -z \"$f\" ]; then f=$(find ~/Pictures/Wallpapers/" + folder + " -maxdepth 1 -type f 2>/dev/null | shuf -n 1); fi; ";
            cmdStr += "echo \"$f\"";
            randomWallpaperProc.command = ["bash", "-c", cmdStr];
            randomWallpaperProc.running = true;
            return ;
        }
        Theme.applyScheme(scheme);
    }

    function applyWallpaperWithSync(wallpaperName, rawPath, wType) {
        currentWallpaper = wallpaperName;
        saveCurrentWallpaper(wallpaperName);
        applyWallpaper(rawPath);
        if (syncEnabled && wType) {
            let isTargetDark = (wType === "Dark");
            for (let i = 0; i < Theme.themes.length; i++) {
                let th = Theme.themes[i];
                if (th.dark.name === Theme.currentScheme || th.light.name === Theme.currentScheme) {
                    let newScheme = isTargetDark ? th.dark : th.light;
                    if (Theme.currentScheme !== newScheme.name)
                        Theme.applyScheme(newScheme);

                    break;
                }
            }
        }
    }

    function applyWallpaper(rawPath) {
        let transition = useGrowTransition ? "grow" : "outer";
        wallpaperApplyProc.running = false;
        if (useGrowTransition)
            wallpaperApplyProc.command = ["awww", "img", rawPath, "--transition-type", transition, "--transition-pos", "0.5,0.5", "--transition-step", "120"];
        else
            wallpaperApplyProc.command = ["awww", "img", rawPath, "--transition-type", transition, "--transition-step", "120"];
        wallpaperApplyProc.startDetached();
        useGrowTransition = !useGrowTransition;
    }

    function saveCurrentWallpaper(wallName) {
        wallpaperSaveProc.running = false;
        wallpaperSaveProc.command = ["bash", "-c", "mkdir -p ~/.cache/quickshell && echo '" + wallName + "' > ~/.cache/quickshell/current_wallpaper"];
        wallpaperSaveProc.startDetached();
    }

    Component.onCompleted: {
        wallpaperLoader.running = true;
    }

    randomWallpaperProc: Process {
        id: randomWallpaperProc

        property string resultPath: ""

        onExited: function(exitCode) {
            if (exitCode === 0 && resultPath !== "") {
                let parts = resultPath.split('/');
                let wallName = parts[parts.length - 1];
                root.currentWallpaper = wallName;
                root.saveCurrentWallpaper(wallName);
                root.applyWallpaper(resultPath);
            } else {
                console.log("No wallpaper found or error: " + exitCode);
            }
            if (root.pendingScheme) {
                Theme.applyScheme(root.pendingScheme);
                root.pendingScheme = null;
            }
            resultPath = "";
        }

        stdout: SplitParser {
            onRead: function(data) {
                let name = data.trim();
                if (name)
                    randomWallpaperProc.resultPath = name;

            }
        }

    }

    wallpaperApplyProc: Process {
    }

    wallpaperSaveProc: Process {
    }

    wallpaperLoader: Process {
        command: ["bash", "-c", "cat ~/.cache/quickshell/current_wallpaper 2>/dev/null"]
        onExited: function(exitCode) {
        }

        stdout: SplitParser {
            onRead: function(data) {
                let name = data.trim();
                if (name)
                    root.currentWallpaper = name;

            }
        }

    }

}
