import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core

TopPopup {
    id: root

    property var notificationService
    property var currentTime: new Date()
    property bool controlCenterOpen: false

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
            return "󰄀";

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

    function timeAgo(date, now) {
        if (!date || isNaN(date.getTime()) || !now || isNaN(now.getTime()))
            return "...";

        let diff = Math.floor((now.getTime() - date.getTime()) / 1000);
        if (diff < 60)
            return "Just now";

        if (diff < 3600)
            return Math.floor(diff / 60) + "m ago";

        if (diff < 86400)
            return Math.floor(diff / 3600) + "h ago";

        return Math.floor(diff / 86400) + "d ago";
    }

    preferredHeight: implicitHeight
    implicitWidth: 400
    onVisibleChanged: {
        if (visible)
            currentTime = new Date();

    }

    Timer {
        interval: 60000
        running: root.visible
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    ColumnLayout {
        id: mainCol

        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Constants.sizeLg

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeXs

            ThemedText {
                text: "NOTIFICATIONS"
                font.pixelSize: Constants.sizeMd
                font.letterSpacing: 2
                color: Theme.cyan
                Layout.fillWidth: true
            }

            IconButton {
                icon: (notificationService && notificationService.dndEnabled) ? "󰂛" : "󰂚"
                iconColor: (notificationService && notificationService.dndEnabled) ? Theme.muted : Theme.blue
                iconSize: Constants.sizeMd
                onClicked: {
                    if (notificationService)
                        notificationService.dndEnabled = !notificationService.dndEnabled;

                }
            }

            IconButton {
                icon: "󰃢"
                iconColor: Theme.red
                iconSize: Constants.sizeMd
                visible: historyView.count > 0
                onClicked: {
                    if (notificationService)
                        notificationService.clearHistory();

                }
            }

        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeXs

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 350

                ThemedText {
                    anchors.centerIn: parent
                    text: "No notifications"
                    color: Theme.muted
                    font.pixelSize: Constants.sizeSm
                    opacity: historyView.count === 0 ? 1 : 0
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Constants.animNormal
                        }

                    }

                }

                ScrollView {
                    anchors.fill: parent
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    clip: true

                    ListView {
                        id: historyView

                        width: parent.width
                        model: notificationService ? notificationService.historyList : null
                        spacing: Constants.sizeXs

                        add: Transition {
                            NumberAnimation {
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: root.visible ? Constants.animSlow : 0
                            }

                        }

                        remove: Transition {
                            NumberAnimation {
                                property: "x"
                                to: historyView.width
                                duration: Constants.animSlow
                                easing.type: Easing.InExpo
                            }

                            NumberAnimation {
                                property: "opacity"
                                to: 0
                                duration: Constants.animSlow
                            }

                        }

                        removeDisplaced: Transition {
                            SequentialAnimation {
                                PauseAnimation {
                                    duration: Constants.animSlow
                                }

                                NumberAnimation {
                                    properties: "y"
                                    duration: Constants.animSlow
                                    easing.type: Easing.OutExpo
                                }

                            }

                        }

                        addDisplaced: Transition {
                            NumberAnimation {
                                properties: "y"
                                duration: root.visible ? Constants.animSlow : 0
                                easing.type: Easing.OutExpo
                            }

                        }

                        delegate: Rectangle {
                            id: delegateRoot

                            property bool expanded: false

                            width: ListView.view.width
                            height: delegateLayout.implicitHeight + Constants.sizeSm * 2
                            color: Theme.bgSecondary
                            radius: Constants.sizeSm
                            border.width: 1
                            border.color: delegateMouseArea.containsMouse ? Qt.rgba(Theme.purple.r, Theme.purple.g, Theme.purple.b, 0.4) : Theme.border

                            MouseArea {
                                id: delegateMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                            }

                            RowLayout {
                                id: delegateLayout

                                anchors.fill: parent
                                anchors.margins: Constants.sizeSm
                                spacing: Constants.sizeSm

                                Rectangle {
                                    Layout.alignment: Qt.AlignTop
                                    Layout.topMargin: 4
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
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
                                                const icoStr = model.icon.toString();
                                                if (icoStr.startsWith("/") || icoStr.startsWith("file://") || icoStr.startsWith("image://"))
                                                    return icoStr;

                                                return Quickshell.iconPath(icoStr, true);
                                            }
                                            return "";
                                        }
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
                                        font.pixelSize: 32
                                    }

                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop
                                    spacing: 2

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Constants.sizeXs

                                        ThemedText {
                                            text: model.summary
                                            color: Theme.cyan
                                            font.pixelSize: Constants.sizeSm
                                            font.weight: Font.Medium
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        ThemedText {
                                            text: {
                                                let ts = model.timestamp;
                                                if (!ts)
                                                    return "Just now";

                                                let n = Number(ts);
                                                let d = new Date(n < 1e+10 ? n * 1000 : n);
                                                return root.timeAgo(d, root.currentTime);
                                            }
                                            color: Theme.muted
                                            font.pixelSize: Constants.sizeSm - 2
                                        }

                                        IconButton {
                                            icon: delegateRoot.expanded ? "" : ""
                                            iconColor: Theme.blue
                                            iconSize: Constants.sizeSm - 2
                                            visible: bodyText.truncated || delegateRoot.expanded
                                            onClicked: {
                                                delegateRoot.expanded = !delegateRoot.expanded;
                                            }
                                        }

                                        IconButton {
                                            icon: ""
                                            iconColor: Theme.red
                                            iconSize: Constants.sizeSm - 2
                                            onClicked: {
                                                if (notificationService)
                                                    notificationService.removeHistoryItem(index);

                                            }
                                        }

                                    }

                                    ThemedText {
                                        id: bodyText

                                        text: model.body
                                        color: Theme.fg
                                        opacity: 0.7
                                        font.pixelSize: Constants.sizeSm - 2
                                        wrapMode: Text.Wrap
                                        Layout.fillWidth: true
                                        maximumLineCount: delegateRoot.expanded ? 100 : 2
                                        elide: Text.ElideRight

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: Constants.animNormal
                                            }

                                        }

                                    }

                                }

                            }

                            Behavior on height {
                                NumberAnimation {
                                    duration: Constants.animSlow
                                    easing.type: Easing.OutExpo
                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
