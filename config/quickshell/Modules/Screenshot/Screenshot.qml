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
        spacing: Theme.spacingSm

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 14
            Layout.rightMargin: 14
            spacing: Theme.spacingSm

            ThemedText {
                text: "󰄄"
                color: Theme.colPurple
                font.pixelSize: Theme.fontSizeLg
            }

            ThemedText {
                text: "Screenshot"
                color: Theme.colFg
                font.pixelSize: Theme.fontSizeLg
                font.bold: true
                Layout.fillWidth: true
            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.colBgLighter
        }

        ColumnLayout {
            id: shotView

            property int currentIndex: 0

            Layout.fillWidth: true
            spacing: 2
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

            Repeater {
                model: shotModel

                Rectangle {
                    readonly property bool isCurrent: shotView.currentIndex === index

                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    radius: Theme.radiusSm
                    color: isCurrent ? Theme.colBgLighter : (hoverHandler.hovered ? Theme.colBgSecondary : "transparent")

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12

                        ThemedText {
                            text: model.iconSource
                            color: isCurrent ? Theme.colPurple : Theme.colFg
                            font.pixelSize: Theme.fontSizeLg

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animNormal
                                }

                            }

                        }

                        ThemedText {
                            text: model.label
                            color: isCurrent ? Theme.colPurple : Theme.colFg
                            font.bold: isCurrent
                            Layout.fillWidth: true

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animNormal
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

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animNormal
                        }

                    }

                }

            }

        }

    }

}
