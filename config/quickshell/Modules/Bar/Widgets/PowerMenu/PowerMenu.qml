import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

TopPopup {
    id: root

    property string selectedId: ""
    property var menuModel: [{
        "id": "lock",
        "name": "Lock",
        "icon": "󰍁",
        "command": ["sh", "-c", "sleep 0.3; hyprlock"],
        "color": Theme.colGreen,
        "confirm": false
    }, {
        "id": "suspend",
        "name": "Suspend",
        "icon": "",
        "command": ["sh", "-c", "mpc -q pause; amixer set Master mute; systemctl suspend"],
        "color": Theme.colBlue,
        "confirm": true
    }, {
        "id": "logout",
        "name": "Logout",
        "icon": "󰗽",
        "command": ["hyprctl", "dispatch", "exit"],
        "color": Theme.colPurple,
        "confirm": true
    }, {
        "id": "reboot",
        "name": "Reboot",
        "icon": "󰜉",
        "command": ["systemctl", "reboot"],
        "color": Theme.colYellow,
        "confirm": true
    }, {
        "id": "shutdown",
        "name": "Shutdown",
        "icon": "",
        "command": ["systemctl", "poweroff"],
        "color": Theme.colRed,
        "confirm": true
    }]

    implicitWidth: 280
    preferredHeight: mainCol.implicitHeight + 32
    onIsOpenChanged: {
        if (!isOpen)
            selectedId = "";

    }

    Process {
        id: execProc
    }

    ColumnLayout {
        id: mainCol

        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 8

        Repeater {
            model: root.menuModel

            delegate: ColumnLayout {
                id: itemCol

                readonly property bool isSelected: root.selectedId === modelData.id

                Layout.fillWidth: true
                spacing: 4

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: itemCol.isSelected ? Theme.colBgLighter : (hnd.hovered ? Theme.colBgSecondary : "transparent")
                    radius: 10

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 14

                        Text {
                            text: modelData.icon
                            color: (hnd.hovered || itemCol.isSelected) ? modelData.color : Theme.colFg
                            font.pixelSize: 20
                        }

                        Text {
                            text: modelData.name
                            color: Theme.colFg
                            font.family: Theme.fontFamily
                            font.pixelSize: 15
                            font.bold: itemCol.isSelected
                            Layout.fillWidth: true
                        }

                        Text {
                            text: itemCol.isSelected ? "󰅂" : "󰅀"
                            color: Theme.colMuted
                            font.pixelSize: 14
                            visible: modelData.confirm
                            rotation: itemCol.isSelected ? 180 : 0

                            Behavior on rotation {
                                NumberAnimation {
                                    duration: 200
                                }

                            }

                        }

                    }

                    HoverHandler {
                        id: hnd

                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            if (!modelData.confirm) {
                                execProc.command = modelData.command;
                                execProc.running = true;
                                root.isOpen = false;
                            } else {
                                root.selectedId = itemCol.isSelected ? "" : modelData.id;
                            }
                        }
                    }

                }

                Rectangle {
                    id: confirmArea

                    Layout.fillWidth: true
                    Layout.preferredHeight: itemCol.isSelected ? 54 : 0
                    Layout.leftMargin: 4
                    Layout.rightMargin: 4
                    clip: true
                    color: Theme.colBgSecondary
                    radius: 8
                    opacity: itemCol.isSelected ? 1 : 0
                    border.color: Theme.colBgLighter
                    border.width: itemCol.isSelected ? 1 : 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Theme.colBgLighter
                            radius: 6
                            opacity: hndCancel.hovered ? 1 : 0.8

                            Text {
                                anchors.centerIn: parent
                                text: "No"
                                color: Theme.colFg
                                font.pixelSize: 14
                                font.family: Theme.fontFamily
                            }

                            TapHandler {
                                onTapped: root.selectedId = ""
                            }

                            HoverHandler {
                                id: hndCancel

                                cursorShape: Qt.PointingHandCursor
                            }

                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: modelData.color
                            radius: 6
                            scale: hndConfirm.hovered ? 1.02 : 1

                            Text {
                                anchors.centerIn: parent
                                text: "Yes"
                                color: "white"
                                font.pixelSize: 14
                                font.family: Theme.fontFamily
                                font.bold: true
                            }

                            TapHandler {
                                onTapped: {
                                    execProc.command = modelData.command;
                                    execProc.running = true;
                                    root.isOpen = false;
                                }
                            }

                            HoverHandler {
                                id: hndConfirm

                                cursorShape: Qt.PointingHandCursor
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                }

                            }

                        }

                    }

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutQuart
                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                        }

                    }

                }

            }

        }

    }

}
