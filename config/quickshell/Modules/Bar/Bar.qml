import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Modules.Bar.Components
import qs.Modules.Bar.Widgets.KeyboardLayout
import qs.Modules.Bar.Widgets.MainPanel

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
                id: kbLayoutBtn

                selector: keyboardLayout
            }

            QuickSettingsButton {
            }

            ClockButton {
            }

            NotificationsButton {
            }

            PowerButton {
                Layout.rightMargin: 10
            }

        }

    }

    MainPanel {
        id: mainPanel
    }

    KeyboardLayout {
        id: keyboardLayout

        anchor.window: mainBar
        anchor.rect.x: mainBar.width - implicitWidth - 200
        anchor.rect.y: mainBar.height
    }

}
