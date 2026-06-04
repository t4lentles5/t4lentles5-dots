import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

Card {
    id: root

    property int memUsage: 0
    property real animatedMemUsage: memUsage
    property string memSizeText: "0.0 / 0.0 GiB"

    Process {
        id: memInfoProc

        command: ["sh", "-c", "free -m | grep Mem"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var p = data.trim().split(/\s+/);
                var totalMB = parseInt(p[1]) || 0;
                var usedMB = parseInt(p[2]) || 0;
                var totalGiB = (totalMB / 1024).toFixed(1);
                var usedGiB = (usedMB / 1024).toFixed(1);
                root.memSizeText = usedGiB + " / " + totalGiB + " GiB";
                root.memUsage = Math.round(100 * usedMB / (totalMB || 1));
            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            memInfoProc.running = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Constants.sizeMd
        spacing: Constants.sizeXs

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Constants.sizeXs

            ThemedText {
                text: " "
                font.pixelSize: Constants.sizeMd
                color: Theme.purple
            }

            ThemedText {
                text: "Memory"
                font.pixelSize: Constants.sizeSm
                font.weight: Font.Bold
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Canvas {
                id: memCanvas

                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var cx = width / 2, cy = height / 2;
                    var r = (Math.min(width, height) - 12) / 2;
                    ctx.beginPath();
                    ctx.strokeStyle = Theme.border;
                    ctx.lineWidth = 5;
                    ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                    ctx.stroke();
                    if (root.animatedMemUsage > 0) {
                        ctx.beginPath();
                        ctx.strokeStyle = Theme.purple;
                        ctx.lineWidth = 5;
                        ctx.lineCap = "round";
                        var angle = (root.animatedMemUsage / 100) * 2 * Math.PI - 0.5 * Math.PI;
                        ctx.arc(cx, cy, r, -0.5 * Math.PI, angle);
                        ctx.stroke();
                    }
                }
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                Connections {
                    function onAnimatedMemUsageChanged() {
                        memCanvas.requestPaint();
                    }

                    target: root
                }

            }

            ThemedText {
                anchors.centerIn: parent
                text: Math.round(root.animatedMemUsage) + "%"
                font.pixelSize: 20
                font.bold: true
                color: Theme.purple
            }

        }

        ThemedText {
            text: root.memSizeText
            font.pixelSize: Constants.sizeSm - 2
            color: Theme.muted
            Layout.alignment: Qt.AlignHCenter
        }

    }

    Behavior on animatedMemUsage {
        NumberAnimation {
            duration: 600
            easing.type: Easing.OutCubic
        }

    }

}
