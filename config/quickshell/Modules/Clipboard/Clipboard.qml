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
        spacing: Theme.sizeLg

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.sizeXs

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: Theme.colBgSecondary
                radius: Theme.sizeXl

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.sizeLg
                    anchors.rightMargin: Theme.sizeLg
                    spacing: Theme.sizeXs

                    ThemedText {
                        text: ""
                        color: Theme.colFg
                        font.pixelSize: Theme.sizeLg
                    }

                    TextField {
                        id: searchField

                        Layout.fillWidth: true
                        placeholderText: "Search clipboard history..."
                        placeholderTextColor: Theme.colMuted
                        color: Theme.colFg
                        font.pixelSize: Theme.sizeMd
                        font.family: Theme.fontFamily
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

            }

            Rectangle {
                id: clearButton

                Layout.preferredHeight: 40
                Layout.preferredWidth: 40
                color: Theme.colBgSecondary
                radius: 20

                ThemedText {
                    anchors.centerIn: parent
                    text: "󰆴"
                    color: clearHover.hovered ? Theme.colRed : Theme.colMuted
                    font.pixelSize: Theme.sizeXl

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animNormal
                        }

                    }

                }

                HoverHandler {
                    id: clearHover
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.clearHistory()
                }

            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                visible: filteredModel.count === 0 && searchField.text === ""

                ThemedText {
                    text: "󰅍"
                    color: Theme.colMuted
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                ThemedText {
                    text: "Clipboard is empty"
                    color: Theme.colMuted
                    font.pixelSize: Theme.sizeMd
                    Layout.alignment: Qt.AlignHCenter
                }

            }

            ColumnLayout {
                anchors.centerIn: parent
                visible: filteredModel.count === 0 && searchField.text !== ""

                ThemedText {
                    text: "󰩉"
                    color: Theme.colMuted
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                ThemedText {
                    text: "No results found"
                    color: Theme.colMuted
                    font.pixelSize: Theme.sizeMd
                    Layout.alignment: Qt.AlignHCenter
                }

            }

            ListView {
                id: clipboardView

                anchors.fill: parent
                clip: true
                model: filteredModel
                spacing: Theme.sizeXs
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
                        radius: Theme.sizeXs
                        color: Theme.colBgSecondary

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 2
                            anchors.topMargin: 8
                            anchors.bottomMargin: 8
                            width: 3
                            radius: 2
                            color: Theme.colPurple
                        }

                    }

                }

                add: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        from: 0
                        to: 1
                        duration: Theme.animNormal
                        easing.type: Easing.OutQuint
                    }

                }

                populate: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        from: 0
                        to: 1
                        duration: Theme.animNormal
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
                        radius: Theme.sizeXs
                        color: Theme.colBgSecondary
                        opacity: hoverHandler.hovered && !isCurrent ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.animNormal
                            }

                        }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.sizeLg
                        anchors.rightMargin: Theme.sizeLg
                        spacing: Theme.sizeLg

                        ThemedText {
                            text: model.text
                            color: isCurrent ? Theme.colPurple : Theme.colFg
                            font.bold: isCurrent
                            font.pixelSize: Theme.sizeMd
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            scale: isCurrent ? 1.01 : 1
                            transformOrigin: Item.Left

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animNormal
                                }

                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Theme.animNormal
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
