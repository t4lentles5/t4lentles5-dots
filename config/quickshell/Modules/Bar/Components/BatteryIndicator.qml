import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Rectangle {
    id: root

    property int batteryLevel: 0
    property string batteryStatus: "Discharging"
    property bool hasBattery: false
    property string batPath: ""
    property color activeColor: {
        if (root.batteryStatus === "Charging")
            return Theme.colGreen;

        if (root.batteryLevel < 20)
            return Theme.colRed;

        return Theme.colYellow;
    }

    visible: hasBattery && batPath !== ""
    color: Theme.colBgSecondary
    radius: Theme.radiusLg
    implicitHeight: 34
    implicitWidth: mainRow.implicitWidth + 24
    Component.onCompleted: findBattery.running = true

    Process {
        id: findBattery

        command: ["sh", "-c", "ls /sys/class/power_supply/ | grep -E 'BAT|battery' | head -n 1"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim() !== "") {
                    root.batPath = "/sys/class/power_supply/" + data.trim();
                    updateTimer.start();
                }
            }
        }

    }

    Timer {
        id: updateTimer

        interval: 10000
        running: false
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.batPath !== "") {
                batLevelProc.running = true;
                batStatusProc.running = true;
            }
        }
    }

    Process {
        id: batLevelProc

        command: ["cat", root.batPath + "/capacity"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data) {
                    root.batteryLevel = parseInt(data.trim()) || 0;
                    root.hasBattery = true;
                }
            }
        }

    }

    Process {
        id: batStatusProc

        command: ["cat", root.batPath + "/status"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    root.batteryStatus = data.trim();

            }
        }

    }

    RowLayout {
        id: mainRow

        anchors.centerIn: parent
        spacing: Theme.spacingSm

        ThemedText {
            id: batIcon

            text: {
                if (root.batteryStatus === "Charging")
                    return "󰂄";

                if (root.batteryLevel >= 90)
                    return "󰁹";

                if (root.batteryLevel >= 70)
                    return "󰂁";

                if (root.batteryLevel >= 50)
                    return "󰁾";

                if (root.batteryLevel >= 30)
                    return "󰁼";

                if (root.batteryLevel >= 10)
                    return "󰁺";

                return "󰂃";
            }
            color: root.activeColor
            font.pixelSize: Theme.fontSizeMd

            SequentialAnimation on opacity {
                id: breathAnim

                loops: Animation.Infinite
                running: root.batteryStatus === "Charging"
                onRunningChanged: {
                    if (!running)
                        batIcon.opacity = 1;

                }

                NumberAnimation {
                    to: 0.4
                    duration: 1000
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    to: 1
                    duration: 1000
                    easing.type: Easing.InOutSine
                }

            }

        }

        ThemedText {
            text: root.batteryLevel + "%"
            color: root.activeColor
            font.pixelSize: Theme.fontSizeMd
            font.bold: true
            visible: root.batteryLevel > 0
        }

    }

    Behavior on activeColor {
        ColorAnimation {
            duration: Theme.animSlow
            easing.type: Easing.OutQuint
        }

    }

}
