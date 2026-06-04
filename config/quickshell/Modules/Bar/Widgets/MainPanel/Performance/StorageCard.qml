import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

Card {
    id: root

    property string diskName: "Storage - /"
    property int diskUsage: 0
    property real animatedDiskUsage: diskUsage
    property string diskSizeText: "0.0 / 0.0 GiB"

    Process {
        id: diskInfoProc

        command: ["sh", "-c", "dev=$(basename $(findmnt -n -o SOURCE / 2>/dev/null) 2>/dev/null || echo '/'); df -m / | tail -1 | awk -v d=\"$dev\" '{print d \"|\" $2 \"|\" $3}'"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split('|');
                if (parts.length > 2) {
                    root.diskName = "Storage - " + parts[0];
                    var totalMB = parseInt(parts[1]) || 0;
                    var usedMB = parseInt(parts[2]) || 0;
                    var totalGiB = (totalMB / 1024).toFixed(1);
                    var usedGiB = (usedMB / 1024).toFixed(1);
                    root.diskSizeText = usedGiB + " / " + totalGiB + " GiB";
                    root.diskUsage = Math.round(100 * usedMB / (totalMB || 1));
                }
            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            diskInfoProc.running = true;
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
                text: "󰋊"
                font.pixelSize: Constants.sizeMd
                color: Theme.yellow
            }

            ThemedText {
                text: root.diskName
                font.pixelSize: Constants.sizeSm
                font.weight: Font.Bold
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Canvas {
                id: diskCanvas

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
                    if (root.animatedDiskUsage > 0) {
                        ctx.beginPath();
                        ctx.strokeStyle = Theme.yellow;
                        ctx.lineWidth = 5;
                        ctx.lineCap = "round";
                        var angle = (root.animatedDiskUsage / 100) * 2 * Math.PI - 0.5 * Math.PI;
                        ctx.arc(cx, cy, r, -0.5 * Math.PI, angle);
                        ctx.stroke();
                    }
                }
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                Connections {
                    function onAnimatedDiskUsageChanged() {
                        diskCanvas.requestPaint();
                    }

                    target: root
                }

            }

            ThemedText {
                anchors.centerIn: parent
                text: Math.round(root.animatedDiskUsage) + "%"
                font.pixelSize: 20
                font.bold: true
                color: Theme.yellow
            }

        }

        ThemedText {
            text: root.diskSizeText
            font.pixelSize: Constants.sizeSm - 2
            color: Theme.muted
            Layout.alignment: Qt.AlignHCenter
        }

    }

    Behavior on animatedDiskUsage {
        NumberAnimation {
            duration: 600
            easing.type: Easing.OutCubic
        }

    }

}
