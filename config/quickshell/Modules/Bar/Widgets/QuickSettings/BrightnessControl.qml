import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
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
    spacing: 10

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            brightGetProc.running = true;
        }
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

    Rectangle {
        width: 40
        height: 40
        radius: Theme.radiusSm
        color: Theme.colBg

        ThemedText {
            anchors.centerIn: parent
            text: "󰃠"
            color: Theme.colCyan
            font.pixelSize: Theme.fontSizeLg
        }

    }

    Slider {
        id: brightSlider

        Layout.fillWidth: true
        from: 0
        to: 100
        value: root.brightness
        onMoved: root.setBrightness(Math.round(value))

        background: Rectangle {
            x: brightSlider.leftPadding
            y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 8
            width: brightSlider.availableWidth
            height: implicitHeight
            radius: 4
            color: Theme.colBg

            Rectangle {
                width: brightSlider.visualPosition * parent.width
                height: parent.height
                color: Theme.colCyan
                radius: 4
            }

        }

        handle: Rectangle {
            x: brightSlider.leftPadding + brightSlider.visualPosition * (brightSlider.availableWidth - width)
            y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
            width: brightSlider.pressed ? 22 : 18
            height: brightSlider.pressed ? 22 : 18
            radius: width / 2
            color: Theme.colFg
            border.color: Theme.colCyan
            border.width: 2
            visible: brightSlider.pressed || brightSlider.hovered

            Behavior on width {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutBack
                }

            }

            Behavior on height {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutBack
                }

            }

        }

    }

    ThemedText {
        text: root.brightness + "%"
        color: Theme.colFg
        font.pixelSize: Theme.fontSizeMd
        Layout.preferredWidth: 35
        horizontalAlignment: Text.AlignRight
    }

}
