import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Rectangle {
    id: container

    property string layoutName: ".."

    function updateLayout(rawName) {
        if (rawName.includes("English"))
            container.layoutName = "US";
        else if (rawName.includes("Spanish"))
            container.layoutName = "ES";
        else
            container.layoutName = rawName.substring(0, 2).toUpperCase();
    }

    color: theme.colBgSecondary
    radius: 20
    implicitWidth: layoutText.implicitWidth + 30
    implicitHeight: 30

    Theme {
        id: theme
    }

    Process {
        id: kbdProc

        command: ["sh", "-c", "hyprctl devices -j | jq -c ."]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                try {
                    var devices = JSON.parse(data);
                    var keyboard = devices.keyboards.find((k) => {
                        return k.main === true;
                    }) || devices.keyboards[0];
                    if (keyboard)
                        updateLayout(keyboard.active_keymap);

                } catch (e) {
                    console.log("Error parsing keyboard info: " + e);
                }
            }
        }

    }

    Connections {
        function onRawEvent(event) {
            if (event.name === "activelayout") {
                var parts = event.data.split(",");
                if (parts.length >= 2)
                    updateLayout(parts[1]);

            }
        }

        target: Hyprland
    }

    Text {
        id: layoutText

        anchors.centerIn: parent
        text: "  " + container.layoutName
        color: theme.colFg
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
        }
    }

}
