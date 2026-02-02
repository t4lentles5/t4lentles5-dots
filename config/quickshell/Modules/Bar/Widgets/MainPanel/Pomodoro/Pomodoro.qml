import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Io
import qs.Core

Item {
    id: root

    property int workTime: 25 * 60
    property int breakTime: 5 * 60
    property int currentTime: workTime
    property bool isRunning: false
    property bool isBreak: false

    function formatTime(seconds) {
        let mins = Math.floor(seconds / 60);
        let secs = seconds % 60;
        return (mins < 10 ? "0" + mins : mins) + ":" + (secs < 10 ? "0" + secs : secs);
    }

    function toggleTimer() {
        isRunning = !isRunning;
    }

    function resetTimer() {
        isRunning = false;
        isBreak = false;
        currentTime = workTime;
    }

    function restoreDefaults() {
        isRunning = false;
        isBreak = false;
        workTime = 25 * 60;
        breakTime = 5 * 60;
        currentTime = workTime;
    }

    Process {
        id: notificationSound

        command: ["paplay", "/usr/share/sounds/freedesktop/stereo/complete.oga"]
    }

    Timer {
        id: timer

        interval: 1000
        repeat: true
        running: root.isRunning
        onTriggered: {
            if (root.currentTime > 0) {
                root.currentTime--;
            } else {
                root.isRunning = false;
                root.isBreak = !root.isBreak;
                root.currentTime = root.isBreak ? root.breakTime : root.workTime;
                notificationSound.running = true;
            }
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 60

        Item {
            Layout.preferredWidth: 240
            Layout.preferredHeight: 240

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.color: Theme.colBgSecondary
                border.width: 10
            }

            Shape {
                id: progressShape

                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4
                opacity: 0.8

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: root.isBreak ? Theme.colGreen : Theme.colPurple
                    strokeWidth: 10
                    capStyle: ShapePath.RoundCap

                    PathAngleArc {
                        centerX: 120
                        centerY: 120
                        radiusX: 115
                        radiusY: 115
                        startAngle: -90
                        sweepAngle: 360 * (root.currentTime / (root.isBreak ? root.breakTime : root.workTime))

                        Behavior on sweepAngle {
                            NumberAnimation {
                                duration: 1000
                                easing.type: Easing.Linear
                            }

                        }

                    }

                }

            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    text: root.isBreak ? "Break" : "Focus"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    color: Theme.colMuted
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: root.formatTime(root.currentTime)
                    font.family: Theme.fontFamily
                    font.pixelSize: 58
                    font.bold: true
                    color: Theme.colFg
                    Layout.alignment: Qt.AlignHCenter
                }

            }

        }

        ColumnLayout {
            spacing: 25
            Layout.alignment: Qt.AlignVCenter

            RowLayout {
                spacing: 20
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    radius: 30
                    color: root.isRunning ? Theme.colRed : Theme.colGreen
                    opacity: 0.9

                    Text {
                        anchors.centerIn: parent
                        text: root.isRunning ? "󰏤" : "󰐊"
                        font.family: Theme.fontFamily
                        font.pixelSize: 24
                        color: Theme.colBg
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleTimer()
                    }

                }

                Rectangle {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    radius: 25
                    color: Theme.colBgSecondary
                    border.color: Theme.colMuted
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "󰜉"
                        font.family: Theme.fontFamily
                        font.pixelSize: 20
                        color: Theme.colFg
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.resetTimer()
                    }

                }

            }

            ColumnLayout {
                spacing: 15
                Layout.alignment: Qt.AlignHCenter

                ColumnLayout {
                    spacing: 5

                    Text {
                        text: "Focus Time"
                        color: Theme.colMuted
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        spacing: 15

                        Text {
                            text: "󰍷"
                            color: Theme.colFg
                            font.pixelSize: 18

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.workTime > 60) {
                                        root.workTime -= 60;
                                        if (!root.isRunning && !root.isBreak)
                                            root.currentTime = root.workTime;

                                    }
                                }
                            }

                        }

                        Text {
                            text: Math.floor(root.workTime / 60) + "m"
                            color: Theme.colFg
                            font.bold: true
                            font.pixelSize: 16
                        }

                        Text {
                            text: "󰐙"
                            color: Theme.colFg
                            font.pixelSize: 18

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.workTime += 60;
                                    if (!root.isRunning && !root.isBreak)
                                        root.currentTime = root.workTime;

                                }
                            }

                        }

                    }

                }

                ColumnLayout {
                    spacing: 5

                    Text {
                        text: "Break Time"
                        color: Theme.colMuted
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        spacing: 15

                        Text {
                            text: "󰍷"
                            color: Theme.colFg
                            font.pixelSize: 18

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.breakTime > 60) {
                                        root.breakTime -= 60;
                                        if (!root.isRunning && root.isBreak)
                                            root.currentTime = root.breakTime;

                                    }
                                }
                            }

                        }

                        Text {
                            text: Math.floor(root.breakTime / 60) + "m"
                            color: Theme.colFg
                            font.bold: true
                            font.pixelSize: 16
                        }

                        Text {
                            text: "󰐙"
                            color: Theme.colFg
                            font.pixelSize: 18

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.breakTime += 60;
                                    if (!root.isRunning && root.isBreak)
                                        root.currentTime = root.breakTime;

                                }
                            }

                        }

                    }

                }

            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 140
                height: 30
                color: "transparent"
                radius: 15
                border.color: Theme.colMuted
                border.width: 1
                opacity: 0.6

                Text {
                    anchors.centerIn: parent
                    text: "Restore Defaults"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.colMuted
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: parent.opacity = 1
                    onExited: parent.opacity = 0.6
                    onClicked: root.restoreDefaults()
                }

            }

        }

    }

}
