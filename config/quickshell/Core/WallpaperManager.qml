import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
pragma Singleton

QtObject {
    id: root

    property string currentWallpaper: ""
    property string currentWallpaperPath: ""
    property bool useGrowTransition: true
    property Process wallpaperApplyProc
    property Process wallpaperSaveProc
    property Process wallpaperLoader

    function applyWallpaperWithSync(wallpaperName, rawPath) {
        currentWallpaper = wallpaperName;
        currentWallpaperPath = rawPath;
        saveCurrentWallpaper(wallpaperName);
        applyWallpaper(rawPath);
        Theme.generateTheme(rawPath);
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
                if (name) {
                    root.currentWallpaper = name;
                    root.currentWallpaperPath = Quickshell.env("HOME") + "/Pictures/Wallpapers/" + name;
                }
            }
        }

    }

}
