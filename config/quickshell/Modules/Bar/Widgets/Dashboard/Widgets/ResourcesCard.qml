import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

Rectangle {
    id: root

    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0
    property int gpuUsage: 0
    property int lastCpuIdle: 0
    property int lastCpuTotal: 0
    property bool hasGpu: false

    color: Theme.bgSecondary
    radius: Constants.sizeXs
    implicitWidth: mainLayout.implicitWidth + (Constants.sizeLg * 2)
    implicitHeight: mainLayout.implicitHeight + (Constants.sizeLg * 2)

    Process {
        id: cpuProc

        command: ["sh", "-c", "head -1 /proc/stat"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data || !data.startsWith('cpu'))
                    return ;

                var p = data.trim().split(/\s+/);
                var user = parseInt(p[1]) || 0, nice = parseInt(p[2]) || 0, system = parseInt(p[3]) || 0, idle = parseInt(p[4]) || 0, iowait = parseInt(p[5]) || 0, irq = parseInt(p[6]) || 0, softirq = parseInt(p[7]) || 0;
                var total = user + nice + system + idle + iowait + irq + softirq;
                var idleTime = idle + iowait;
                if (root.lastCpuTotal > 0) {
                    var td = total - root.lastCpuTotal, id = idleTime - root.lastCpuIdle;
                    if (td > 0)
                        root.cpuUsage = Math.round(100 * (td - id) / td);

                }
                root.lastCpuTotal = total;
                root.lastCpuIdle = idleTime;
            }
        }

    }

    Process {
        id: memProc

        command: ["sh", "-c", "free | grep Mem"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var p = data.trim().split(/\s+/);
                root.memUsage = Math.round(100 * (parseInt(p[2]) || 0) / (parseInt(p[1]) || 1));
            }
        }

    }

    Process {
        id: diskProc

        command: ["sh", "-c", "df / | tail -1"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                root.diskUsage = parseInt((data.trim().split(/\s+/)[4] || "0%").replace('%', '')) || 0;
            }
        }

    }

    Process {
        id: gpuProc

        command: ["sh", "-c", "if command -v nvidia-smi > /dev/null; then nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits; elif [ -e /sys/class/drm/card0/device/gpu_busy_percent ]; then cat /sys/class/drm/card0/device/gpu_busy_percent; else echo 'none'; fi"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                var str = data.toString().trim();
                if (str === "none" || str === "") {
                    root.hasGpu = false;
                } else {
                    root.hasGpu = true;
                    root.gpuUsage = parseInt(str) || 0;
                }
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

    RowLayout {
        id: mainLayout

        anchors.fill: parent
        spacing: Constants.sizeLg
        anchors.margins: Constants.sizeLg

        CircularGauge {
            label: " CPU"
            value: root.cpuUsage
            accentColor: Theme.cyan
        }

        CircularGauge {
            label: " RAM"
            value: root.memUsage
            accentColor: Theme.purple
        }

        CircularGauge {
            label: "󰢮 GPU"
            value: root.gpuUsage
            accentColor: Theme.yellow
            visible: root.hasGpu
        }

        CircularGauge {
            label: "󰋊 DISK"
            value: root.diskUsage
            accentColor: Theme.yellow
        }

    }

    component CircularGauge: Item {
        property string label: ""
        property int value: 0
        property color accentColor: Theme.muted

        onValueChanged: canvas.requestPaint()
        implicitWidth: 140
        implicitHeight: 140
        Layout.alignment: Qt.AlignVCenter

        Canvas {
            id: canvas

            anchors.fill: parent
            antialiasing: true
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                var cx = width / 2, cy = height / 2;
                var r = (width - 16) / 2;
                var startAngle = 0.75 * Math.PI;
                var spanAngle = 1.5 * Math.PI;
                ctx.beginPath();
                ctx.strokeStyle = Theme.border;
                ctx.lineWidth = 5;
                ctx.lineCap = "round";
                ctx.arc(cx, cy, r, startAngle, startAngle + spanAngle);
                ctx.stroke();
                if (value > 0) {
                    ctx.beginPath();
                    ctx.strokeStyle = accentColor;
                    ctx.lineWidth = 5;
                    ctx.lineCap = "round";
                    var end = startAngle + (spanAngle * (Math.min(Math.max(value, 0), 100) / 100));
                    ctx.arc(cx, cy, r, startAngle, end);
                    ctx.stroke();
                }
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }

        ThemedText {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -Constants.sizeXs
            text: value + "%"
            font.pixelSize: Constants.sizeLg
            font.weight: Font.Medium
            color: value > 0 ? accentColor : Theme.muted
        }

        ThemedText {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Constants.sizeSm
            text: label
            color: Theme.muted
            font.pixelSize: Constants.sizeSm
            font.letterSpacing: 2
        }

        Behavior on value {
            NumberAnimation {
                duration: 800
                easing.type: Easing.OutExpo
            }

        }

    }

}
