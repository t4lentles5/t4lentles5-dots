import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Core

CenterWindow {
    id: root

    property string searchText: ""

    function filterClipboard(query) {
        filteredModel.clear();
        query = query.toLowerCase();
        for (let i = 0; i < clipboardModel.count; i++) {
            let item = clipboardModel.get(i);
            if (item.text.toLowerCase().includes(query))
                filteredModel.append(item);

        }
        if (filteredModel.count > 0)
            clipboardView.currentIndex = 0;
        else
            clipboardView.currentIndex = -1;
    }

    function copyToClipboard(itemId) {
        if (!itemId)
            return ;

        copyProc.command = ["bash", "-c", "cliphist decode " + itemId + " | wl-copy"];
        copyProc.startDetached();
        root.isOpen = false;
    }

    function clearHistory() {
        clearProc.running = false;
        clearProc.running = true;
    }

    popupId: "clipboard"
    preferredHeight: 480
    preferredWidth: 600
    onPopupOpened: {
        focusTimer.start();
        searchField.text = "";
        loadClipboardProc.running = true;
    }

    Timer {
        id: focusTimer

        interval: 50
        repeat: false
        onTriggered: searchField.forceActiveFocus()
    }

    ListModel {
        id: clipboardModel
    }

    ListModel {
        id: filteredModel
    }

    Process {
        id: loadClipboardProc

        command: ["cliphist", "list"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                clipboardModel.clear();
                let output = clipboardOutput.text.trim();
                if (output === "") {
                    filterClipboard("");
                    return ;
                }
                let lines = output.split('\n');
                lines.forEach(function(line) {
                    if (line.trim() === "")
                        return ;

                    let parts = line.split('\t');
                    if (parts.length >= 2)
                        clipboardModel.append({
                        "itemId": parts[0],
                        "text": parts.slice(1).join('\t')
                    });

                });
                filterClipboard("");
            }
        }

        stdout: StdioCollector {
            id: clipboardOutput
        }

    }

    Process {
        id: copyProc
    }

    Process {
        id: clearProc

        command: ["cliphist", "wipe"]
        onExited: function(exitCode) {
            if (exitCode === 0)
                loadClipboardProc.running = true;

        }
    }

    ColumnLayout {
        spacing: 20

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                id: searchBar

                Layout.fillWidth: true
                Layout.preferredHeight: 48
                color: Theme.colBgSecondary
                radius: 8

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: searchField.activeFocus ? Theme.colPurple : Theme.colBgLighter

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                        }

                    }

                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 16

                    Text {
                        text: ""
                        color: searchField.activeFocus ? Theme.colPurple : Theme.colMuted
                        font.pixelSize: 22
                        font.family: Theme.fontFamily

                        Behavior on color {
                            ColorAnimation {
                                duration: 250
                            }

                        }

                    }

                    TextField {
                        id: searchField

                        Layout.fillWidth: true
                        placeholderText: "Search clipboard history..."
                        placeholderTextColor: Theme.colMuted
                        color: Theme.colFg
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        background: null
                        onTextChanged: root.filterClipboard(text)
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Down) {
                                if (clipboardView.count > 0) {
                                    clipboardView.currentIndex = Math.min(clipboardView.currentIndex + 1, clipboardView.count - 1);
                                    event.accepted = true;
                                }
                            } else if (event.key === Qt.Key_Up) {
                                if (clipboardView.count > 0) {
                                    clipboardView.currentIndex = Math.max(clipboardView.currentIndex - 1, 0);
                                    event.accepted = true;
                                }
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                let idx = clipboardView.currentIndex >= 0 ? clipboardView.currentIndex : 0;
                                if (filteredModel.count > idx) {
                                    let item = filteredModel.get(idx);
                                    copyToClipboard(item.itemId);
                                    event.accepted = true;
                                }
                            }
                        }
                    }

                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 250
                    }

                }

            }

            Rectangle {
                id: clearButton

                Layout.preferredHeight: 48
                Layout.preferredWidth: 48
                color: Theme.colBgSecondary
                radius: 8

                Text {
                    anchors.centerIn: parent
                    text: "󰆴"
                    color: clearHover.hovered ? Theme.colRed : Theme.colMuted
                    font.pixelSize: 22

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                        }

                    }

                }

                HoverHandler {
                    id: clearHover
                }

                TapHandler {
                    onTapped: root.clearHistory()
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 250
                    }

                }

            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                visible: filteredModel.count === 0 && searchField.text === ""
                spacing: 16

                Text {
                    text: "󰅍"
                    color: Theme.colBgLighter
                    font.pixelSize: 72
                    font.family: Theme.fontFamily
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Clipboard is empty"
                    color: Theme.colMuted
                    font.pixelSize: 16
                    font.family: Theme.fontFamily
                    Layout.alignment: Qt.AlignHCenter
                }

            }

            ColumnLayout {
                anchors.centerIn: parent
                visible: filteredModel.count === 0 && searchField.text !== ""
                spacing: 16

                Text {
                    text: "󰩉"
                    color: Theme.colBgLighter
                    font.pixelSize: 72
                    font.family: Theme.fontFamily
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "No results found"
                    color: Theme.colMuted
                    font.pixelSize: 16
                    font.family: Theme.fontFamily
                    Layout.alignment: Qt.AlignHCenter
                }

            }

            ListView {
                id: clipboardView

                anchors.fill: parent
                clip: true
                model: filteredModel
                spacing: 8
                currentIndex: -1
                highlightResizeDuration: 0
                highlightMoveDuration: 250
                highlightFollowsCurrentItem: true
                visible: filteredModel.count > 0
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Up) {
                        if (currentIndex <= 0) {
                            searchField.forceActiveFocus();
                            currentIndex = -1;
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (currentIndex >= 0) {
                            let item = filteredModel.get(currentIndex);
                            copyToClipboard(item.itemId);
                            event.accepted = true;
                        }
                    }
                }

                highlight: Item {
                    width: clipboardView.width
                    height: 44
                    z: 1

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: Theme.colBgLighter
                    }

                }

                add: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        from: 0
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuint
                    }

                }

                populate: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        from: 0
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuint
                    }

                }

                delegate: Item {
                    id: delegateRoot

                    readonly property bool isCurrent: clipboardView.currentIndex === index

                    width: clipboardView.width
                    height: 44
                    z: 2

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: Theme.colBgLighter
                        opacity: hoverHandler.hovered && !isCurrent ? 0.4 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }

                        }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 16

                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            radius: 8
                            color: isCurrent ? Theme.colPurple : Theme.colBgSecondary

                            Text {
                                anchors.centerIn: parent
                                text: "󰆏"
                                color: isCurrent ? Theme.colBg : Theme.colFg
                                font.pixelSize: 18
                                font.family: Theme.fontFamily

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 250
                                    }

                                }

                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 250
                                }

                            }

                        }

                        Text {
                            text: model.text
                            color: isCurrent ? Theme.colPurple : Theme.colFg
                            font.family: Theme.fontFamily
                            font.bold: isCurrent
                            font.pixelSize: 14
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            scale: isCurrent ? 1.01 : 1
                            transformOrigin: Item.Left

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }

                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 250
                                    easing.type: Easing.OutQuint
                                }

                            }

                        }

                    }

                    HoverHandler {
                        id: hoverHandler
                    }

                    TapHandler {
                        onTapped: copyToClipboard(model.itemId)
                    }

                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    active: true
                }

            }

        }

    }

}
