import QtQuick
import QtQuick.Layouts
import qs.Core

Rectangle {
    property var selector

    implicitHeight: 30
    color: mouseArea.containsMouse ? Theme.colBgLighter : Theme.colBgSecondary
    radius: 16
    implicitWidth: layout.implicitWidth + 30

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: 12

        Text {
            text: " "
            color: Theme.colBlue
            font.pixelSize: Theme.fontSize
            font.family: Theme.fontFamily
        }

        Text {
            text: ""
            color: Theme.colBlue
            font.pixelSize: Theme.fontSize + 2
            font.family: Theme.fontFamily
        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
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
