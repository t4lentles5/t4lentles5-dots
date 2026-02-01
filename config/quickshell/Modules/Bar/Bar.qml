import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Modules.Bar.Components

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
            }

            MusicStatusButton {
            }

        }

        Workspaces {
            anchors.centerIn: parent
        }

        RowLayout {
            //    selector: qsSelector
            //}
            //SystemTray {
            //    selector: trayDrawer
            //}

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 15

            KeyboardLayoutButton {
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

}
