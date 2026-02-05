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

    readonly property color activeColor: {
        if (root.batteryStatus === "Charging") return Theme.colGreen;
        if (root.batteryLevel < 20) return Theme.colRed;
        return Theme.colYellow;
    }

    // Solo visible si se encontró una ruta de batería válida
    visible: hasBattery && batPath !== ""
    color: Theme.colBgSecondary
    radius: 20
    implicitHeight: 30
    implicitWidth: mainRow.implicitWidth + 20

    // 1. Buscar la batería al iniciar
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

    // 2. Actualizar datos periódicamente
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
                if (data) root.batteryStatus = data.trim();
            }
        }
    }

    RowLayout {
        id: mainRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: {
                if (root.batteryStatus === "Charging") return "󰂄";
                if (root.batteryLevel >= 90) return "󰁹";
                if (root.batteryLevel >= 70) return "󰂁";
                if (root.batteryLevel >= 50) return "󰁾";
                if (root.batteryLevel >= 30) return "󰁼";
                if (root.batteryLevel >= 10) return "󰁺";
                return "󰂃";
            }
            color: root.activeColor
            font.family: Theme.fontFamily
            font.pixelSize: 16
        }

        Text {
            text: root.batteryLevel + "%"
            color: root.activeColor
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.bold: true
            visible: root.batteryLevel > 0
        }
    }
}