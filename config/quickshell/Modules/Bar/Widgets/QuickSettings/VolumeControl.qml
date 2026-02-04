import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Rectangle {
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
    }

    width: 40
    height: 40
    radius: 20
    color: muted ? Theme.colRed : (volHover.hovered ? Theme.colBgLighter : Theme.colBg)

    HoverHandler {
        id: volHover

        enabled: !root.muted
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

    Text {
        anchors.centerIn: parent
        text: root.muted ? "󰝟" : "󰕾"
        color: root.muted ? Theme.colBg : Theme.colBlue
        font.family: Theme.fontFamily
        font.pixelSize: 20
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleMute()
    }

}
