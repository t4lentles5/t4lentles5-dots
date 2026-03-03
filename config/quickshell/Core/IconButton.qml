import QtQuick
import qs.Core

Rectangle {
    id: root

    property string icon: ""
    property int iconSize: 16
    property color iconColor: Theme.colFg
    property color activeColor: Theme.colPurple
    property color hoverColor: Theme.colBgLighter
    property bool isActive: false
    property bool useText: true
    property color baseColor: "transparent"
    readonly property alias hovered: hoverHandler.hovered

    signal clicked()

    width: 30
    height: 30
    radius: 8
    color: hoverHandler.hovered ? hoverColor : baseColor

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.isActive ? root.activeColor : root.iconColor
        font.family: Theme.fontFamily
        font.pixelSize: root.iconSize
        visible: root.useText

        Behavior on color {
            ColorAnimation {
                duration: 250
            }

        }

    }

    HoverHandler {
        id: hoverHandler

        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }

    Behavior on color {
        ColorAnimation {
            duration: 250
        }

    }

}
