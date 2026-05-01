import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

CenterWindow {
    id: root

    property var hyprlandData: []
    property var nvimData: []
    property int activeTab: 0
    property int selectedCategory: 0
    property var currentData: activeTab === 0 ? hyprlandData : nvimData
    property var currentBinds: {
        if (currentData.length === 0)
            return [];

        if (selectedCategory < 0 || selectedCategory >= currentData.length)
            return [];

        return currentData[selectedCategory].binds;
    }

    function loadKeybinds() {
        hyprlandData = [];
        nvimData = [];
        activeTab = 0;
        selectedCategory = 0;
        hyprProc.running = true;
        nvimProc.running = true;
    }

    function processKeybindData(rawData) {
        let processed = [];
        for (let i = 0; i < rawData.length; i++) {
            let section = rawData[i];
            let newBinds = [];
            let bindCount = 0;
            for (let j = 0; j < section.binds.length; j++) {
                let bind = section.binds[j];
                if (bind.is_subheader) {
                    newBinds.push({
                        "is_subheader": true,
                        "name": bind.name,
                        "uiElements": [],
                        "desc": ""
                    });
                    continue;
                }
                bindCount++;
                let keys = bind.keys;
                let desc = bind.desc;
                let result = [];
                let multiKeys = [];
                let joiner = "";
                if (desc.endsWith(" ←→↑↓")) {
                    desc = desc.replace(" ←→↑↓", "");
                    multiKeys = ["↕ ↔"];
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
                "binds": newBinds,
                "bindCount": bindCount
            });
        }
        return processed;
    }

    popupId: "keybinds"
    preferredWidth: 850
    preferredHeight: 550
    onPopupOpened: root.loadKeybinds()

    Shortcut {
        sequence: "Tab"
        enabled: root.isOpen
        onActivated: {
            root.activeTab = root.activeTab === 0 ? 1 : 0;
            root.selectedCategory = 0;
        }
    }

    Process {
        id: hyprProc

        command: ["python3", Quickshell.shellDir + "/Scripts/parse_keybinds.py"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    let rawData = JSON.parse(hyprOutput.text);
                    root.hyprlandData = processKeybindData(rawData);
                } catch (e) {
                    console.error("Error parsing Hyprland keybinds: " + e);
                }
            }
        }

        stdout: StdioCollector {
            id: hyprOutput
        }

    }

    Process {
        id: nvimProc

        command: ["python3", Quickshell.shellDir + "/Scripts/parse_keybinds.py", "--nvim"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    let rawData = JSON.parse(nvimOutput.text);
                    root.nvimData = processKeybindData(rawData);
                } catch (e) {
                    console.error("Error parsing Neovim keybinds: " + e);
                }
            }
        }

        stdout: StdioCollector {
            id: nvimOutput
        }

    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Constants.sizeLg

        Flickable {
            Layout.preferredWidth: 170
            Layout.fillHeight: true
            contentHeight: sidebarCol.implicitHeight
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: sidebarCol

                width: parent.width
                spacing: 2

                ThemedText {
                    text: "Environment"
                    color: Theme.muted
                    font.pixelSize: 10
                    font.bold: true
                    Layout.leftMargin: Constants.sizeXs
                    Layout.topMargin: Constants.sizeXs
                    Layout.bottomMargin: 2
                }

                SidebarItem {
                    label: "Hyprland"
                    icon: "󰖲"
                    isActive: root.activeTab === 0
                    onClicked: {
                        root.activeTab = 0;
                        root.selectedCategory = 0;
                    }
                }

                SidebarItem {
                    label: "Neovim"
                    icon: ""
                    isActive: root.activeTab === 1
                    onClicked: {
                        root.activeTab = 1;
                        root.selectedCategory = 0;
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    Layout.margins: Constants.sizeXs
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    color: Theme.bgSecondary
                }

                ThemedText {
                    text: "Categories"
                    color: Theme.muted
                    font.pixelSize: 10
                    font.bold: true
                    Layout.leftMargin: Constants.sizeXs
                    Layout.bottomMargin: 2
                }

                Repeater {
                    model: root.currentData

                    delegate: SidebarItem {
                        label: modelData.section
                        subLabel: modelData.bindCount
                        isActive: index === root.selectedCategory
                        onClicked: root.selectedCategory = index
                    }

                }

            }

        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.bgSecondary
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: bindsCol.implicitHeight + (Constants.sizeMd * 2)
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: bindsCol

                width: parent.width - (Constants.sizeMd * 2)
                x: Constants.sizeMd
                y: Constants.sizeMd
                spacing: 4

                Repeater {
                    model: root.currentBinds

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? 24 : 0
                            Layout.topMargin: visible ? (index === 0 ? 0 : Constants.sizeLg) : 0
                            Layout.bottomMargin: visible ? Constants.sizeSm : 0
                            color: "transparent"
                            visible: modelData.is_subheader === true

                            ThemedText {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 4
                                text: modelData.name || ""
                                color: Theme.purple
                                font.pixelSize: Constants.sizeMd
                                font.bold: true
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 1
                                color: Theme.bgSecondary
                            }

                        }

                        KeybindItem {
                            visible: modelData.is_subheader !== true
                            uiElements: modelData.uiElements || []
                            desc: modelData.desc || ""
                        }

                    }

                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 100
                    visible: root.currentBinds.length === 0

                    ThemedText {
                        anchors.centerIn: parent
                        text: "No keybinds loaded"
                        color: Theme.muted
                        font.pixelSize: Constants.sizeMd
                    }

                }

            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
                visible: size < 1
            }

        }

    }

    component SidebarItem: Rectangle {
        property string icon
        property string label
        property string subLabel
        property bool isActive: false

        signal clicked()

        Layout.fillWidth: true
        Layout.preferredHeight: 32
        radius: Constants.sizeXs
        color: isActive ? Theme.bgSecondary : (itemHover.hovered ? Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, 0.5) : Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, 0))

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Constants.sizeXs
            anchors.rightMargin: Constants.sizeXs
            spacing: Constants.sizeXs

            Rectangle {
                width: 3
                height: 14
                radius: 2
                color: Theme.purple
                visible: isActive
            }

            ThemedText {
                text: icon
                visible: icon !== ""
                color: isActive ? Theme.purple : Theme.fg
                font.pixelSize: Constants.sizeMd
                Layout.preferredWidth: 20
                horizontalAlignment: Text.AlignHCenter
            }

            ThemedText {
                text: label
                color: isActive ? Theme.purple : Theme.fg
                font.pixelSize: Constants.sizeSm
                font.bold: isActive
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            ThemedText {
                text: subLabel
                visible: subLabel !== ""
                color: Theme.muted
                font.pixelSize: 10
            }

        }

        HoverHandler {
            id: itemHover
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }

        Behavior on color {
            ColorAnimation {
                duration: Constants.animFast
            }

        }

    }

    component KeybindItem: RowLayout {
        property var uiElements
        property string desc

        Layout.fillWidth: true
        spacing: Constants.sizeLg

        Row {
            spacing: 4
            Layout.preferredWidth: 260
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
                        color: Theme.bgSecondary
                        anchors.verticalCenter: parent.verticalCenter

                        ThemedText {
                            id: capText

                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -1
                            text: modelData.isKey ? modelData.text : ""
                            color: Theme.yellow
                            font.pixelSize: Constants.sizeSm
                            font.bold: true
                        }

                    }

                    ThemedText {
                        id: sepText

                        visible: !modelData.isKey
                        text: !modelData.isKey ? modelData.text : ""
                        color: Theme.muted
                        font.pixelSize: Constants.sizeMd
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
