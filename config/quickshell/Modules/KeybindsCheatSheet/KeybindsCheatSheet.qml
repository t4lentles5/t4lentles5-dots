import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

CenterWindow {
    id: root

    property var keybindData: []

    function loadKeybinds() {
        keybindData = [];
        parseProc.running = true;
    }

    popupId: "keybinds"
    preferredWidth: 1200
    preferredHeight: 800
    onPopupOpened: root.loadKeybinds()

    Process {
        id: parseProc

        command: ["python3", Quickshell.shellDir + "/Scripts/parse_keybinds.py"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    root.keybindData = JSON.parse(parseOutput.text);
                } catch (e) {
                    console.error("Error parsing keybinds JSON: " + e);
                }
            }
        }

        stdout: StdioCollector {
            id: parseOutput
        }

    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: 12

        ThemedText {
            text: "󰌌"
            color: Theme.colPurple
            font.pixelSize: 28
        }

        ThemedText {
            text: "Hyprland Keybinds"
            color: Theme.colFg
            font.pixelSize: Theme.fontSizeLg
            font.bold: true
        }

    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 20

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            contentHeight: col1.implicitHeight
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: col1

                width: parent.width
                spacing: 12

                Repeater {
                    model: {
                        let half = Math.ceil(root.keybindData.length / 2);
                        return root.keybindData.slice(0, half);
                    }

                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        SectionHeader {
                            label: modelData.section
                        }

                        Repeater {
                            model: modelData.binds

                            KeybindItem {
                                keys: modelData.keys
                                desc: modelData.desc
                            }

                        }

                    }

                }

            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                active: true
            }

        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.colBgLighter
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            contentHeight: col2.implicitHeight
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: col2

                width: parent.width
                spacing: 12

                Repeater {
                    model: {
                        let half = Math.ceil(root.keybindData.length / 2);
                        return root.keybindData.slice(half);
                    }

                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        SectionHeader {
                            label: modelData.section
                        }

                        Repeater {
                            model: modelData.binds

                            KeybindItem {
                                keys: modelData.keys
                                desc: modelData.desc
                            }

                        }

                    }

                }

            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                active: true
            }

        }

    }

    component SectionHeader: RowLayout {
        property string label

        Layout.fillWidth: true
        Layout.topMargin: 4
        spacing: 10

        Rectangle {
            width: 3
            height: 16
            radius: 2
            color: Theme.colPurple
        }

        ThemedText {
            text: label
            color: Theme.colPurple
            font.pixelSize: Theme.fontSizeMd
            font.bold: true
            font.capitalization: Font.AllUppercase
            Layout.fillWidth: true
        }

    }

    component KeybindItem: RowLayout {
        property list<string> keys
        property string desc

        Layout.fillWidth: true
        spacing: Theme.spacingSm

        Row {
            spacing: 4
            Layout.preferredWidth: 180
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: keys

                delegate: Row {
                    required property string modelData
                    required property int index

                    spacing: 4

                    Rectangle {
                        width: Math.max(capText.implicitWidth + 14, 28)
                        height: 26
                        radius: 5
                        color: Theme.colBgSecondary


                        ThemedText {
                            id: capText

                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -1
                            text: modelData
                            color: Theme.colYellow
                            font.pixelSize: Theme.fontSizeSm
                            font.bold: true
                        }

                    }

                    ThemedText {
                        visible: index < keys.length - 1
                        text: "+"
                        color: Theme.colMuted
                        font.pixelSize: Theme.fontSizeSm
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

            }

        }

        ThemedText {
            text: desc
            color: Theme.colFg
            font.pixelSize: Theme.fontSizeMd - 1
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

    }

}
