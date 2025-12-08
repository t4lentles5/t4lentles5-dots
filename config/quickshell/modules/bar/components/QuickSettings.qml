import QtQuick
import QtQuick.Layouts

Rectangle {
    id: container

    color: theme.colBgSecondary
    radius: 20
    implicitWidth: layout.implicitWidth + 30
    implicitHeight: 30

    Theme {
        id: theme
    }

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: 12

        // Icono Wifi
        Text {
            text: "󰤨 "
            color: theme.colBlue
            font.pixelSize: 16
            font.family: theme.fontFamily
        }

        // Icono Bluetooth
        Text {
            text: "󰂯"
            color: theme.colBlue
            font.pixelSize: 16
            font.family: theme.fontFamily
        }

        Text {
            text: "󰁹"
            color: theme.colCyan
            font.pixelSize: 16
            font.family: theme.fontFamily
        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            console.log("Abrir widget de QuickSettings");
        }
    }

}
