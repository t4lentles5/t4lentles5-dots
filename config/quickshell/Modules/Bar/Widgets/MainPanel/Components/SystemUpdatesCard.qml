import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Item {
    id: root

    property string pacmanUpdates: "..."
    property string aurUpdates: "..."
    property bool hasUpdates: (parseInt(pacmanUpdates) > 0 || parseInt(aurUpdates) > 0)

    Process {
        id: pacmanProc

        command: ["sh", "-c", "checkupdates | wc -l || echo 0"]

        stdout: SplitParser {
            onRead: (data) => {
                root.pacmanUpdates = data.trim();
            }
        }

    }

    Process {
        id: aurProc

        command: ["sh", "-c", "yay -Qua | wc -l || echo 0"]

        stdout: SplitParser {
            onRead: (data) => {
                root.aurUpdates = data.trim();
            }
        }

    }

    Process {
        id: updateExec

        command: ["sh", "-c", "kitty --class kitty-floating --hold -e yay -Syu --noconfirm"]
        onExited: {
            pacmanProc.running = true;
            aurProc.running = true;
        }
    }

    Timer {
        interval: 3.6e+06
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            pacmanProc.running = true;
            aurProc.running = true;
        }
    }

    Card {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                ThemedText {
                    text: "󰏔"
                    color: Theme.colPurple
                    font.pixelSize: Theme.fontSizeMd
                }

                ThemedText {
                    text: "System Updates"
                    color: Theme.colFg
                    font.pixelSize: Theme.fontSizeMd
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 8
                    Layout.preferredHeight: 8
                    radius: 4
                    color: root.hasUpdates ? Theme.colYellow : Theme.colGreen
                }

                ThemedText {
                    text: root.hasUpdates ? (parseInt(root.pacmanUpdates) + parseInt(root.aurUpdates)) + " Pending" : "Up to date"
                    color: Theme.colMuted
                    font.pixelSize: Theme.fontSizeSm
                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.colBgLighter
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Theme.spacingSm

                    UpdateRowItem {
                        icon: "󰣇"
                        label: "Official"
                        count: root.pacmanUpdates
                        iconColor: Theme.colBlueArch
                    }

                    UpdateRowItem {
                        icon: "󰊤"
                        label: "AUR"
                        count: root.aurUpdates
                        iconColor: Theme.colMuted
                    }

                }

                Rectangle {
                    id: updateBtn

                    visible: root.hasUpdates
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillHeight: true
                    Layout.preferredWidth: 80
                    color: updateArea.containsPress ? Qt.darker(Theme.colPurple, 1.2) : (updateArea.containsMouse ? Theme.colPurple : Qt.rgba(Theme.colPurple.r, Theme.colPurple.g, Theme.colPurple.b, 0.1))
                    radius: Theme.radiusSm
                    border.color: Theme.colPurple
                    border.width: 1
                    scale: updateArea.containsPress ? 0.95 : 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        ThemedText {
                            text: "󰚰"
                            Layout.alignment: Qt.AlignHCenter
                            color: updateArea.containsMouse ? Theme.colBg : Theme.colPurple
                            font.pixelSize: 24
                        }

                        ThemedText {
                            text: "Update"
                            Layout.alignment: Qt.AlignHCenter
                            color: updateArea.containsMouse ? Theme.colBg : Theme.colPurple
                            font.pixelSize: Theme.fontSizeSm
                            font.bold: true
                        }

                    }

                    MouseArea {
                        id: updateArea

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: updateExec.running = true
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.animNormal
                            easing.type: Easing.OutBack
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

    component UpdateRowItem: Rectangle {
        property string icon
        property string label
        property string count
        property color iconColor

        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Theme.radiusSm
        color: itemHover.containsMouse ? Theme.colBgLighter : "transparent"

        MouseArea {
            id: itemHover

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingSm
            anchors.rightMargin: Theme.spacingSm
            spacing: 12

            ThemedText {
                text: icon
                color: iconColor
                font.pixelSize: Theme.fontSizeLg
            }

            ThemedText {
                text: label
                color: Theme.colFg
                font.pixelSize: Theme.fontSizeMd
                font.bold: true
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 22
                radius: 6
                color: parseInt(count) > 0 ? Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.2) : Theme.colBgSecondary
                border.color: parseInt(count) > 0 ? iconColor : "transparent"
                border.width: 1

                ThemedText {
                    anchors.centerIn: parent
                    text: count
                    color: parseInt(count) > 0 ? iconColor : Theme.colMuted
                    font.pixelSize: Theme.fontSizeSm
                    font.bold: true
                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.animNormal
            }

        }

    }

}
