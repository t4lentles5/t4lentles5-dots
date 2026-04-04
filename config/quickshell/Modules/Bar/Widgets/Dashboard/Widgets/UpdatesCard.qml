import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

Rectangle {
    id: root

    property string pacmanUpdates: "..."
    property string aurUpdates: "..."
    property bool hasUpdates: (parseInt(pacmanUpdates) > 0 || parseInt(aurUpdates) > 0)

    function runUpdate() {
        updateExec.running = true;
    }

    color: Colors.bgSecondary
    radius: Constants.sizeXs
    implicitWidth: mainLayout.implicitWidth + (Constants.sizeLg * 2)
    implicitHeight: mainLayout.implicitHeight + (Constants.sizeLg * 2)

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

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.margins: Constants.sizeLg
        spacing: Constants.sizeLg

        RowLayout {
            ThemedText {
                text: "Official Repo:"
                font.pixelSize: Constants.sizeSm
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            ThemedText {
                text: " " + (root.pacmanUpdates === "..." ? "·" : root.pacmanUpdates)
                font.pixelSize: Constants.sizeSm
                elide: Text.ElideRight
                color: parseInt(root.pacmanUpdates) > 0 ? Colors.blueArch : Colors.fg
            }

        }

        RowLayout {
            ThemedText {
                text: "AUR:"
                font.pixelSize: Constants.sizeSm
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            ThemedText {
                text: "󰊤 " + (root.aurUpdates === "..." ? "·" : root.aurUpdates)
                font.pixelSize: Constants.sizeSm
                elide: Text.ElideRight
                color: parseInt(root.pacmanUpdates) > 0 ? Colors.muted : Colors.fg
            }

        }

        Item {
            visible: root.hasUpdates
            Layout.fillWidth: true
            Layout.preferredHeight: 32

            Rectangle {
                id: updateBtnBg

                anchors.fill: parent
                radius: Constants.sizeXs
                color: updateArea.containsPress ? Qt.rgba(Colors.purple.r, Colors.purple.g, Colors.purple.b, 0.28) : updateArea.containsMouse ? Qt.rgba(Colors.purple.r, Colors.purple.g, Colors.purple.b, 0.16) : Qt.rgba(Colors.purple.r, Colors.purple.g, Colors.purple.b, 0.07)
                border.color: Qt.rgba(Colors.purple.r, Colors.purple.g, Colors.purple.b, 0.3)
                border.width: 1
                scale: updateArea.containsPress ? 0.98 : 1

                Behavior on scale {
                    NumberAnimation {
                        duration: Constants.animNormal
                        easing.type: Easing.OutBack
                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: Constants.animNormal
                    }

                }

            }

            RowLayout {
                anchors.centerIn: parent
                spacing: Constants.sizeXs

                ThemedText {
                    text: "󰚰"
                    color: Colors.purple
                    font.pixelSize: Constants.sizeSm
                    Layout.alignment: Qt.AlignHCenter
                }

                ThemedText {
                    text: "Update"
                    color: Colors.purple
                    font.pixelSize: Constants.sizeSm
                    font.weight: Font.Medium
                    Layout.alignment: Qt.AlignHCenter
                }

            }

            MouseArea {
                id: updateArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.runUpdate()
            }

        }

    }

}
