import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core

TopPopup {
    id: root

    property var notificationService

    implicitWidth: 420
    preferredHeight: mainCol.implicitHeight + (root.contentPadding * 2)
    animateHeight: true

    ColumnLayout {
        id: mainCol

        width: parent.width
        spacing: Theme.spacingLg

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: Theme.colBgSecondary
            radius: Theme.radiusSm

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15

                ThemedText {
                    text: "Notifications"
                    font.pixelSize: Theme.fontSizeLg
                    font.bold: true
                    color: Theme.colFg
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: dndRow.implicitWidth + 24
                    height: 36
                    radius: Theme.radiusSm
                    color: mouseDnd.containsMouse ? Theme.colBgLighter : (notificationService && notificationService.dndEnabled ? Theme.colRed : "transparent")

                    RowLayout {
                        id: dndRow

                        anchors.centerIn: parent
                        spacing: 6

                        ThemedText {
                            text: "󰂛"
                            color: (notificationService && notificationService.dndEnabled) ? Theme.colBg : Theme.colFg
                            font.pixelSize: Theme.fontSizeMd
                        }

                        ThemedText {
                            text: "DND"
                            color: (notificationService && notificationService.dndEnabled) ? Theme.colBg : Theme.colFg
                            font.pixelSize: Theme.fontSizeSm
                            font.bold: true
                        }

                    }

                    MouseArea {
                        id: mouseDnd

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (notificationService)
                                notificationService.dndEnabled = !notificationService.dndEnabled;

                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animFast
                        }

                    }

                }

                Rectangle {
                    width: clearRow.implicitWidth + 24
                    height: 36
                    radius: Theme.radiusSm
                    color: mouseClear.containsMouse ? Theme.colRed : "transparent"

                    RowLayout {
                        id: clearRow

                        anchors.centerIn: parent
                        spacing: 6

                        ThemedText {
                            text: "󰃢"
                            color: mouseClear.containsMouse ? Theme.colBg : Theme.colFg
                            font.pixelSize: Theme.fontSizeMd
                        }

                        ThemedText {
                            text: "Clear"
                            color: mouseClear.containsMouse ? Theme.colBg : Theme.colFg
                            font.pixelSize: Theme.fontSizeSm
                            font.bold: true
                        }

                    }

                    MouseArea {
                        id: mouseClear

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (notificationService)
                                notificationService.clearHistory();

                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animFast
                        }

                    }

                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 350
            color: "transparent"
            radius: Theme.radiusSm
            clip: true

            ScrollView {
                anchors.fill: parent
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ListView {
                    id: historyView

                    width: parent.width
                    model: notificationService ? notificationService.historyList : null
                    spacing: Theme.spacingLg

                    ThemedText {
                        anchors.centerIn: parent
                        text: "No notifications"
                        color: Theme.colMuted
                        font.pixelSize: Theme.fontSizeMd
                        visible: historyView.count === 0
                    }

                    remove: Transition {
                        ParallelAnimation {
                            NumberAnimation {
                                property: "x"
                                to: historyView.width
                                duration: Theme.animNormal
                                easing.type: Easing.InExpo
                            }

                            NumberAnimation {
                                property: "opacity"
                                to: 0
                                duration: Theme.animNormal
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                    displaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: Theme.animNormal
                            easing.type: Easing.OutExpo
                        }

                    }

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: delegateLayout.implicitHeight + (Theme.spacingLg * 2)
                        color: Theme.colBgSecondary
                        radius: Theme.radiusLg
                        border.color: Qt.rgba(Theme.colMuted.r, Theme.colMuted.g, Theme.colMuted.b, 0.4)
                        border.width: 1

                        RowLayout {
                            id: delegateLayout

                            anchors.fill: parent
                            anchors.margins: Theme.spacingLg
                            spacing: Theme.spacingLg

                            Image {
                                Layout.alignment: Qt.AlignTop
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                source: {
                                    if (model.image)
                                        return model.image;

                                    if (model.icon) {
                                        let iconStr = model.icon.toString();
                                        if (iconStr.startsWith("/") || iconStr.startsWith("file://") || iconStr.startsWith("image://")) {
                                            return iconStr;
                                        }
                                        return "image://icon/" + iconStr + "?fallback=dialog-information";
                                    }

                                    return "";
                                }
                                sourceSize: Qt.size(40, 40)
                                visible: source.toString() !== ""
                                fillMode: Image.PreserveAspectCrop
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                ThemedText {
                                    text: model.summary
                                    font.pixelSize: Theme.fontSizeMd
                                    font.bold: true
                                    wrapMode: Text.Wrap
                                    color: Theme.colFg
                                    Layout.fillWidth: true
                                }

                                ThemedText {
                                    text: model.body
                                    color: Theme.colFg
                                    opacity: 0.8
                                    font.pixelSize: Theme.fontSizeSm
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }

                            }

                        }

                        Rectangle {
                            id: closeBtn

                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: Theme.spacingSm
                            width: 24
                            height: 24
                            radius: Theme.radiusSm
                            color: closeMouse.containsMouse ? Theme.colRed : "transparent"

                            ThemedText {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: closeMouse.containsMouse ? Theme.colBg : Theme.colFg
                                font.pixelSize: Theme.fontSizeMd
                            }

                            MouseArea {
                                id: closeMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (notificationService)
                                        notificationService.removeHistoryItem(index);

                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animFast
                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
