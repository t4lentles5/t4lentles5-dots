import QtQuick
import qs.Core

Rectangle {
    property var selector

    color: mouseArea.containsMouse ? Theme.colBgSecondary : "transparent"
    radius: 16
    implicitWidth: icon.implicitWidth + 24
    implicitHeight: 30

    Text {
        id: icon

        text: "⏻"
        color: Theme.colRed
        font.pixelSize: 18
        font.family: Theme.fontFamily
        anchors.centerIn: parent
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

    Behavior on color {
        ColorAnimation {
            duration: 200
        }

    }

}
