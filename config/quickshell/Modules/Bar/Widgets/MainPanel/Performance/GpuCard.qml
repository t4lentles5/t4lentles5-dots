import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

Card {
    id: root

    property string gpuName: "Detecting..."
    property string gpuTemp: "50°C"
    property int gpuUsage: 0
    property bool hasGpu: gpuName !== "None"

    visible: hasGpu

    Process {
        id: gpuInfoProc

        command: ["sh", "-c", "gpus=$(lspci 2>/dev/null | grep -i -E 'vga|3d'); if [ -z \"$gpus\" ]; then echo \"None|0°C|0\"; exit 0; fi; gpu=$(echo \"$gpus\" | grep -i 'nvidia' | head -n 1); if [ -z \"$gpu\" ]; then gpu=$(echo \"$gpus\" | head -n 1); fi; raw_name=$(echo \"$gpu\" | awk -F'controller: ' '{print $2}' | sed -E 's/ \\(rev .*\\)//g' | sed -E 's/ Corporation//g; s/ Technologies//g'); if echo \"$raw_name\" | grep -q '\\['; then name=$(echo \"$raw_name\" | sed -E 's/^([^ ]+) [^ ]+ \\[(.*)\\].*/\\1 \\2/'); else name=\"$raw_name\"; fi; if command -v nvidia-smi >/dev/null; then t=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null); u=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null); else t=50; u=0; fi; echo \"$name|$t°C|$u\""]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.trim().split('|');
                if (parts.length > 0 && parts[0])
                    root.gpuName = parts[0];

                if (parts.length > 1 && parts[1])
                    root.gpuTemp = parts[1];

                if (parts.length > 2)
                    root.gpuUsage = parseInt(parts[2]) || 0;

            }
        }

    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            gpuInfoProc.running = true;
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
                    text: "󰢮 "
                    font.pixelSize: Constants.sizeMd
                    color: Theme.orange
                    font.bold: true
                }

                ThemedText {
                    text: root.gpuName
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
                text: root.gpuTemp + " Temp"
                color: Theme.muted
                font.pixelSize: Constants.sizeSm - 1
            }

            Rectangle {
                Layout.fillWidth: true
                height: 6
                radius: 3
                color: Theme.border

                Rectangle {
                    width: parent.width * (root.gpuUsage / 100)
                    height: parent.height
                    radius: parent.radius
                    color: Theme.orange

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
                text: root.gpuUsage + "%"
                font.pixelSize: 24
                font.bold: true
                color: Theme.orange
                Layout.alignment: Qt.AlignRight
            }

        }

    }

}
