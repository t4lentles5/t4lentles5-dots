import QtQuick
import QtQuick.Layouts
import qs.Core

Rectangle {
    property var widget
    property var notificationService

    color: mouseArea.containsMouse ? Theme.colBgLighter : Theme.colBgSecondary
    radius: Theme.radiusLg
    implicitWidth: notifContent.implicitWidth + 30
    implicitHeight: 30

    RowLayout {
        id: notifContent

        anchors.centerIn: parent
        spacing: Theme.spacingSm

        ThemedText {
            property int count: notificationService ? notificationService.unreadCount : 0
            property bool dnd: notificationService ? notificationService.dndEnabled : false

            text: {
                let icon = dnd ? "󰂛" : (count > 0 ? "󱅫" : "󰂚");
                return `${icon} ${count}`;
            }
            color: dnd ? Theme.colMuted : Theme.colPurple
            font.pixelSize: Theme.fontSizeMd
            font.bold: true
        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (widget)
                widget.isOpen = !widget.isOpen;

        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.animNormal
        }

    }

}
