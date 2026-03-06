import QtQuick
import qs.Core

Rectangle {
    property var widget

    color: mouseArea.containsMouse ? Theme.colBgSecondary : "transparent"
    radius: Theme.radiusLg
    implicitWidth: icon.implicitWidth + 24
    implicitHeight: 30

    ThemedText {
        id: icon

        text: "⏻"
        color: Theme.colRed
        font.pixelSize: Theme.fontSizeLg
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (widget)
                widget.isOpen = !widget.isOpen;

        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.animNormal
        }

    }

}
