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
        micNotifyProc.command = ["notify-send", "-a", "System", "-i", Constants.iconPath.replace("file://", "") + (root.muted ? "microphone-sensitivity-high.svg" : "microphone-sensitivity-muted.svg"), "Microphone", root.muted ? "Unmuted" : "Muted", "-t", "1500"];
        micNotifyProc.running = true;
    }

    Process {
        id: micNotifyProc
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
