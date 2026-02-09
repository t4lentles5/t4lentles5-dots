import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Rectangle {
    id: root

    property int cardPadding: 20
    property string userName: "User"
    property string osName: "Linux"
    property string wmName: "Unknown"
    property string uptime: "..."
    property string userHome: ""

    color: Theme.colBgSecondary
    radius: 10

    Process {
        id: userProc

        command: ["whoami"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                return root.userName = data.trim();
            }
        }

    }

    Process {
        id: osProc

        command: ["sh", "-c", "grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '\"'"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                return root.osName = data.trim();
            }
        }

    }

    Process {
        id: wmProc

        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                return root.wmName = data.trim();
            }
        }

    }

    Process {
        id: uptimeProc

        command: ["uptime", "-p"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                return root.uptime = data.trim().replace("up ", "");
            }
        }

    }

    Process {
        id: homeProc

        command: ["sh", "-c", "echo $HOME"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                return root.userHome = data.trim();
            }
        }

    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: uptimeProc.running = true
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: root.cardPadding
        spacing: 16

        Item {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80

            Image {
                id: userImage

                anchors.fill: parent
                source: root.userHome === "" ? "" : "file://" + root.userHome + "/.face"
                fillMode: Image.PreserveAspectCrop
                visible: false
                antialiasing: true
                onStatusChanged: {
                    if (status === Image.Error)
                        source = "qrc:/qt/qml/qs/Shared/assets/default_avatar.png";

                }
            }

            Rectangle {
                id: mask

                anchors.fill: parent
                radius: width / 2
                visible: false
                antialiasing: true
            }

            OpacityMask {
                anchors.fill: parent
                source: userImage
                maskSource: mask
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 2
                border.color: Theme.colFg
                antialiasing: true
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 8

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true

                Text {
                    text: "Welcome,"
                    color: Theme.colMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                }

                Text {
                    text: root.userName.charAt(0).toUpperCase() + root.userName.slice(1)
                    color: Theme.colPurple
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 4
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true

                RowLayout {
                    spacing: 6
                    Layout.fillWidth: true

                    Text {
                        text: "󰣇"
                        color: Theme.colBlueArch
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    Text {
                        text: root.osName
                        color: Theme.colFg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                }

                RowLayout {
                    spacing: 6
                    Layout.fillWidth: true

                    Text {
                        text: ""
                        color: Theme.colGreen
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    Text {
                        text: root.wmName
                        color: Theme.colFg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                }

                RowLayout {
                    spacing: 6
                    Layout.fillWidth: true

                    Text {
                        text: "󱑎"
                        color: Theme.colYellow
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    Text {
                        text: root.uptime
                        color: Theme.colFg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                }

            }

        }

    }

}
