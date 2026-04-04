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
        "code": "latam"
    }]

    implicitWidth: 200

    Process {
        id: proc
    }

    ColumnLayout {
        id: mainCol

        Layout.fillWidth: true
        spacing: Constants.sizeXs

        Repeater {
            model: root.model

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: hoverHandler.hovered ? Colors.bgSecondary : "transparent"
                radius: Constants.sizeXs

                ThemedText {
                    anchors.centerIn: parent
                    text: modelData.name
                    color: hoverHandler.hovered ? Colors.purple : Colors.fg
                }

                HoverHandler {
                    id: hoverHandler
                }

                TapHandler {
                    onTapped: {
                        let iconPath = Constants.deviceIconPath.toString().replace("file://", "") + "input-keyboard.svg";
                        proc.command = ["sh", "-c", `hyprctl keyword input:kb_layout ${modelData.code} && notify-send -i ${iconPath} "Keyboard Layout" "Switched to ${modelData.code}"`];
                        proc.running = true;
                        root.isOpen = false;
                    }
                }

            }

        }

    }

}
