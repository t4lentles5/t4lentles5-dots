import QtQuick
import QtQuick.Layouts
import qs.Core

Rectangle {
    property var selector

    color: Theme.colBgSecondary
    radius: 20
    implicitWidth: clockText.implicitWidth + 30
    implicitHeight: 30

    Text {
        id: clockText

        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "  HH:mm")
        color: Theme.colCyan
        font.pixelSize: Theme.fontSize
        font.family: Theme.fontFamily
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
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (selector)
                selector.isOpen = !selector.isOpen;

        }
    }

}
