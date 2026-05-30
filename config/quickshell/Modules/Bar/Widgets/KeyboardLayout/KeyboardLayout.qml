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
    property string currentCode: ""

    implicitWidth: 200

    Connections {
        function onIsOpenChanged() {
            if (root.isOpen)
                activeLayoutProc.running = true;

        }

        target: root
    }

    Process {
        id: proc
    }

    Process {
        id: activeLayoutProc

        command: ["sh", "-c", "hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap'"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                let raw = data.trim();
                if (raw.includes("English"))
                    root.currentCode = "us";
                else if (raw.includes("Spanish"))
                    root.currentCode = "latam";
            }
        }

    }

    ColumnLayout {
        id: mainCol

        Layout.fillWidth: true
        spacing: Constants.sizeXs

        Repeater {
            model: root.model

            Item {
                id: delegateRoot

                readonly property bool isHovered: hoverHandler.hovered
                readonly property bool isPressed: tapHandler.pressed

                Layout.fillWidth: true
                Layout.preferredHeight: 30
                scale: isPressed ? 0.95 : 1

                Rectangle {
                    anchors.fill: parent
                    radius: Constants.sizeXs
                    color: Theme.purple
                    opacity: isPressed ? 0.25 : (isHovered ? 0.15 : 0)

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Constants.animNormal
                        }

                    }

                }

                ThemedText {
                    anchors.centerIn: parent
                    text: modelData.name
                    color: (modelData.code === root.currentCode) ? Theme.purple : Theme.fg

                    Behavior on color {
                        ColorAnimation {
                            duration: Constants.animNormal
                        }

                    }

                }

                HoverHandler {
                    id: hoverHandler
                }

                TapHandler {
                    id: tapHandler

                    onTapped: {
                        if (modelData.code === root.currentCode) {
                            root.isOpen = false;
                            return ;
                        }
                        proc.command = ["sh", "-c", `hyprctl keyword input:kb_layout ${modelData.code} && notify-send -i input-keyboard "Keyboard Layout" "Switched to ${modelData.code}"`];
                        proc.running = true;
                        root.isOpen = false;
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Constants.animFast
                        easing.type: Easing.OutBack
                    }

                }

            }

        }

    }

}
