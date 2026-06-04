import QtQuick
import qs.Core

Rectangle {
    id: root

    property string icon: ""
    property int iconSize: Constants.sizeLg
    property color bgColor: Theme.bgSecondary
    property color iconColor: Theme.fg
    property color activeColor: Theme.purple
    property color hoverColor: iconColor
    property bool isActive: false
    property bool useText: true
    property alias hovered: hoverHandler.hovered
    property bool useBorder: true

    signal clicked()

    color: {
        if (hoverColor.a === 0)
            return bgColor;

        if (tapHandler.pressed)
            return bgColor.a === 0 ? Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.25) : Qt.tint(bgColor, Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.25));
        else if (hoverHandler.hovered)
            return bgColor.a === 0 ? Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.15) : Qt.tint(bgColor, Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.15));
        return bgColor;
    }
    scale: tapHandler.pressed ? 0.95 : 1
    radius: iconSize
    implicitWidth: iconSize * 2
    implicitHeight: iconSize * 2
    border.color: useBorder ? (isActive ? activeColor : (hoverHandler.hovered ? Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.4) : Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.1))) : Qt.rgba(0, 0, 0, 0)
    border.width: 1

    ThemedText {
        anchors.centerIn: parent
        text: root.icon
        color: {
            if (root.isActive)
                return root.activeColor;

            if (hoverHandler.hovered && root.hoverColor.a !== 0)
                return root.hoverColor;

            return root.iconColor;
        }
        font.pixelSize: root.iconSize
        visible: root.useText
        scale: hoverHandler.hovered ? 1.15 : 1

        Behavior on scale {
            NumberAnimation {
                duration: Constants.animFast
                easing.type: Easing.OutQuint
            }

        }

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

    Behavior on border.color {
        ColorAnimation {
            duration: Constants.animFast
        }

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
