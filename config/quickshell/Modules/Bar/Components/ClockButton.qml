import QtQuick
import QtQuick.Layouts
import qs.Core

Rectangle {
    property var widget

    color: mouseArea.containsMouse ? Theme.colBgLighter : Theme.colBgSecondary
    radius: Theme.radiusLg
    implicitWidth: clockText.implicitWidth + 30
    implicitHeight: 30

    ThemedText {
        id: clockText

        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "  HH:mm")
        color: Theme.colCyan
        font.pixelSize: Theme.fontSizeMd
        font.bold: true

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                clockText.text = Qt.formatDateTime(new Date(), "󱑍 HH:mm");
            }
        }

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
