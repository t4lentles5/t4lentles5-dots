import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Modules.Bar.Components
import qs.Modules.Bar.Widgets.Calendar
import qs.Modules.Bar.Widgets.Dashboard
import qs.Modules.Bar.Widgets.KeyboardLayout
import qs.Modules.Bar.Widgets.MusicPlayer
import qs.Modules.Bar.Widgets.NotificationCenter
import qs.Modules.Bar.Widgets.PowerMenu
import qs.Modules.Bar.Widgets.QuickSettings
import qs.Modules.Bar.Widgets.SystemTray

PanelWindow {
    id: mainBar

    required property var notificationService

    implicitHeight: 48
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 8
        bottom: 0
        left: 8
        right: 8
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        radius: 22

        RowLayout {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: Constants.sizeXs
            anchors.leftMargin: 8

            ArchButton {
                widget: dashboard
            }

            Workspaces {
            }

        }

        MusicStatusButton {
            widget: musicPlayer
            anchors.centerIn: parent
        }

        RowLayout {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: Constants.sizeXs
            anchors.rightMargin: 8

            ClockButton {
                widget: calendar
            }

            BatteryIndicator {
                notificationService: mainBar.notificationService
            }

            KeyboardLayoutButton {
                widget: keyboardLayout
            }

            QuickSettingsButton {
                widget: quickSettings
            }

            NotificationsButton {
                notificationService: mainBar.notificationService
                widget: notificationCenter
            }

            SystemTrayButton {
                widget: systemTray
            }

            PowerButton {
                widget: powerMenu
            }

        }

    }

    Dashboard {
        id: dashboard

        popupId: "dashboard"
        anchor.window: mainBar
        anchor.rect.x: (mainBar.width / 2) - (implicitWidth / 2)
        anchor.rect.y: mainBar.height
    }

    MusicPlayer {
        id: musicPlayer

        popupId: "musicPlayer"
        anchor.window: mainBar
        anchor.rect.x: (mainBar.width / 2) - (implicitWidth / 2)
        anchor.rect.y: mainBar.height
    }

    Calendar {
        id: calendar

        popupId: "calendar"
        anchor.window: mainBar
        anchor.rect.x: mainBar.width - implicitWidth - 260
        anchor.rect.y: mainBar.height
    }

    KeyboardLayout {
        id: keyboardLayout

        popupId: "keyboardLayout"
        anchor.window: mainBar
        anchor.rect.x: mainBar.width - implicitWidth - 165
        anchor.rect.y: mainBar.height
    }

    QuickSettings {
        id: quickSettings

        popupId: "quickSettings"
        anchor.window: mainBar
        anchor.rect.x: mainBar.width - implicitWidth - 15
        anchor.rect.y: mainBar.height
    }

    NotificationCenter {
        id: notificationCenter

        notificationService: mainBar.notificationService
        popupId: "notificationCenter"
        anchor.window: mainBar
        anchor.rect.x: mainBar.width - implicitWidth - 15
        anchor.rect.y: mainBar.height
    }

    SystemTray {
        id: systemTray

        popupId: "systemTray"
        anchor.window: mainBar
        anchor.rect.x: mainBar.width - implicitWidth - 15
        anchor.rect.y: mainBar.height
    }

    PowerMenu {
        id: powerMenu

        popupId: "powerMenu"
        anchor.window: mainBar
        anchor.rect.x: mainBar.width - implicitWidth - 15
        anchor.rect.y: mainBar.height
    }

}
