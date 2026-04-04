import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

IconButton {
    id: root

    property bool muted: false

    icon: muted ? "󰍭" : "󰍬"
    isActive: muted
    activeColor: Colors.muted
    iconColor: Colors.blue
    hoverColor: Colors.blue
    iconSize: Constants.sizeXl
    Component.onCompleted: micCheckProc.running = true
    onClicked: {
        micToggleProc.running = false;
        micToggleProc.running = true;
    }

    Process {
        id: micCheckProc

        command: ["sh", "-c", "pamixer --default-source --get-mute"]

        stdout: SplitParser {
            onRead: (data) => {
                const val = data.trim();
                if (val !== "")
                    root.muted = (val === "true");

            }
        }

    }

    Process {
        id: micToggleProc

        command: ["sh", "-c", "pamixer --default-source -t"]
        onExited: (code) => {
            if (code === 0) {
                micCheckProc.running = false;
                micCheckProc.running = true;
            }
        }
    }

}
