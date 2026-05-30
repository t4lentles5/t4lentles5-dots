import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

Card {
    id: root

    property int batteryPercentage: 0
    property string batteryStatus: "Unknown"
    property string batPath: ""
    property bool hasBattery: batPath !== ""

    visible: hasBattery
    clip: true
    onBatPathChanged: {
        if (root.batPath !== "") {
            batteryLevelProc.running = true;
            batteryStatusProc.running = true;
        }
    }

    Process {
        id: findBattery

        command: ["sh", "-c", "ls /sys/class/power_supply/ | grep -E 'BAT|battery' | head -n 1"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim() !== "")
                    root.batPath = "/sys/class/power_supply/" + data.trim();

            }
        }

    }

    Process {
        id: batteryLevelProc

        command: ["cat", root.batPath + "/capacity"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim() !== "")
                    root.batteryPercentage = parseInt(data.trim()) || 0;

            }
        }

    }

    Process {
        id: batteryStatusProc

        command: ["cat", root.batPath + "/status"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim() !== "")
                    root.batteryStatus = data.trim();

            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (root.batPath !== "") {
                batteryLevelProc.running = true;
                batteryStatusProc.running = true;
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height * (root.batteryPercentage / 100)
        color: root.batteryStatus === "Charging" ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.15) : (root.batteryPercentage < 20 ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.15) : Qt.rgba(Theme.blueArch.r, Theme.blueArch.g, Theme.blueArch.b, 0.15))

        Behavior on height {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutExpo
            }

        }

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Constants.sizeMd
        spacing: Constants.sizeXs

        ThemedText {
            text: root.batteryStatus === "Charging" ? "󰂄" : "󰁹"
            font.pixelSize: 28
            color: root.batteryStatus === "Charging" ? Theme.green : (root.batteryPercentage < 20 ? Theme.red : Theme.blueArch)
            Layout.alignment: Qt.AlignHCenter
        }

        ThemedText {
            text: "Battery"
            font.pixelSize: Constants.sizeSm - 1
            color: Theme.muted
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            Layout.fillHeight: true
        }

        ThemedText {
            text: root.batteryPercentage + "%"
            font.pixelSize: 22
            font.bold: true
            color: root.batteryStatus === "Charging" ? Theme.green : (root.batteryPercentage < 20 ? Theme.red : Theme.blueArch)
            Layout.alignment: Qt.AlignHCenter
        }

        ThemedText {
            text: root.batteryStatus
            font.pixelSize: Constants.sizeSm - 3
            color: Theme.muted
            Layout.alignment: Qt.AlignHCenter
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

    }

}
