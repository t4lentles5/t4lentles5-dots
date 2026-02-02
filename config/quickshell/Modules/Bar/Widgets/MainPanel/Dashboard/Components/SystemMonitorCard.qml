import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import qs.Core

Rectangle {
    id: root

    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0
    property int gpuUsage: 0
    property int cardPadding: 20
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    Layout.preferredHeight: parent.height * 0.55
    color: Theme.colBgSecondary
    radius: 10

    Process {
        id: cpuProc

        command: ["sh", "-c", "head -1 /proc/stat"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split(/\s+/);
                var user = parseInt(parts[1]) || 0;
                var nice = parseInt(parts[2]) || 0;
                var system = parseInt(parts[3]) || 0;
                var idle = parseInt(parts[4]) || 0;
                var iowait = parseInt(parts[5]) || 0;
                var irq = parseInt(parts[6]) || 0;
                var softirq = parseInt(parts[7]) || 0;
                var total = user + nice + system + idle + iowait + irq + softirq;
                var idleTime = idle + iowait;
                if (root.lastCpuTotal > 0) {
                    var totalDiff = total - root.lastCpuTotal;
                    var idleDiff = idleTime - root.lastCpuIdle;
                    if (totalDiff > 0)
                        root.cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff);

                }
                root.lastCpuTotal = total;
                root.lastCpuIdle = idleTime;
            }
        }

    }

    Process {
        id: memProc

        command: ["sh", "-c", "free | grep Mem"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split(/\s+/);
                var total = parseInt(parts[1]) || 1;
                var used = parseInt(parts[2]) || 0;
                root.memUsage = Math.round(100 * used / total);
            }
        }

    }

    Process {
        id: diskProc

        command: ["sh", "-c", "df / | tail -1"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split(/\s+/);
                var percentStr = parts[4] || "0%";
                root.diskUsage = parseInt(percentStr.replace('%', '')) || 0;
            }
        }

    }

    Process {
        id: gpuProc

        command: ["sh", "-c", "if command -v nvidia-smi > /dev/null; then nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits; " + "elif [ -e /sys/class/drm/card0/device/gpu_busy_percent ]; then cat /sys/class/drm/card0/device/gpu_busy_percent; " + "elif [ -e /sys/class/hwmon/hwmon*/device/gpu_busy_percent ]; then cat /sys/class/hwmon/hwmon*/device/gpu_busy_percent | head -n 1; " + "else echo 0; fi"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                let usage = parseInt(data.toString().trim());
                root.gpuUsage = isNaN(usage) ? 0 : usage;
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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: parent.cardPadding
        spacing: 15

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            MonitorGauge {
                label: "CPU"
                icon: ""
                value: root.cpuUsage
                accentColor: Theme.colRed
            }

            MonitorGauge {
                label: "RAM"
                icon: ""
                value: root.memUsage
                accentColor: Theme.colBlue
            }

            MonitorGauge {
                label: "GPU"
                icon: "󰢮"
                value: root.gpuUsage
                accentColor: Theme.colGreen
            }

            MonitorGauge {
                label: "DSK"
                icon: "󰋊"
                value: root.diskUsage
                accentColor: Theme.colPurple
            }

        }

    }

    component MonitorGauge: ColumnLayout {
        id: gaugeRoot

        property string label
        property string icon
        property int value
        property color accentColor

        spacing: 8

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 130
            Layout.preferredHeight: 130

            Shape {
                id: shape

                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: Qt.rgba(Theme.colMuted.r, Theme.colMuted.g, Theme.colMuted.b, 0.2)
                    strokeWidth: 10
                    capStyle: ShapePath.RoundCap

                    PathAngleArc {
                        centerX: 65
                        centerY: 65
                        radiusX: 60
                        radiusY: 60
                        startAngle: 0
                        sweepAngle: 360
                    }

                }

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: gaugeRoot.accentColor
                    strokeWidth: 10
                    capStyle: ShapePath.RoundCap

                    PathAngleArc {
                        centerX: 65
                        centerY: 65
                        radiusX: 60
                        radiusY: 60
                        startAngle: -90
                        sweepAngle: 360 * (gaugeRoot.value / 100)

                        Behavior on sweepAngle {
                            NumberAnimation {
                                duration: 600
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                }

            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    text: gaugeRoot.icon
                    color: gaugeRoot.accentColor
                    font.family: Theme.fontFamily
                    font.pixelSize: 32
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: gaugeRoot.value + "%"
                    color: Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

            }

        }

        Text {
            text: gaugeRoot.label
            color: Theme.colMuted
            font.family: Theme.fontFamily
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
        }

    }

}
