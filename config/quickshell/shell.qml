import Quickshell
import qs.Modules.Bar
import qs.Modules.Clipboard
import qs.Modules.ColorSchemeSelector
import qs.Modules.KeybindsCheatSheet
import qs.Modules.Launcher
import qs.Modules.Notifications
import qs.Modules.Screenshot
import qs.Modules.WallpaperSelector
import qs.Services.System

ShellRoot {
    NotificationService {
        id: globalNotificationService
    }

    Bar {
        notificationService: globalNotificationService
    }

    Launcher {
    }

    Clipboard {
    }

    WallpaperSelector {
    }

    Screenshot {
    }

    KeybindsCheatSheet {
    }

    ColorSchemeSelector {
    }

    NotificationOverlay {
        notificationService: globalNotificationService
    }

}
