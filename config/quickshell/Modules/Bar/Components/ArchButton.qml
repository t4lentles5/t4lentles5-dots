import QtQuick
import qs.Core

Rectangle {
    color: "transparent"
    implicitWidth: icon.implicitWidth + 20
    implicitHeight: icon.implicitHeight

    Text {
        id: icon

        text: "󰣇 "
        color: Theme.colBlueArch
        font.pixelSize: 20
        font.family: Theme.fontFamily
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
    }

}
