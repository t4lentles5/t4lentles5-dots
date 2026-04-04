import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core

TopPopup {
    id: root

    property var notificationService
    property var currentTime: new Date()
    property bool controlCenterOpen: false

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
                color: Colors.cyan
                Layout.fillWidth: true
            }

            IconButton {
                icon: (notificationService && notificationService.dndEnabled) ? "󰂛" : "󰂚"
                iconColor: Colors.blue
                hoverColor: Colors.blue
                iconSize: Constants.sizeMd
                onClicked: {
                    if (notificationService)
                        notificationService.dndEnabled = !notificationService.dndEnabled;

                }
            }

            IconButton {
                icon: "󰃢"
                iconColor: Colors.red
                hoverColor: Colors.red
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
                    color: Colors.muted
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

                        remove: Transition {
                            NumberAnimation {
                                property: "x"
                                to: historyView.width
                                duration: Constants.animSlow
                                easing.type: Easing.InExpo
                            }

                        }

                        displaced: Transition {
                            SequentialAnimation {
                                PauseAnimation {
                                    duration: Constants.animSlow
                                }

                                NumberAnimation {
                                    properties: "x,y"
                                    duration: Constants.animSlow
                                    easing.type: Easing.OutExpo
                                }

                            }

                        }

                        delegate: Rectangle {
                            id: delegateRoot

                            property bool expanded: false

                            width: ListView.view.width
                            height: delegateLayout.implicitHeight + Constants.sizeLg * 2
                            color: Colors.bgSecondary
                            radius: Constants.sizeXs
                            border.width: 1
                            border.color: Colors.muted

                            RowLayout {
                                id: delegateLayout

                                anchors.fill: parent
                                anchors.leftMargin: Constants.sizeSm
                                anchors.rightMargin: Constants.sizeSm
                                anchors.topMargin: Constants.sizeSm
                                anchors.bottomMargin: Constants.sizeSm
                                spacing: Constants.sizeSm

                                Image {
                                    id: notifImage

                                    Layout.alignment: Qt.AlignTop
                                    Layout.topMargin: 4
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    source: {
                                        if (model.image)
                                            return model.image;

                                        if (model.icon) {
                                            const ico = model.icon.toString();
                                            if (ico.startsWith("/") || ico.startsWith("file://") || ico.startsWith("image://"))
                                                return ico;

                                            return "image://icon/" + ico + "?fallback=dialog-information";
                                        }
                                        return "";
                                    }
                                    visible: source.toString() !== ""
                                    fillMode: Image.PreserveAspectCrop
                                    opacity: 1
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
                                            color: Colors.muted
                                            font.pixelSize: Constants.sizeSm - 2
                                        }

                                        IconButton {
                                            icon: delegateRoot.expanded ? "" : ""
                                            iconColor: Colors.blue
                                            hoverColor: Colors.blue
                                            iconSize: Constants.sizeSm - 2
                                            visible: bodyText.truncated || delegateRoot.expanded
                                            onClicked: {
                                                delegateRoot.expanded = !delegateRoot.expanded;
                                            }
                                        }

                                        IconButton {
                                            icon: ""
                                            iconColor: Colors.red
                                            hoverColor: Colors.red
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
                                        color: Colors.muted
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
