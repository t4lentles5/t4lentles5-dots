import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

IconButton {
    id: root

    property int volume: 0
    property bool muted: false

    function setVolume(val) {
        volSetProc.command = ["pamixer", "--set-volume", val.toString()];
        volSetProc.running = true;
        root.volume = val;
    }

    function toggleMute() {
        volSetProc.command = ["pamixer", "--toggle-mute"];
        volSetProc.running = true;
        muteGetProc.running = true;
        volNotifyProc.command = ["notify-send", "-a", "System", "-i", Constants.iconPath.replace("file://", "") + (root.muted ? "audio-volume-high.svg" : "audio-volume-muted.svg"), "Volume", root.muted ? "Unmuted" : "Muted", "-t", "1500"];
        volNotifyProc.running = true;
    }

    iconSize: Constants.sizeXl
    icon: muted ? "󰝟" : "󰕾"
    iconColor: muted ? Theme.muted : Theme.cyan
    hoverColor: muted ? Theme.muted : Theme.cyan
    onClicked: root.toggleMute()

    Process {
        id: volNotifyProc
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            volGetProc.running = true;
            muteGetProc.running = true;
        }
    }

    Process {
        id: volGetProc

        command: ["pamixer", "--get-volume"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim() !== "")
                    root.volume = parseInt(data.trim());

            }
        }

    }

    Process {
        id: muteGetProc

        command: ["pamixer", "--get-mute"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    root.muted = (data.trim() === "true");

            }
        }

    }

    Process {
        id: volSetProc
    }

}
