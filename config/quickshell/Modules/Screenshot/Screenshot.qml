import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Core

CenterWindow {
    id: root

    function runShot(mode) {
        if (screenshotProc.running)
            screenshotProc.running = false;

        let scriptPath = "~/.config/quickshell/Scripts/screenshot.sh";
        let cmd = `nohup sh ${scriptPath} ${mode} > /dev/null 2>&1 &`;
        screenshotProc.command = ["sh", "-c", cmd];
        screenshotProc.startDetached();
        root.isOpen = false;
    }

    popupId: "screenshot"
    preferredHeight: mainCol.implicitHeight + 32
    preferredWidth: 300
    onPopupOpened: {
        focusTimer.start();
        shotView.currentIndex = 0;
    }

    Timer {
        id: focusTimer

        interval: 50
        repeat: false
        onTriggered: shotView.forceActiveFocus()
    }

    Process {
        id: screenshotProc
    }

    ListModel {
        id: shotModel

        ListElement {
            label: "Full Screen"
            iconSource: "󰹑"
            shotMode: "full"
        }

        ListElement {
            label: "Select Area"
            iconSource: "󰆞"
            shotMode: "area"
        }

        ListElement {
            label: "Current Window"
            iconSource: "󰖯"
            shotMode: "window"
        }

        ListElement {
            label: "Full (5s delay)"
            iconSource: ""
            shotMode: "full_delay"
        }

        ListElement {
            label: "Area to Clipboard"
            iconSource: "󰆏"
            shotMode: "clipboard"
        }

    }

    ColumnLayout {
        id: mainCol

        width: parent.width
        spacing: Constants.sizeLg

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Constants.sizeXs

            ThemedText {
                text: "󰄄"
                color: Colors.purple
                font.pixelSize: Constants.sizeXl
            }

            ThemedText {
                text: "Screenshot"
                font.pixelSize: Constants.sizeXl
                font.bold: true
            }

        }

        ListView {
            id: shotView

            currentIndex: 0
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            spacing: Constants.sizeXs
            model: shotModel
            clip: true
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 250
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Down) {
                    if (currentIndex + 1 < shotModel.count) {
                        currentIndex++;
                        event.accepted = true;
                    }
                } else if (event.key === Qt.Key_Up) {
                    if (currentIndex - 1 >= 0) {
                        currentIndex--;
                        event.accepted = true;
                    }
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (currentIndex >= 0 && currentIndex < shotModel.count) {
                        let shotMode = shotModel.get(currentIndex).shotMode;
                        root.runShot(shotMode);
                        event.accepted = true;
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                active: true
            }

            highlight: Item {
                width: shotView.width
                height: 42
                z: 1

                Rectangle {
                    anchors.fill: parent
                    radius: Constants.sizeXs
                    color: Colors.bgSecondary

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 2
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        width: 3
                        radius: 2
                        color: Colors.purple
                    }

                }

            }

            delegate: Item {
                readonly property bool isCurrent: shotView.currentIndex === index

                width: shotView.width
                height: 42
                z: 2

                Rectangle {
                    anchors.fill: parent
                    radius: Constants.sizeXs
                    color: Colors.bgSecondary
                    opacity: hoverHandler.hovered && !isCurrent ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Constants.animNormal
                        }

                    }

                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Constants.sizeLg
                    anchors.rightMargin: Constants.sizeLg
                    spacing: Constants.sizeLg

                    ThemedText {
                        text: model.iconSource
                        color: isCurrent ? Colors.purple : Colors.fg
                        font.pixelSize: Constants.sizeLg

                        Behavior on color {
                            ColorAnimation {
                                duration: Constants.animNormal
                            }

                        }

                    }

                    ThemedText {
                        text: model.label
                        color: isCurrent ? Colors.purple : Colors.fg
                        font.bold: isCurrent
                        font.pixelSize: Constants.sizeMd
                        Layout.fillWidth: true
                        scale: isCurrent ? 1.02 : 1
                        transformOrigin: Item.Left

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

                }

                HoverHandler {
                    id: hoverHandler

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        shotView.currentIndex = index;
                        root.runShot(model.shotMode);
                    }
                }

            }

        }

    }

}
