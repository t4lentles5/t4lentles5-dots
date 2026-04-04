import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

RowLayout {
    id: root

    property int brightness: 0

    function setBrightness(val) {
        let finalVal = Math.max(5, val);
        brightSetProc.command = ["brightnessctl", "s", finalVal + "%"];
        brightSetProc.running = true;
        root.brightness = finalVal;
    }

    Layout.fillWidth: true
    spacing: Constants.sizeSm

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: brightGetProc.running = true
    }

    Process {
        id: brightGetProc

        command: ["brightnessctl", "-m"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                var parts = data.split(",");
                if (parts.length >= 4) {
                    var pct = parts[3];
                    if (pct.endsWith("%"))
                        pct = pct.substring(0, pct.length - 1);

                    if (!brightSlider.pressed)
                        root.brightness = parseInt(pct);

                }
            }
        }

    }

    Process {
        id: brightSetProc
    }

    ThemedText {
        text: {
            if (root.brightness <= 33)
                return "󰃞";

            if (root.brightness <= 66)
                return "󰃟";

            return "󰃠";
        }
        color: Colors.yellow
        font.pixelSize: Constants.sizeMd
        Layout.preferredWidth: Constants.sizeXl
        horizontalAlignment: Text.AlignHCenter
    }

    Slider {
        id: brightSlider

        Layout.fillWidth: true
        from: 0
        to: 100
        value: root.brightness
        onMoved: root.setBrightness(Math.round(value))
        topPadding: Constants.sizeSm
        bottomPadding: Constants.sizeSm

        background: Rectangle {
            x: brightSlider.leftPadding
            y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 3
            width: brightSlider.availableWidth
            height: implicitHeight
            radius: 2
            color: Colors.border

            Rectangle {
                width: Math.max(height, brightSlider.visualPosition * parent.width)
                height: parent.height
                color: Colors.yellow
                radius: 2
            }

        }

        handle: Rectangle {
            x: brightSlider.leftPadding + brightSlider.visualPosition * (brightSlider.availableWidth - width)
            y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
            implicitWidth: Constants.sizeSm
            implicitHeight: Constants.sizeSm
            radius: 6
            color: Colors.yellow
            border.color: Qt.darker(color, 1.2)
            border.width: 1

            Behavior on x {
                NumberAnimation {
                    duration: 100
                }

            }

        }

    }

    ThemedText {
        text: root.brightness + "%"
        font.pixelSize: Constants.sizeSm
        Layout.preferredWidth: 28
        horizontalAlignment: Text.AlignRight
    }

}
