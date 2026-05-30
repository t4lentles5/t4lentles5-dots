import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Card {
    id: root

    property string userName: Quickshell.env("USER") || "User"
    property string userHome: Quickshell.env("HOME") || ""
    property string uptime: "..."

    implicitWidth: mainLayout.implicitWidth + (Constants.sizeLg * 2)
    implicitHeight: mainLayout.implicitHeight + (Constants.sizeLg * 2)

    Process {
        id: uptimeProc

        command: ["sh", "-c", "uptime -p | sed 's/up //'"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    root.uptime = data.trim();

            }
        }

    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            uptimeProc.running = true;
        }
    }

    RowLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.margins: Constants.sizeLg
        spacing: Constants.sizeLg

        Item {
            id: avatarContainer

            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Theme.bgSecondary
            }

            Image {
                id: userImage

                anchors.fill: parent
                source: root.userHome !== "" ? "file://" + root.userHome + "/.face" : ""
                fillMode: Image.PreserveAspectCrop
                visible: false
                antialiasing: true
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
                visible: userImage.status === Image.Ready
            }

            ThemedText {
                anchors.centerIn: parent
                text: ""
                font.pixelSize: 28
                color: Theme.purple
                visible: userImage.status !== Image.Ready
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 2
                border.color: Theme.purple
                opacity: 0.8
                antialiasing: true
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            ThemedText {
                text: root.userName.charAt(0).toUpperCase() + root.userName.slice(1)
                font.pixelSize: Constants.sizeMd + 2
                font.weight: Font.Bold
                color: Theme.purple
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.bottomMargin: 2
            }

            RowLayout {
                spacing: Constants.sizeSm

                ThemedText {
                    text: "󰣇"
                    font.pixelSize: Constants.sizeMd + 2
                    color: Theme.blueArch
                }

                ThemedText {
                    text: "Arch Linux"
                    font.pixelSize: Constants.sizeSm
                    font.weight: Font.Medium
                    color: Theme.fg
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            RowLayout {
                spacing: Constants.sizeSm

                ThemedText {
                    text: "󰅐"
                    font.pixelSize: Constants.sizeMd + 2
                    color: Theme.yellow
                }

                ThemedText {
                    text: root.uptime.startsWith("up ") ? root.uptime : "up " + root.uptime
                    font.pixelSize: Constants.sizeSm
                    font.weight: Font.Medium
                    color: Theme.fg
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

        }

    }

}
