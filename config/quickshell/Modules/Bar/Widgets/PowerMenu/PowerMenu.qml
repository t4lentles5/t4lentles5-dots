import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

TopPopup {
    id: root

    property bool controlCenterOpen: true
    property var menuModel: [{
        "id": "lock",
        "icon": "󰍁",
        "command": ["sh", "-c", "sleep 0.3; hyprlock"],
        "color": Colors.green,
        "confirm": false
    }, {
        "id": "suspend",
        "icon": "",
        "command": ["sh", "-c", "mpc -q pause; amixer set Master mute; systemctl suspend"],
        "color": Colors.blue,
        "confirm": true
    }, {
        "id": "logout",
        "icon": "󰗽",
        "command": ["hyprctl", "dispatch", "exit"],
        "color": Colors.purple,
        "confirm": true
    }, {
        "id": "reboot",
        "icon": "󰜉",
        "command": ["systemctl", "reboot"],
        "color": Colors.yellow,
        "confirm": true
    }, {
        "id": "shutdown",
        "icon": "",
        "command": ["systemctl", "poweroff"],
        "color": Colors.red,
        "confirm": true
    }]

    signal requestClose()

    implicitHeight: contentColumn.implicitHeight + Constants.sizeLg * 2

    Process {
        id: actionProc
    }

    ColumnLayout {
        id: contentColumn

        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Constants.sizeXs

        Repeater {
            model: root.menuModel

            delegate: Item {
                id: delegateRoot

                readonly property bool isHovered: hoverHandler.hovered

                Layout.fillWidth: true
                implicitHeight: 40
                implicitWidth: Math.max(160, innerRow.implicitWidth)

                Rectangle {
                    anchors.fill: parent
                    radius: Constants.sizeXs
                    color: modelData.color
                    opacity: isHovered ? 0.15 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Constants.animNormal
                        }

                    }

                }

                RowLayout {
                    id: innerRow

                    anchors.fill: parent
                    anchors.leftMargin: Constants.sizeLg
                    anchors.rightMargin: Constants.sizeLg
                    spacing: Constants.sizeLg

                    ThemedText {
                        text: modelData.icon
                        font.pixelSize: Constants.sizeXl
                        color: isHovered ? modelData.color : Colors.fg
                        scale: isHovered ? 1.1 : 1

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

                    ThemedText {
                        text: modelData.id.charAt(0).toUpperCase() + modelData.id.slice(1)
                        font.pixelSize: Constants.sizeMd
                        font.weight: Font.Medium
                        color: Colors.fg
                        Layout.fillWidth: true

                        Behavior on color {
                            ColorAnimation {
                                duration: Constants.animNormal
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
                        if (modelData.confirm) {
                            let scriptPath = Quickshell.shellDir + "/Scripts/power_action.sh";
                            let args = [scriptPath, modelData.id];
                            for (let arg of modelData.command) args.push(arg)
                            actionProc.command = ["bash"].concat(args);
                        } else {
                            actionProc.command = modelData.command;
                        }
                        actionProc.startDetached();
                        root.isOpen = false;
                    }
                }

            }

        }

    }

}
