import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import qs.Core

Item {
    id: root

    property int cpuUsage: 0
    property string cpuInfo: ""
    property int memUsage: 0
    property string memInfo: ""
    property int diskUsage: 0
    property string diskInfo: ""
    property int gpuUsage: 0
    property string gpuInfo: ""
    property int lastCpuIdle: 0
    property int lastCpuTotal: 0

    Process {
        id: cpuProc

        command: ["sh", "-c", "head -1 /proc/stat && lscpu | grep 'CPU MHz' | awk '{print $3}'"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var lines = data.trim().split('\n');
                if (lines[0].startsWith('cpu')) {
                    var parts = lines[0].trim().split(/\s+/);
                    var user = parseInt(parts[1]) || 0, nice = parseInt(parts[2]) || 0, system = parseInt(parts[3]) || 0, idle = parseInt(parts[4]) || 0, iowait = parseInt(parts[5]) || 0, irq = parseInt(parts[6]) || 0, softirq = parseInt(parts[7]) || 0;
                    var total = user + nice + system + idle + iowait + irq + softirq, idleTime = idle + iowait;
                    if (root.lastCpuTotal > 0) {
                        var totalDiff = total - root.lastCpuTotal, idleDiff = idleTime - root.lastCpuIdle;
                        if (totalDiff > 0)
                            root.cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff);

                    }
                    root.lastCpuTotal = total;
                    root.lastCpuIdle = idleTime;
                    if (lines.length > 1 && lines[1] !== "")
                        root.cpuInfo = Math.round(parseFloat(lines[1])) + " MHz";

                }
            }
        }

    }

    Process {
        id: memProc

        command: ["sh", "-c", "free -h | grep Mem"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split(/\s+/);
                var usedStr = parts[2] || "0";
                var totalStr = parts[1] || "1";
                usedStr = usedStr.replace('i', '');
                totalStr = totalStr.replace('i', '');
                root.memInfo = usedStr + " / " + totalStr;
                var usedFloat = parseFloat(usedStr);
                var totalFloat = parseFloat(totalStr);
                var usedFloat = parseFloat(usedStr);
                var totalFloat = parseFloat(totalStr);
                if (totalFloat > 0)
                    root.memUsage = Math.round(100 * usedFloat / totalFloat);
                else
                    root.memUsage = 0;
            }
        }

    }

    Process {
        id: diskProc

        command: ["sh", "-c", "df -h / | tail -1"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data) {
                    var parts = data.trim().split(/\s+/);
                    root.diskUsage = parseInt((parts[4] || "0%").replace('%', '')) || 0;
                    var usedStr = parts[2] || "0";
                    var totalStr = parts[1] || "0";
                    root.diskInfo = usedStr + " / " + totalStr;
                }
            }
        }

    }

    Process {
        id: gpuProc

        command: ["sh", "-c", "if command -v nvidia-smi > /dev/null; then nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits; elif [ -e /sys/class/drm/card0/device/gpu_busy_percent ]; then cat /sys/class/drm/card0/device/gpu_busy_percent; else echo 0; fi"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                var usage = parseInt(data.toString().trim()) || 0;
                root.gpuUsage = usage;
                root.gpuInfo = (usage > 0) ? "Active" : "Idle";
            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;
            memProc.running = true;
            diskProc.running = true;
            gpuProc.running = true;
        }
    }

    Card {
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 2
            Layout.alignment: Qt.AlignCenter

            MonitorGauge {
                label: "CPU"
                icon: ""
                value: root.cpuUsage
                accentColor: Theme.colBlueArch
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
            }

            MonitorGauge {
                label: "RAM"
                icon: ""
                value: root.memUsage
                accentColor: Theme.colGreen
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
            }

            MonitorGauge {
                label: "GPU"
                icon: "󰢮"
                value: root.gpuUsage
                accentColor: Theme.colYellow
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
            }

            MonitorGauge {
                label: "DISK"
                icon: "󰋊"
                value: root.diskUsage
                accentColor: Theme.colPurple
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
            }

        }

    }

    component MonitorGauge: ColumnLayout {
        id: gaugeRoot

        property string label
        property string icon
        property int value
        property color accentColor

        spacing: 0
        Layout.fillWidth: true

        Item {
            Layout.fillHeight: true
        }

        Item {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.preferredWidth: 120

            ColumnLayout {
                anchors.centerIn: parent
                spacing: -30

                Item {
                    id: shapeContainer

                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 120
                    layer.enabled: true
                    layer.samples: 4

                    Shape {
                        id: arcShape

                        anchors.fill: parent

                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: Theme.colBgLighter
                            strokeWidth: 3
                            capStyle: ShapePath.RoundCap

                            PathAngleArc {
                                centerX: 60
                                centerY: 60
                                radiusX: 54
                                radiusY: 54
                                startAngle: 135
                                sweepAngle: 270
                            }

                        }

                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: gaugeRoot.accentColor
                            strokeWidth: 3
                            capStyle: ShapePath.RoundCap

                            PathAngleArc {
                                centerX: 60
                                centerY: 60
                                radiusX: 54
                                radiusY: 54
                                startAngle: 135
                                sweepAngle: 270 * (gaugeRoot.value / 100)

                                Behavior on sweepAngle {
                                    NumberAnimation {
                                        duration: 1000
                                        easing.type: Easing.OutExpo
                                    }

                                }

                            }

                        }

                    }

                    DropShadow {
                        anchors.fill: arcShape
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: gaugeRootHover.containsMouse ? 14 : 0
                        samples: 29
                        color: Qt.rgba(gaugeRoot.accentColor.r, gaugeRoot.accentColor.g, gaugeRoot.accentColor.b, 0.4)
                        source: arcShape

                        Behavior on radius {
                            NumberAnimation {
                                duration: 200
                            }

                        }

                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: -2

                        Text {
                            text: gaugeRoot.value + "%"
                            color: Theme.colFg
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: gaugeRoot.icon
                            color: gaugeRoot.accentColor
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            Layout.alignment: Qt.AlignHCenter
                            opacity: 0.9
                        }

                    }

                    MouseArea {
                        id: gaugeRootHover

                        anchors.fill: parent
                        hoverEnabled: true
                    }

                }

                Text {
                    text: gaugeRoot.label
                    color: Theme.colMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    opacity: gaugeRootHover.containsMouse ? 1 : 0.8

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }

                    }

                }

            }

        }

        Item {
            Layout.fillHeight: true
        }

    }

}
