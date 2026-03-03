import QtQuick
import qs.Core

Rectangle {
    property var panel

    color: mouseArea.containsMouse ? Theme.colBgSecondary : "transparent"
    radius: 16
    implicitWidth: icon.implicitWidth + 24
    implicitHeight: 30

    Text {
        id: icon

        text: "󰣇"
        color: Theme.colBlueArch
        font.pixelSize: 20
        font.family: Theme.fontFamily
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (parent.panel)
                parent.panel.isOpen = !parent.panel.isOpen;

        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 200
        }

    }

}
