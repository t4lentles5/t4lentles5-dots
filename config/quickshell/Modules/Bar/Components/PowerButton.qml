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
        scale: mouseArea.containsMouse ? 1.2 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }

        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (selector)
                selector.isOpen = !selector.isOpen;

        }
    }

}
