import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

TopPopup {
    id: root

    property var model: [{
        "name": "English",
        "code": "us"
    }, {
        "name": "Español",
        "code": "es"
    }]

    implicitWidth: 280

    Process {
        id: proc
    }

    ColumnLayout {
        id: mainCol

        Layout.fillWidth: true
        spacing: 4

        Repeater {
            model: root.model

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                color: hoverHandler.hovered ? Theme.colBgSecondary : "transparent"
                radius: 6

                Text {
                    anchors.centerIn: parent
                    text: modelData.name
                    color: hoverHandler.hovered ? Theme.colPurple : Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                HoverHandler {
                    id: hoverHandler
                }

                TapHandler {
                    onTapped: {
                        proc.command = ["hyprctl", "keyword", "input:kb_layout", modelData.code];
                        proc.running = true;
                        root.isOpen = false;
                    }
                }

            }

        }

    }

}
