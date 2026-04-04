import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Rectangle {
    id: root

    property string userName: Quickshell.env("USER") || "User"
    property string userHome: Quickshell.env("HOME") || ""
    property string uptime: "..."

    color: Colors.bgSecondary
    radius: Constants.sizeXs
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

            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Colors.bgSecondary
            }

            Image {
                id: userImage

                anchors.fill: parent
                source: root.userHome !== "" ? "file://" + root.userHome + "/.face" : ""
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
                border.width: 1
                border.color: Colors.purple
                opacity: 0.35
                antialiasing: true
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            ThemedText {
                text: " : " + root.userName.charAt(0).toUpperCase() + root.userName.slice(1)
                font.pixelSize: Constants.sizeSm
                color: Colors.purple
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            ThemedText {
                text: "󰣇 : Arch Linux"
                font.pixelSize: Constants.sizeSm
                color: Colors.blueArch
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            ThemedText {
                text: "󰅐 : " + root.uptime
                font.pixelSize: Constants.sizeSm
                color: Colors.yellow
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

        }

    }

}
