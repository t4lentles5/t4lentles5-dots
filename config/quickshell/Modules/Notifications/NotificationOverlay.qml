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
                color: Colors.bg
                radius: 12
                border.color: mainMouseArea.containsMouse ? Qt.rgba(Colors.purple.r, Colors.purple.g, Colors.purple.b, 0.4) : Colors.border
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
                    onExited: toastRect.color = Colors.bg
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
                                if (model.image)
                                    return model.image;

                                if (model.icon) {
                                    let iconStr = model.icon.toString();
                                    if (iconStr.startsWith("/") || iconStr.startsWith("file://") || iconStr.startsWith("image://"))
                                        return iconStr;

                                    return "image://icon/" + iconStr + "?fallback=dialog-information";
                                }
                                return Constants.fallbackIcon;
                            }
                            sourceSize: Qt.size(48, 48)
                            visible: false
                            fillMode: Image.PreserveAspectCrop
                        }

                        OpacityMask {
                            anchors.fill: parent
                            source: notifImage
                            visible: notifImage.source.toString() !== ""

                            maskSource: Rectangle {
                                width: notifImage.width
                                height: notifImage.height
                                radius: 8
                            }

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
                                color: Colors.cyan
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
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 28
                                color: acceptMouse.containsMouse ? Qt.rgba(Colors.green.r, Colors.green.g, Colors.green.b, 0.15) : Colors.bgSecondary
                                border.color: acceptMouse.containsMouse ? Qt.rgba(Colors.green.r, Colors.green.g, Colors.green.b, 0.4) : Colors.border
                                border.width: 1
                                radius: Constants.sizeXs

                                ThemedText {
                                    anchors.centerIn: parent
                                    text: "Accept"
                                    color: Colors.green
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
                                        actionCommand.command = ["bash", "-c", "pgrep -n -f [p]ower_action.sh | xargs -r kill -USR1"];
                                        actionCommand.startDetached();
                                        toastRect.closeNotification();
                                    }
                                }

                            }

                            Rectangle {
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 28
                                color: cancelMouse.containsMouse ? Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.15) : Colors.bgSecondary
                                border.color: cancelMouse.containsMouse ? Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.4) : Colors.border
                                border.width: 1
                                radius: Constants.sizeXs

                                ThemedText {
                                    anchors.centerIn: parent
                                    text: "Cancel"
                                    color: Colors.red
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
                                        actionCommand.command = ["bash", "-c", "pgrep -n -f [p]ower_action.sh | xargs -r kill -TERM"];
                                        actionCommand.startDetached();
                                        toastRect.closeNotification();
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
                    hoverColor: Colors.fg
                    iconColor: Colors.muted
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
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    height: 4
                    radius: 2
                    color: Qt.rgba(Colors.purple.r, Colors.purple.g, Colors.purple.b, 0.15)
                    visible: true

                    Rectangle {
                        id: progressBar

                        height: parent.height
                        radius: 2
                        color: Colors.purple
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
