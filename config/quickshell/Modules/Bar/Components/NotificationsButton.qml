import QtQuick
import qs.Core

Rectangle {
    color: Theme.colBgSecondary
    radius: 20
    implicitWidth: icon.implicitWidth + 30
    implicitHeight: 30

    Text {
        id: icon

        text: "󰂚"
        anchors.centerIn: parent
        color: Theme.colPurple
        font.pixelSize: Theme.fontSize
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
    }

}
