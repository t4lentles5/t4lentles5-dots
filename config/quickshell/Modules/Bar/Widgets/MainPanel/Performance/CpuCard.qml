import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

Card {
    id: root

    property string cpuName: "AMD Ryzen"
    property string cpuTemp: "55°C"
    property int cpuUsage: 0

    Process {
        id: cpuInfoProc

        command: ["sh", "-c", "name=$(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2- | xargs | sed 's/ Processor//' | sed 's/ CPU//'); temp=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1); if [ -n \"$temp\" ]; then f=$((temp / 1000)); else f=55; fi; echo \"$name|$f°C\""]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split('|');
                if (parts.length > 0 && parts[0])
                    root.cpuName = parts[0];

                if (parts.length > 1 && parts[1])
                    root.cpuTemp = parts[1];

            }
        }

    }

    Process {
        id: cpuUsageProc

        property int lastIdle: 0
        property int lastTotal: 0

        command: ["sh", "-c", "head -1 /proc/stat"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data || !data.startsWith('cpu'))
                    return ;

                var p = data.trim().split(/\s+/);
                var user = parseInt(p[1]) || 0, nice = parseInt(p[2]) || 0, system = parseInt(p[3]) || 0, idle = parseInt(p[4]) || 0, iowaitVal = parseInt(p[5]) || 0, irq = parseInt(p[6]) || 0, softirq = parseInt(p[7]) || 0;
                var total = user + nice + system + idle + iowaitVal + irq + softirq;
                var idleTime = idle + iowaitVal;
                if (cpuUsageProc.lastTotal > 0) {
                    var td = total - cpuUsageProc.lastTotal, id = idleTime - cpuUsageProc.lastIdle;
                    if (td > 0)
                        root.cpuUsage = Math.round(100 * (td - id) / td);

                }
                cpuUsageProc.lastTotal = total;
                cpuUsageProc.lastIdle = idleTime;
            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuInfoProc.running = true;
            cpuUsageProc.running = true;
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Constants.sizeMd
        spacing: Constants.sizeLg

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeXs

            RowLayout {
                ThemedText {
                    text: " "
                    font.pixelSize: Constants.sizeMd
                    color: Theme.cyan
                    font.bold: true
                }

                ThemedText {
                    text: root.cpuName
                    font.pixelSize: Constants.sizeSm
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            Item {
                Layout.fillHeight: true
            }

            ThemedText {
                text: root.cpuTemp + " Temp"
                color: Theme.muted
                font.pixelSize: Constants.sizeSm - 1
            }

            Rectangle {
                Layout.fillWidth: true
                height: 6
                radius: 3
                color: Theme.border

                Rectangle {
                    width: parent.width * (root.cpuUsage / 100)
                    height: parent.height
                    radius: parent.radius
                    color: Theme.cyan

                    Behavior on width {
                        NumberAnimation {
                            duration: 600
                            easing.type: Easing.OutCubic
                        }

                    }

                }

            }

        }

        ColumnLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            spacing: 0

            ThemedText {
                text: "Usage"
                color: Theme.muted
                font.pixelSize: Constants.sizeSm - 2
                Layout.alignment: Qt.AlignRight
            }

            ThemedText {
                text: root.cpuUsage + "%"
                font.pixelSize: 24
                font.bold: true
                color: Theme.cyan
                Layout.alignment: Qt.AlignRight
            }

        }

    }

}
