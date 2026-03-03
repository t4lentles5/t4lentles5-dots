import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Item {
    id: root

    property string userName: Quickshell.env("USER") || "User"
    property string userHome: Quickshell.env("HOME") || ""
    property string uptime: "..."
    property string osName: "..."
    property string greeting: getGreeting()

    function getGreeting() {
        var hour = new Date().getHours();
        if (hour < 12)
            return "Good morning,";

        if (hour < 18)
            return "Good afternoon,";

        return "Good evening,";
    }

    Process {
        id: uptimeProc

        command: ["sh", "-c", "uptime -p | sed 's/up //'"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                root.uptime = data.trim();
            }
        }

    }

    Process {
        id: osProc

        command: ["sh", "-c", "(cat /etc/os-release 2>/dev/null | grep -i '^NAME=' | cut -d'=' -f2 | tr -d '\"') || uname -s"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                root.osName = data.trim();
            }
        }

    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            uptimeProc.running = true;
        }
    }

    Card {
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16
            clip: true

            Item {
                id: avatarContainer

                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    id: avatarBg

                    anchors.fill: parent
                    radius: 40
                    color: Theme.colBgLighter
                }

                Image {
                    id: userImage

                    anchors.fill: parent
                    anchors.margins: 4
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
                    anchors.margins: 4
                    radius: 40
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
                    radius: 40
                    color: "transparent"
                    border.width: 2
                    border.color: Theme.colPurple
                    opacity: 0.4
                    antialiasing: true
                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    text: root.greeting
                    color: Theme.colMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                }

                Text {
                    text: root.userName.charAt(0).toUpperCase() + root.userName.slice(1)
                    color: Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                    elide: Text.ElideRight
                }

                RowLayout {
                    spacing: 6
                    Layout.topMargin: 4

                    Text {
                        text: "󰅐"
                        color: Theme.colPurple
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }

                    Text {
                        text: root.uptime
                        color: Theme.colMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                }

                RowLayout {
                    spacing: 6

                    Text {
                        text: "󰣇"
                        color: Theme.colBlueArch
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }

                    Text {
                        text: root.osName
                        color: Theme.colMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                }

            }

        }

    }

}
