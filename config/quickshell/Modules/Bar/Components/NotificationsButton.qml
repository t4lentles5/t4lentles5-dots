import QtQuick
import qs.Core

BarButton {
    property var notificationService

    text: (notificationService && notificationService.dndEnabled) ? "󰂛" : "󰂚"
    textColor: (notificationService && notificationService.dndEnabled) ? Theme.muted : Theme.purple
    fontSize: Constants.sizeLg

    Rectangle {
        id: indicator

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 6
        anchors.rightMargin: 10
        width: 6
        height: 6
        radius: 3
        color: (notificationService && notificationService.dndEnabled) ? Theme.muted : Theme.red
        visible: notificationService && notificationService.unreadCount > 0
    }

}
