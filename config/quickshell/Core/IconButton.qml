import QtQuick
import qs.Core

Rectangle {
    id: root

    property string icon: ""
    property int iconSize: Constants.sizeLg
    property color bgColor: Theme.bgSecondary
    property color iconColor: Theme.fg
    property color activeColor: Theme.purple
    property color hoverColor: Theme.purple
    property bool isActive: false
    property bool useText: true
    property alias hovered: hoverHandler.hovered

    signal clicked()

    color: tapHandler.pressed ? Qt.darker(bgColor, 1.1) : (hoverHandler.hovered ? Qt.lighter(bgColor, 1.2) : bgColor)
    scale: tapHandler.pressed ? 0.95 : 1
    radius: iconSize
    implicitWidth: iconSize * 2
    implicitHeight: iconSize * 2

    ThemedText {
        anchors.centerIn: parent
        text: root.icon
        color: {
            if (root.isActive)
                return root.activeColor;

            if (hoverHandler.hovered)
                return root.hoverColor;

            return root.iconColor;
        }
        font.pixelSize: root.iconSize
        visible: root.useText

        Behavior on color {
            ColorAnimation {
                duration: Constants.animNormal
            }

        }

    }

    HoverHandler {
        id: hoverHandler

        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tapHandler

        onTapped: root.clicked()
    }

    Behavior on color {
        ColorAnimation {
            duration: Constants.animNormal
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: Constants.animFast
            easing.type: Easing.OutBack
        }

    }

}
