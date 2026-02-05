import QtQuick
import qs.Core

Rectangle {
    property var selector

    color: "transparent"
    implicitWidth: icon.implicitWidth + 20
    implicitHeight: icon.implicitHeight

    Text {
        id: icon

        text: "⏻"
        color: Theme.colRed
        font.pixelSize: 18
        font.family: Theme.fontFamily
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (selector)
                selector.isOpen = !selector.isOpen;

        }
    }

}
