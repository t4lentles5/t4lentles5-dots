import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Modules.Bar.Components
import qs.Modules.Bar.Widgets.Calendar
import qs.Modules.Bar.Widgets.KeyboardLayout
import qs.Modules.Bar.Widgets.MainPanel
import qs.Modules.Bar.Widgets.PowerMenu
import qs.Modules.Bar.Widgets.QuickSettings

PanelWindow {
    id: mainBar

    implicitHeight: 45
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 10
        bottom: 10
        left: 10
        right: 10
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.colBg
        radius: 24

        RowLayout {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            ArchButton {
                Layout.leftMargin: 10
                panel: mainPanel
            }

            MusicStatusButton {
            }

        }

        Workspaces {
            anchors.centerIn: parent
        }

        RowLayout {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 15

            KeyboardLayoutButton {
                selector: keyboardLayout
            }

            QuickSettingsButton {
                selector: quickSettings
            }

            BatteryIndicator {
            }

            ClockButton {
                selector: calendar
            }

            PowerButton {
                Layout.rightMargin: 10
                selector: powerMenu
            }

        }

    }

    MainPanel {
        id: mainPanel

        popupId: "mainPanel"
    }

    KeyboardLayout {
        id: keyboardLayout

        popupId: "keyboardLayout"
        anchor.window: mainBar
        anchor.rect.x: mainBar.width - implicitWidth - 220
        anchor.rect.y: mainBar.height
    }

    QuickSettings {
        id: quickSettings

        popupId: "quickSettings"
        anchor.window: mainBar
        anchor.rect.x: mainBar.width - implicitWidth - 50
        anchor.rect.y: mainBar.height
    }

    Calendar {
        id: calendar

        popupId: "calendar"
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
