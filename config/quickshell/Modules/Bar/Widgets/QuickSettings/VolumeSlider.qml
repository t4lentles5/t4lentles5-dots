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
            width: 18
            height: 18
            radius: 9
            color: Theme.colFg
            border.color: Theme.colBlue
            border.width: 2
            visible: volSlider.pressed || volSlider.hovered
        }

    }

    Text {
        text: root.volume + "%"
        color: Theme.colFg
        font.family: Theme.fontFamily
        font.pixelSize: 14
        Layout.preferredWidth: 35
        horizontalAlignment: Text.AlignRight
    }

}
