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
    preferredHeight: 380
    preferredWidth: 440
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
            iconSource: ""
            shotMode: "window"
        }

        ListElement {
            label: "Full (3s)"
            iconSource: "󰔝"
            shotMode: "full_delay"
        }

    }

    ColumnLayout {
        spacing: 20
        anchors.fill: parent
        anchors.margins: 16

        Text {
            text: "󰄄  Take Screenshot"
            color: Theme.colFg
            font.pixelSize: 22
            font.family: Theme.fontFamily
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.bottomMargin: 10
        }

        GridView {
            id: shotView

            Layout.fillWidth: true
            Layout.fillHeight: true
            model: shotModel
            cellWidth: width / 2
            cellHeight: height / 2
            clip: true
            currentIndex: 0
            interactive: false
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Right) {
                    if (currentIndex % 2 === 0 && currentIndex + 1 < count) {
                        currentIndex++;
                        event.accepted = true;
                    }
                } else if (event.key === Qt.Key_Left) {
                    if (currentIndex % 2 !== 0 && currentIndex - 1 >= 0) {
                        currentIndex--;
                        event.accepted = true;
                    }
                } else if (event.key === Qt.Key_Down) {
                    if (currentIndex + 2 < count) {
                        currentIndex += 2;
                        event.accepted = true;
                    }
                } else if (event.key === Qt.Key_Up) {
                    if (currentIndex - 2 >= 0) {
                        currentIndex -= 2;
                        event.accepted = true;
                    }
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (currentIndex >= 0 && currentIndex < count) {
                        let shotMode = shotModel.get(currentIndex).shotMode;
                        root.runShot(shotMode);
                        event.accepted = true;
                    }
                }
            }

            delegate: Item {
                id: delegateRoot

                readonly property bool isCurrent: shotView.currentIndex === index

                width: shotView.cellWidth
                height: shotView.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 8
                    radius: 12
                    color: isCurrent ? Theme.colBgLighter : Theme.colBgSecondary
                    border.color: isCurrent ? Theme.colPurple : "transparent"
                    border.width: 1
                    scale: hoverHandler.hovered || isCurrent ? 1.02 : 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            text: model.iconSource
                            color: isCurrent ? Theme.colPurple : Theme.colFg
                            font.pixelSize: 42
                            font.family: Theme.fontFamily
                            Layout.alignment: Qt.AlignHCenter

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }

                            }

                        }

                        Text {
                            text: model.label
                            color: isCurrent ? Theme.colPurple : Theme.colFg
                            font.family: Theme.fontFamily
                            font.pixelSize: 15
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }

                            }

                        }

                    }

                    HoverHandler {
                        id: hoverHandler
                    }

                    TapHandler {
                        onTapped: {
                            shotView.currentIndex = index;
                            root.runShot(model.shotMode);
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutBack
                        }

                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                }

            }

        }

    }

}
