import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

RowLayout {
    id: root

    signal closeRequested()

    Rectangle {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        radius: 20
        color: wallHover.hovered ? Theme.colBgLighter : Theme.colBg
        clip: true

        HoverHandler {
            id: wallHover
        }

        Text {
            anchors.centerIn: parent
            text: ""
            color: Theme.colGreen
            font.family: Theme.fontFamily
            font.pixelSize: 20
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
        }

    }

}
