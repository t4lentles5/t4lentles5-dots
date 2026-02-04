import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Item {
    id: root

    property int batteryLevel: 0
    property string batteryStatus: "Discharging"

    implicitHeight: 60

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batLevelProc.running = true;
            batStatusProc.running = true;
        }
    }

    Process {
        id: batLevelProc

        command: ["cat", "/sys/class/power_supply/BAT1/capacity"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    root.batteryLevel = parseInt(data.trim()) || 0;

            }
        }

    }

    Process {
        id: batStatusProc

        command: ["cat", "/sys/class/power_supply/BAT1/status"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    root.batteryStatus = data.trim();

            }
        }

    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 20

        Text {
            Layout.alignment: Qt.AlignVCenter
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
            color: root.batteryLevel < 20 && root.batteryStatus !== "Charging" ? Theme.colRed : (root.batteryStatus === "Charging" ? Theme.colGreen : Theme.colCyan)
            font.family: Theme.fontFamily
            font.pixelSize: 32
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Battery"
                    color: Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: root.batteryLevel + "%"
                    color: Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 8
                color: Theme.colBg
                radius: 4

                Rectangle {
                    width: (root.batteryLevel / 100) * parent.width
                    height: parent.height
                    color: root.batteryStatus === "Charging" ? Theme.colGreen : (root.batteryLevel < 20 ? Theme.colRed : Theme.colCyan)
                    radius: 4

                    Behavior on width {
                        NumberAnimation {
                            duration: 500
                            easing.type: Easing.OutQuad
                        }

                    }

                }

            }

            Text {
                text: "Charging..."
                visible: root.batteryStatus === "Charging"
                color: Theme.colMuted
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }

        }

    }

}
