import QtQuick
import QtQuick.Layouts

Rectangle {
    id: container

    color: theme.colBgSecondary
    radius: 20
    implicitWidth: notifText.implicitWidth + 30
    implicitHeight: 30

    Theme {
        id: theme
    }

    Text {
        id: notifText

        anchors.centerIn: parent
        text: "󰂜 󱅫"
        color: theme.colRed
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
        Layout.maximumWidth: 300
        maximumLineCount: 1
    }

}
