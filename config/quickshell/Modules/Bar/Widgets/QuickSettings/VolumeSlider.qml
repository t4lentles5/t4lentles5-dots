import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core

RowLayout {
    id: root

    property int volume: 0
    property bool muted: false

    signal moved(int val)

    Layout.fillWidth: true
    spacing: Constants.sizeSm

    ThemedText {
        text: {
            if (root.muted || root.volume === 0)
                return "󰝟";

            if (root.volume <= 33)
                return "󰕿";

            if (root.volume <= 66)
                return "󰖀";

            return "󰕾";
        }
        color: root.muted ? Theme.border : Theme.blue
        font.pixelSize: Constants.sizeMd
        Layout.preferredWidth: Constants.sizeXl
        horizontalAlignment: Text.AlignHCenter

        Behavior on opacity {
            NumberAnimation {
                duration: Constants.animNormal
            }

        }

    }

    Slider {
        id: volSlider

        Layout.fillWidth: true
        from: 0
        to: 100
        value: root.volume
        onMoved: root.moved(Math.round(value))
        topPadding: Constants.sizeSm
        bottomPadding: Constants.sizeSm

        background: Rectangle {
            x: volSlider.leftPadding
            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 3
            width: volSlider.availableWidth
            height: implicitHeight
            radius: 2
            color: Theme.border

            Rectangle {
                width: Math.max(height, volSlider.visualPosition * parent.width)
                height: parent.height
                color: root.muted ? Theme.border : Theme.blue
                radius: 2

                Behavior on opacity {
                    NumberAnimation {
                        duration: Constants.animNormal
                    }

                }

            }

        }

        handle: Rectangle {
            x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
            implicitWidth: Constants.sizeSm
            implicitHeight: Constants.sizeSm
            radius: 6
            color: root.muted ? Theme.border : Theme.blue
            border.color: Qt.darker(color, 1.2)
            border.width: 1

            Behavior on x {
                NumberAnimation {
                    duration: 100
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Constants.animNormal
                }

            }

        }

    }

    ThemedText {
        text: root.muted ? "muted" : root.volume + "%"
        color: root.muted ? Theme.border : Theme.fg
        font.pixelSize: Constants.sizeSm
        Layout.preferredWidth: 28
        horizontalAlignment: Text.AlignRight
    }

}
