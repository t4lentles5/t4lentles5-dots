import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: root

    required property var notificationService

    screen: Quickshell.screens[0]
    WlrLayershell.namespace: "notifications"
    WlrLayershell.layer: WlrLayer.Overlay
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
        top: 60
        right: 8
    }

    Column {
        id: notificationContainer

        anchors.top: parent.top
        anchors.right: parent.right
        width: parent.width
        spacing: Theme.spacingLg

        Repeater {
            id: notificationList

            model: notificationService ? notificationService.activeList : null

            delegate: Rectangle {
                id: toastRect

                property bool isRemoving: false
                property real scaleValue: 0.8
                property real opacityValue: 0
                property real slideOffset: 300

                function closeNotification() {
                    if (isRemoving)
                        return ;

                    isRemoving = true;
                    animInDelayTimer.stop();
                    slideOffset = 300;
                    scaleValue = 0.8;
                    opacityValue = 0;
                    removalTimer.start();
                }

                width: notificationContainer.width
                height: layout.implicitHeight + Theme.spacingLg * 2
                color: Theme.colBgSecondary
                radius: Theme.radiusLg
                scale: scaleValue
                opacity: opacityValue
                Component.onCompleted: {
                    animInDelayTimer.interval = index * Theme.animFast;
                    animInDelayTimer.start();
                }

                Timer {
                    id: animInDelayTimer

                    repeat: false
                    onTriggered: {
                        if (toastRect.isRemoving)
                            return ;

                        toastRect.slideOffset = 0;
                        toastRect.scaleValue = 1;
                        toastRect.opacityValue = 1;
                    }
                }

                Timer {
                    id: removalTimer

                    interval: Theme.animSlow
                    repeat: false
                    onTriggered: {
                        if (notificationService)
                            notificationService.dismissNotification(model.id);

                    }
                }

                RowLayout {
                    id: layout

                    anchors.fill: parent
                    anchors.margins: Theme.spacingLg
                    spacing: Theme.spacingLg

                    Image {
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        source: {
                            if (model.image)
                                return model.image;

                            if (model.icon) {
                                let iconStr = model.icon.toString();
                                if (iconStr.startsWith("/") || iconStr.startsWith("file://") || iconStr.startsWith("image://"))
                                    return iconStr;

                                return "image://icon/" + iconStr + "?fallback=dialog-information";
                            }
                            return "";
                        }
                        sourceSize: Qt.size(48, 48)
                        visible: source.toString() !== ""
                        fillMode: Image.PreserveAspectCrop
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: model.summary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMd
                            font.bold: true
                            color: Theme.colFg
                            wrapMode: Text.Wrap
                        }

                        Text {
                            Layout.fillWidth: true
                            text: model.body
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.colFg
                            wrapMode: Text.Wrap
                            opacity: 0.8
                        }

                    }

                }

                Rectangle {
                    id: progressBar

                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.bottomMargin: 4
                    anchors.leftMargin: Theme.radiusLg
                    height: 4
                    radius: 2
                    color: Theme.colCyan
                    width: toastRect.width - Theme.radiusLg * 2

                    NumberAnimation on width {
                        id: progressAnim

                        to: 0
                        duration: 5000
                        running: toastRect.opacityValue === 1 && !toastRect.isRemoving
                        paused: hoverArea.containsMouse
                        onFinished: {
                            if (!toastRect.isRemoving)
                                toastRect.closeNotification();

                        }
                    }

                }

                MouseArea {
                    id: hoverArea

                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: toastRect.closeNotification()
                    onEntered: toastRect.color = Qt.darker(Theme.colBgSecondary, 1.1)
                    onExited: toastRect.color = Theme.colBgSecondary
                }

                transform: Translate {
                    x: toastRect.slideOffset
                    y: 0
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.animSlow
                        easing.type: Easing.OutExpo
                    }

                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animSlow
                        easing.type: Easing.OutCubic
                    }

                }

                Behavior on slideOffset {
                    NumberAnimation {
                        duration: Theme.animSlow
                        easing.type: Easing.OutExpo
                    }

                }

            }

        }

        move: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: Theme.animSlow
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
