import QtQuick
import QtQuick.Layouts

Rectangle {
    id: container

    color: theme.colBgSecondary
    radius: 20
    implicitWidth: clockText.implicitWidth + 30
    implicitHeight: 30

    Theme {
        id: theme
    }

    Text {
        id: clockText

        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "󱑍 HH:mm")
        color: theme.colCyan
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
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

}
