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
    spacing: 10

    Slider {
        id: volSlider

        Layout.fillWidth: true
        from: 0
        to: 100
        value: root.volume
        onMoved: root.moved(Math.round(value))

        background: Rectangle {
            x: volSlider.leftPadding
            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 8
            width: volSlider.availableWidth
            height: implicitHeight
            radius: 4
            color: Theme.colBg

            Rectangle {
                width: volSlider.visualPosition * parent.width
                height: parent.height
                color: Theme.colBlue
                radius: 4
            }

        }

        handle: Rectangle {
            x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
            width: volSlider.pressed ? 22 : 18
            height: volSlider.pressed ? 22 : 18
            radius: width / 2
            color: Theme.colFg
            border.color: Theme.colBlue
            border.width: 2
            visible: volSlider.pressed || volSlider.hovered

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
        text: root.volume + "%"
        color: Theme.colFg
        font.pixelSize: Theme.fontSizeMd
        Layout.preferredWidth: 35
        horizontalAlignment: Text.AlignRight
    }

}
