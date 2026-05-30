import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: root

    required property var notificationService

    function getSystemFontIcon(iconPath) {
        if (!iconPath)
            return "";

        let path = iconPath.toString();
        if (path.includes("microphone-sensitivity-high"))
            return "󰍬";

        if (path.includes("microphone-sensitivity-muted"))
            return "󰍭";

        if (path.includes("preferences-system-bluetooth-active"))
            return "󰂯";

        if (path.includes("preferences-system-bluetooth-inactive"))
            return "󰂲";

        if (path.includes("weather-clear-night"))
            return "󰖔";

        if (path.includes("weather-clear"))
            return "󰖙";

        if (path.includes("audio-volume-high"))
            return "󰕾";

        if (path.includes("audio-volume-muted"))
            return "󰝟";

        if (path.includes("network-wireless-connected"))
            return "󰤨";

        if (path.includes("network-wireless-disconnected"))
            return "󰤭";

        if (path.includes("input-keyboard"))
            return "󰌌";

        if (path.includes("battery-good-charging"))
            return "󰂄";

        if (path.includes("battery-good"))
            return "󰁹";

        if (path.includes("battery-full"))
            return "󰁹";

        if (path.includes("battery-caution"))
            return "󰂃";

        if (path.includes("color-management"))
            return "󰏘";

        if (path.includes("system-shutdown"))
            return "";

        if (path.includes("system-reboot"))
            return "";

        if (path.includes("system-suspend"))
            return "󰒲";

        if (path.includes("system-log-out"))
            return "󰍃";

        if (path.includes("accessories-screenshot"))
            return "󰄄";

        if (path.includes("notifications-disabled"))
            return "󰂛";

        if (path.includes("notifications"))
            return "󰂚";

        return "";
    }

    function getSystemFontIconColor(iconPath, fallbackColor) {
        if (!iconPath)
            return fallbackColor;

        let path = iconPath.toString();
        if (path.includes("microphone-sensitivity-high"))
            return Theme.blue;

        if (path.includes("microphone-sensitivity-muted"))
            return Theme.muted;

        if (path.includes("preferences-system-bluetooth-active"))
            return Theme.blue;

        if (path.includes("preferences-system-bluetooth-inactive"))
            return Theme.muted;

        if (path.includes("weather-clear-night"))
            return Theme.yellow;

        if (path.includes("weather-clear"))
            return Theme.yellow;

        if (path.includes("audio-volume-high"))
            return Theme.cyan;

        if (path.includes("audio-volume-muted"))
            return Theme.muted;

        if (path.includes("network-wireless-connected"))
            return Theme.purple;

        if (path.includes("network-wireless-disconnected"))
            return Theme.muted;

        if (path.includes("input-keyboard"))
            return Theme.blue;

        if (path.includes("battery-good-charging"))
            return Theme.green;

        if (path.includes("battery-good"))
            return Theme.yellow;

        if (path.includes("battery-full"))
            return Theme.green;

        if (path.includes("battery-caution"))
            return Theme.red;

        if (path.includes("color-management"))
            return Theme.purple;

        if (path.includes("system-shutdown"))
            return Theme.red;

        if (path.includes("system-reboot"))
            return Theme.yellow;

        if (path.includes("system-suspend"))
            return Theme.blue;

        if (path.includes("system-log-out"))
            return Theme.purple;

        if (path.includes("accessories-screenshot"))
            return Theme.cyan;

        if (path.includes("notifications-disabled"))
            return Theme.muted;

        if (path.includes("notifications"))
            return Theme.purple;

        return fallbackColor;
    }

    screen: Quickshell.screens[0]
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    implicitWidth: 380
    implicitHeight: 1000
    visible: true
    color: "transparent"

    anchors {
        top: true
        right: true
    }

    margins {
        top: 64
        right: 8
    }

    Column {
        id: notificationContainer

        anchors.top: parent.top
        anchors.right: parent.right
        width: parent.width
        spacing: Constants.sizeLg

        Repeater {
            id: notificationList

            model: notificationService ? notificationService.activeList : null

            delegate: Rectangle {
                id: toastRect

                property bool isRemoving: false
                property bool expanded: false
                property real slideOffset: 400

                function closeNotification() {
                    if (isRemoving)
                        return ;

                    isRemoving = true;
                    animInDelayTimer.stop();
                    slideOffset = 400;
                    removalTimer.start();
                }

                width: notificationContainer.width
                height: layout.implicitHeight + Constants.sizeLg * 2 + 4
                color: Theme.bg
                radius: Constants.sizeSm
                border.color: mainMouseArea.containsMouse ? Qt.rgba(Theme.purple.r, Theme.purple.g, Theme.purple.b, 0.4) : Theme.border
                border.width: 1
                layer.enabled: true
                opacity: 1
                Component.onCompleted: {
                    animInDelayTimer.interval = index * Constants.animNormal;
                    animInDelayTimer.start();
                }

                Process {
                    id: actionCommand
                }

                Timer {
                    id: animInDelayTimer

                    repeat: false
                    onTriggered: {
                        if (toastRect.isRemoving)
                            return ;

                        toastRect.slideOffset = 0;
                    }
                }

                Timer {
                    id: removalTimer

                    interval: Constants.animSlow
                    repeat: false
                    onTriggered: {
                        if (notificationService)
                            notificationService.dismissNotification(model.id);

                    }
                }

                MouseArea {
                    id: mainMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: toastRect.closeNotification()
                    onExited: toastRect.color = Theme.bg
                }

                RowLayout {
                    id: layout

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: Constants.sizeLg
                    anchors.leftMargin: Constants.sizeLg
                    anchors.rightMargin: Constants.sizeLg
                    spacing: Constants.sizeLg

                    Rectangle {
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: 4
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        color: "transparent"

                        Image {
                            id: notifImage

                            anchors.fill: parent
                            source: {
                                let img = model.image ? model.image.toString() : "";
                                let ico = model.icon ? model.icon.toString() : "";
                                if (root.getSystemFontIcon(img) !== "" || root.getSystemFontIcon(ico) !== "")
                                    return "";

                                if (model.image)
                                    return model.image;

                                if (model.icon) {
                                    let iconStr = model.icon.toString();
                                    if (iconStr.startsWith("/") || iconStr.startsWith("file://") || iconStr.startsWith("image://"))
                                        return iconStr;

                                    return Quickshell.iconPath(iconStr, true);
                                }
                                return "";
                            }
                            sourceSize: Qt.size(48, 48)
                            visible: false
                            fillMode: Image.PreserveAspectCrop
                        }

                        OpacityMask {
                            anchors.fill: parent
                            source: notifImage
                            visible: notifImage.status === Image.Ready && notifImage.source.toString() !== ""

                            maskSource: Rectangle {
                                width: notifImage.width
                                height: notifImage.height
                                radius: 8
                            }

                        }

                        ThemedText {
                            anchors.centerIn: parent
                            visible: notifImage.status !== Image.Ready || notifImage.source.toString() === ""
                            text: {
                                let img = model.image ? model.image.toString() : "";
                                let ico = model.icon ? model.icon.toString() : "";
                                let sysIcon = root.getSystemFontIcon(img) || root.getSystemFontIcon(ico);
                                if (sysIcon !== "")
                                    return sysIcon;

                                return "󰂚";
                            }
                            color: {
                                let img = model.image ? model.image.toString() : "";
                                let ico = model.icon ? model.icon.toString() : "";
                                let sysColor = root.getSystemFontIconColor(img, "") || root.getSystemFontIconColor(ico, "");
                                if (sysColor !== "")
                                    return sysColor;

                                return Theme.purple;
                            }
                            font.pixelSize: 36
                        }

                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: Constants.sizeMd

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            ThemedText {
                                Layout.fillWidth: true
                                text: model.summary
                                color: Theme.cyan
                                font.pixelSize: Constants.sizeMd
                                font.bold: true
                                wrapMode: Text.Wrap
                            }

                            ThemedText {
                                id: bodyText

                                Layout.fillWidth: true
                                text: model.body
                                wrapMode: Text.Wrap
                                opacity: 0.7
                                maximumLineCount: toastRect.expanded ? 100 : 2
                                elide: Text.ElideRight
                            }

                        }

                        RowLayout {
                            id: actionButtons

                            visible: model.summary === "Power Menu"
                            spacing: Constants.sizeMd

                            Rectangle {
                                id: acceptButton

                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 28
                                color: acceptMouse.containsPress ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.25) : (acceptMouse.containsMouse ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.15) : Theme.bgSecondary)
                                border.color: acceptMouse.containsMouse ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.4) : Theme.border
                                border.width: 1
                                radius: Constants.sizeXs
                                scale: acceptMouse.containsPress ? 0.95 : 1

                                ThemedText {
                                    anchors.centerIn: parent
                                    text: "Accept"
                                    color: Theme.green
                                    font.bold: true
                                    font.pixelSize: Constants.sizeSm
                                }

                                MouseArea {
                                    id: acceptMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    preventStealing: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        actionCommand.command = ["bash", "-c", "kill -USR1 $(cat /tmp/quickshell_power_action.pid 2>/dev/null)"];
                                        actionCommand.startDetached();
                                        toastRect.closeNotification();
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

                            Rectangle {
                                id: cancelButton

                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 28
                                color: cancelMouse.containsPress ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.25) : (cancelMouse.containsMouse ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.15) : Theme.bgSecondary)
                                border.color: cancelMouse.containsMouse ? Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.4) : Theme.border
                                border.width: 1
                                radius: Constants.sizeXs
                                scale: cancelMouse.containsPress ? 0.95 : 1

                                ThemedText {
                                    anchors.centerIn: parent
                                    text: "Cancel"
                                    color: Theme.red
                                    font.bold: true
                                    font.pixelSize: Constants.sizeSm
                                }

                                MouseArea {
                                    id: cancelMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    preventStealing: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        actionCommand.command = ["bash", "-c", "kill -TERM $(cat /tmp/quickshell_power_action.pid 2>/dev/null)"];
                                        actionCommand.startDetached();
                                        toastRect.closeNotification();
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

                        }

                    }

                }

                IconButton {
                    id: expandButton

                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: Constants.sizeXs
                    icon: toastRect.expanded ? "" : ""
                    iconSize: Constants.sizeMd
                    visible: bodyText.truncated || toastRect.expanded
                    iconColor: Theme.muted
                    onClicked: {
                        toastRect.expanded = !toastRect.expanded;
                    }
                }

                Rectangle {
                    id: progressTrack

                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottomMargin: 0
                    anchors.leftMargin: Constants.sizeSm
                    anchors.rightMargin: Constants.sizeSm
                    height: 4
                    radius: 2
                    color: Qt.rgba(Theme.purple.r, Theme.purple.g, Theme.purple.b, 0.15)
                    visible: true

                    Rectangle {
                        id: progressBar

                        height: parent.height
                        radius: 2
                        color: Theme.purple
                        width: parent.width

                        NumberAnimation on width {
                            id: progressAnim

                            to: 0
                            duration: model.summary === "Power Menu" ? 10000 : 5000
                            running: toastRect.slideOffset === 0 && !toastRect.isRemoving && !toastRect.expanded
                            paused: mainMouseArea.containsMouse || toastRect.expanded
                            onFinished: {
                                if (!toastRect.isRemoving)
                                    toastRect.closeNotification();

                            }
                        }

                    }

                }

                transform: Translate {
                    x: toastRect.slideOffset

                    Behavior on y {
                        NumberAnimation {
                            duration: Constants.animNormal
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                Behavior on height {
                    NumberAnimation {
                        duration: Constants.animSlow
                        easing.type: Easing.OutExpo
                    }

                }

                Behavior on slideOffset {
                    NumberAnimation {
                        duration: Constants.animSlow
                        easing.type: Easing.OutExpo
                    }

                }

            }

        }

        move: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: Constants.animSlow
                easing.type: Easing.OutExpo
            }

        }

    }

    mask: Region {
        x: 0
        y: 0
        width: root.width
        height: root.height
        intersection: Intersection.Xor

        Region {
            x: 0
            y: 0
            width: root.width
            height: notificationContainer.height
            intersection: Intersection.Subtract
        }

    }

}
