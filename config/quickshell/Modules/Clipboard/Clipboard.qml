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
    onIsOpenChanged: {
        if (isOpen) {
            focusTimer.start();
            searchField.text = "";
            loadClipboardProc.running = true;
        }
    }
    preferredHeight: 500
    preferredWidth: 600
    Component.onCompleted: socketCleanup.running = true

    Timer {
        id: focusTimer

        interval: 50
        repeat: false
        onTriggered: searchField.forceActiveFocus()
    }

    SocketServer {
        id: server

        path: "/tmp/quickshell_clipboard"
        active: false

        handler: Component {
            Socket {
                onConnectedChanged: {
                    if (connected) {
                        root.isOpen = !root.isOpen;
                        connected = false;
                    }
                }
            }

        }

    }

    Process {
        id: socketCleanup

        command: ["rm", "-f", "/tmp/quickshell_clipboard"]
        onExited: (exitCode) => {
            return server.active = true;
        }
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
        onExited: (exitCode) => {
            if (exitCode === 0) {
                clipboardModel.clear();
                let output = clipboardOutput.text.trim();
                if (output === "") {
                    filterClipboard("");
                    return ;
                }
                let lines = output.split('\n');
                lines.forEach((line) => {
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
        onExited: (exitCode) => {
            if (exitCode === 0)
                loadClipboardProc.running = true;

        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            id: searchBar

            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: Theme.colBgSecondary
            radius: 12
            border.color: searchField.activeFocus ? Theme.colPurple : Theme.colMuted
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 12

                Text {
                    text: ""
                    color: Theme.colMuted
                    font.pixelSize: 18
                    font.family: Theme.fontFamily
                }

                TextField {
                    id: searchField

                    Layout.fillWidth: true
                    placeholderText: "Search clipboard..."
                    placeholderTextColor: Theme.colMuted
                    color: Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                    background: null
                    onTextChanged: root.filterClipboard(text)
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Down) {
                            if (clipboardView.count > 0) {
                                clipboardView.currentIndex = 0;
                                clipboardView.forceActiveFocus();
                                event.accepted = true;
                            }
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (filteredModel.count > 0) {
                                let item = filteredModel.get(clipboardView.currentIndex >= 0 ? clipboardView.currentIndex : 0);
                                copyToClipboard(item.itemId);
                                event.accepted = true;
                            }
                        }
                    }
                }

            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

        Rectangle {
            id: clearButton

            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            radius: 12
            color: Theme.colBgSecondary
            border.color: clearHover.hovered ? Theme.colRed : Theme.colMuted
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "󰆴"
                color: clearHover.hovered ? Theme.colRed : Theme.colMuted
                font.pixelSize: 22

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }

            HoverHandler {
                id: clearHover
            }

            TapHandler {
                onTapped: root.clearHistory()
            }

            ToolTip {
                visible: clearHover.hovered
                text: "Clear History"
                delay: 500
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

    }

    ListView {
        id: clipboardView

        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        model: filteredModel
        spacing: 5
        currentIndex: -1
        highlightResizeDuration: 0
        highlightMoveDuration: 200
        highlightFollowsCurrentItem: true
        Keys.onPressed: (event) => {
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

        highlight: Rectangle {
            width: clipboardView.width
            height: 50
            radius: 10
            color: Theme.colBgLighter
            border.color: Theme.colPurple
            border.width: 1
            z: 1

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 4
                height: 26
                radius: 2
                color: Theme.colPurple
            }

            Behavior on y {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

        delegate: Item {
            id: delegateRoot

            readonly property bool isCurrent: clipboardView.currentIndex === index

            width: clipboardView.width
            height: 50
            z: 2

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: Theme.colBgLighter
                opacity: hoverHandler.hovered && !isCurrent ? 0.5 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }

                }

            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 22
                anchors.rightMargin: 15
                spacing: 15

                Item {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24

                    Text {
                        anchors.centerIn: parent
                        text: "󰆏"
                        color: isCurrent ? Theme.colPurple : Theme.colMuted
                        font.pixelSize: 20
                        font.family: Theme.fontFamily
                        scale: isCurrent ? 1.2 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutBack
                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

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
                    scale: isCurrent ? 1.02 : 1
                    transformOrigin: Item.Left

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
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
