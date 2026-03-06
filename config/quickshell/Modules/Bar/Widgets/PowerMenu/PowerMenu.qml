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
    onPopupClosed: {
        selectedId = "";
    }

    Process {
        id: execProc
    }

    ColumnLayout {
        id: mainCol

        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Theme.spacingSm

        Repeater {
            model: root.menuModel

            delegate: ColumnLayout {
                id: itemCol

                readonly property bool isSelected: root.selectedId === modelData.id

                Layout.fillWidth: true
                spacing: 4

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: itemCol.isSelected ? Theme.colBgLighter : (hnd.hovered ? Theme.colBgSecondary : "transparent")
                    border.color: itemCol.isSelected ? modelData.color : (hnd.hovered ? Theme.colMuted : "transparent")
                    border.width: itemCol.isSelected ? 2 : 1
                    radius: Theme.radiusSm

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 14

                        ThemedText {
                            text: modelData.icon
                            color: (hnd.hovered || itemCol.isSelected) ? modelData.color : Theme.colFg
                            font.pixelSize: Theme.fontSizeLg
                        }

                        ThemedText {
                            text: modelData.name
                            color: (hnd.hovered || itemCol.isSelected) ? modelData.color : Theme.colFg
                            font.pixelSize: Theme.fontSizeMd
                            font.bold: itemCol.isSelected
                            Layout.fillWidth: true

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animSlow
                                }

                            }

                        }

                        ThemedText {
                            text: itemCol.isSelected ? "󰅂" : "󰅀"
                            color: Theme.colMuted
                            font.pixelSize: Theme.fontSizeMd
                            visible: modelData.confirm
                            rotation: itemCol.isSelected ? 180 : 0

                            Behavior on rotation {
                                NumberAnimation {
                                    duration: Theme.animSlow
                                    easing.type: Easing.OutQuint
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

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animSlow
                        }

                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Theme.animSlow
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
                    radius: Theme.radiusSm
                    opacity: itemCol.isSelected ? 1 : 0
                    border.color: Theme.colBgLighter
                    border.width: itemCol.isSelected ? 1 : 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSm
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Theme.colBgLighter
                            radius: 6
                            opacity: hndCancel.hovered ? 1 : 0.8

                            ThemedText {
                                anchors.centerIn: parent
                                text: "No"
                                color: Theme.colFg
                                font.pixelSize: Theme.fontSizeMd
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
                            color: hndConfirm.hovered ? Qt.lighter(modelData.color, 1.2) : modelData.color
                            radius: 6

                            ThemedText {
                                anchors.centerIn: parent
                                text: "Yes"
                                color: "white"
                                font.pixelSize: Theme.fontSizeMd
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

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animSlow
                                }

                            }

                        }

                    }

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            duration: Theme.animSlow
                            easing.type: Easing.OutQuint
                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animSlow
                            easing.type: Easing.OutQuint
                        }

                    }

                }

            }

        }

    }

}
