import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import qs.Core

BarButton {
    id: container

    property string layoutName: ""

    function updateLayout(rawName) {
        if (rawName.includes("English"))
            container.layoutName = "US";
        else if (rawName.includes("Spanish"))
            container.layoutName = "ES";
        else
            container.layoutName = rawName.substring(0, 2).toUpperCase();
    }

    text: "  " + container.layoutName
    textColor: Theme.fg

    Connections {
        function onRawEvent(event) {
            if (event.name === "activelayout")
                kbdProc.running = true;

        }

        target: Hyprland
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
                }
            }
        }

    }

}
