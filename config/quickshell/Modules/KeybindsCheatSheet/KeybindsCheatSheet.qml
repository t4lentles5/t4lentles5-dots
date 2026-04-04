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
                    let rawData = JSON.parse(parseOutput.text);
                    let processed = [];
                    for (let i = 0; i < rawData.length; i++) {
                        let section = rawData[i];
                        let newBinds = [];
                        for (let j = 0; j < section.binds.length; j++) {
                            let bind = section.binds[j];
                            let keys = bind.keys;
                            let desc = bind.desc;
                            let result = [];
                            let multiKeys = [];
                            let joiner = "";
                            if (desc.endsWith(" ←→↑↓")) {
                                desc = desc.replace(" ←→↑↓", "");
                                multiKeys = ["←", "→", "↑", "↓"];
                            } else if (desc.endsWith(" 1..0")) {
                                desc = desc.replace(" 1..0", "");
                                multiKeys = ["1", "0"];
                                joiner = "..";
                            } else if (desc === "Previous / Next Workspace") {
                                multiKeys = ["←", "→"];
                                joiner = "/";
                            } else if (desc === "Scroll Through Workspaces") {
                                multiKeys = ["Scroll ↓", "Scroll ↑"];
                                joiner = "/";
                            } else {
                                multiKeys = [keys[keys.length - 1]];
                            }
                            for (let k = 0; k < keys.length - 1; k++) {
                                result.push({
                                    "text": keys[k],
                                    "isKey": true
                                });
                                result.push({
                                    "text": "+",
                                    "isKey": false
                                });
                            }
                            for (let k = 0; k < multiKeys.length; k++) {
                                result.push({
                                    "text": multiKeys[k],
                                    "isKey": true
                                });
                                if (k < multiKeys.length - 1 && joiner !== "")
                                    result.push({
                                    "text": joiner,
                                    "isKey": false
                                });

                            }
                            newBinds.push({
                                "uiElements": result,
                                "desc": desc
                            });
                        }
                        processed.push({
                            "section": section.section,
                            "binds": newBinds
                        });
                    }
                    root.keybindData = processed;
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
        spacing: Constants.sizeXs

        ThemedText {
            text: "󰌌"
            color: Colors.purple
            font.pixelSize: Constants.sizeXl
        }

        ThemedText {
            text: "Keybinds"
            font.pixelSize: Constants.sizeLg
            font.bold: true
        }

    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Constants.sizeXs

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
                spacing: Constants.sizeXs

                Repeater {
                    model: {
                        let half = Math.ceil(root.keybindData.length / 2);
                        return root.keybindData.slice(0, half);
                    }

                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Constants.sizeXs

                        SectionHeader {
                            label: modelData.section
                        }

                        Repeater {
                            model: modelData.binds

                            KeybindItem {
                                uiElements: modelData.uiElements
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
            color: Colors.bgSecondary
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
                spacing: Constants.sizeXs

                Repeater {
                    model: {
                        let half = Math.ceil(root.keybindData.length / 2);
                        return root.keybindData.slice(half);
                    }

                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Constants.sizeXs

                        SectionHeader {
                            label: modelData.section
                        }

                        Repeater {
                            model: modelData.binds

                            KeybindItem {
                                uiElements: modelData.uiElements
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
        spacing: Constants.sizeXs

        Rectangle {
            width: 3
            height: 16
            radius: 2
            color: Colors.purple
        }

        ThemedText {
            text: label
            color: Colors.purple
            font.pixelSize: Constants.sizeSm
            font.bold: true
            font.capitalization: Font.AllUppercase
            Layout.fillWidth: true
        }

    }

    component KeybindItem: RowLayout {
        property var uiElements
        property string desc

        Layout.fillWidth: true
        spacing: Constants.sizeXs

        Row {
            spacing: 4
            Layout.preferredWidth: 320
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: uiElements

                delegate: Item {
                    required property var modelData

                    width: modelData.isKey ? keyRect.width : sepText.implicitWidth
                    height: 26

                    Rectangle {
                        id: keyRect

                        visible: modelData.isKey
                        width: Math.max(capText.implicitWidth + 14, 28)
                        height: 26
                        radius: 5
                        color: Colors.bgSecondary
                        anchors.verticalCenter: parent.verticalCenter

                        ThemedText {
                            id: capText

                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -1
                            text: modelData.isKey ? modelData.text : ""
                            color: Colors.yellow
                            font.pixelSize: Constants.sizeSm
                            font.bold: true
                        }

                    }

                    ThemedText {
                        id: sepText

                        visible: !modelData.isKey
                        text: !modelData.isKey ? modelData.text : ""
                        color: Colors.muted
                        font.pixelSize: Constants.sizeSm
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

            }

        }

        ThemedText {
            text: desc
            font.pixelSize: Constants.sizeSm
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

    }

}
