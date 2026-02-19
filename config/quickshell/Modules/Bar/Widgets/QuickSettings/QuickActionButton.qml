import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core

Rectangle {
    id: root

    property string icon: ""
    property color iconColor: Theme.colCyan
    property bool active: false
    property color activeColor: Theme.colYellow
    property alias hovered: hover.hovered

    signal clicked()

    Layout.preferredWidth: 40
    Layout.preferredHeight: 40
    radius: 20
    color: active ? activeColor : (hovered ? Theme.colBgLighter : Theme.colBg)
    scale: mouseArea.pressed ? 0.9 : (hovered ? 1.05 : 1)

    HoverHandler {
        id: hover

        enabled: !root.active
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.active ? Theme.colBg : root.iconColor
        font.family: Theme.fontFamily
        font.pixelSize: 20

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Behavior on scale {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutQuad
        }

    }

    Behavior on color {
        ColorAnimation {
            duration: 200
        }

    }

}
