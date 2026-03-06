import QtQuick
import QtQuick.Layouts
import qs.Core

Rectangle {
    property var widget

    implicitHeight: 30
    color: mouseArea.containsMouse ? Theme.colBgLighter : Theme.colBgSecondary
    radius: Theme.radiusLg
    implicitWidth: layout.implicitWidth + 30

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: 12

        ThemedText {
            text: " "
            color: Theme.colBlue
            font.pixelSize: Theme.fontSizeMd
        }

        ThemedText {
            text: ""
            color: Theme.colBlue
            font.pixelSize: Theme.fontSizeMd + 2
        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
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
