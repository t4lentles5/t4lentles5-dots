import QtQuick
import qs.Core

Rectangle {
    id: root

    property string icon: ""
    property int iconSize: Constants.sizeLg
    property color bgColor: Colors.bgSecondary
    property color iconColor: Colors.fg
    property color activeColor: Colors.purple
    property color hoverColor: Colors.purple
    property bool isActive: false
    property bool useText: true
    property real hoverScale: 1.2
    property alias hovered: hoverHandler.hovered

    signal clicked()

    color: bgColor
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
        scale: hoverHandler.hovered ? root.hoverScale : 1

        Behavior on color {
            ColorAnimation {
                duration: Constants.animNormal
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: Constants.animNormal
                easing.type: Easing.OutQuint
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

}
