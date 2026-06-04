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
    property bool isDeleting: false

    function syncModel(listModel, sourceArray) {
        let sourceIds = {
        };
        for (let i = 0; i < sourceArray.length; i++) {
            sourceIds[sourceArray[i].itemId] = true;
        }
        for (let i = listModel.count - 1; i >= 0; i--) {
            if (!sourceIds[listModel.get(i).itemId])
                listModel.remove(i);

        }
        for (let i = 0; i < sourceArray.length; i++) {
            let src = sourceArray[i];
            if (i >= listModel.count) {
                listModel.append(src);
                continue;
            }
            let dest = listModel.get(i);
            if (dest.itemId === src.itemId)
                continue;

            let foundIdx = -1;
            for (let j = i + 1; j < listModel.count; j++) {
                if (listModel.get(j).itemId === src.itemId) {
                    foundIdx = j;
                    break;
                }
            }
            if (foundIdx !== -1)
                listModel.move(foundIdx, i, 1);
            else
                listModel.insert(i, src);
        }
    }

    function filterClipboard(query) {
        let matchedItems = [];
        query = query.toLowerCase();
        for (let i = 0; i < clipboardModel.count; i++) {
            let item = clipboardModel.get(i);
            let isImage = item.isImage !== undefined ? item.isImage : false;
            if (item.text.toLowerCase().includes(query) || (isImage && query === ""))
                matchedItems.push({
                "itemId": item.itemId,
                "text": item.text,
                "fullLine": item.fullLine,
                "isImage": isImage
            });

        }
        syncModel(filteredModel, matchedItems);
        if (filteredModel.count > 0 && clipboardView.currentIndex === -1)
            clipboardView.currentIndex = 0;
        else if (filteredModel.count === 0)
            clipboardView.currentIndex = -1;
    }

    function copyToClipboard(itemId) {
        if (!itemId)
            return ;

        copyProc.command = ["bash", "-c", "cliphist decode " + itemId + " | wl-copy"];
        copyProc.startDetached();
        root.isOpen = false;
    }

    function deleteItem(index, fullLine) {
        isDeleting = true;
        deletingResetTimer.restart();
        filteredModel.remove(index);
        for (let i = 0; i < clipboardModel.count; i++) {
            if (clipboardModel.get(i).fullLine === fullLine) {
                clipboardModel.remove(i);
                break;
            }
        }
        let safeLine = fullLine.replace(/'/g, "'\\''");
        deleteProc.command = ["bash", "-c", "echo '" + safeLine + "' | cliphist delete"];
        deleteProc.startDetached();
    }

    function clearHistory() {
        if (filteredModel.count === 0)
            return ;

        isDeleting = true;
        deletingResetTimer.restart();
        clipboardModel.clear();
        filteredModel.remove(0, filteredModel.count);
        clearProc.running = false;
        clearProc.running = true;
    }

    footerLeftText: filteredModel.count + (filteredModel.count === 1 ? " item" : " items") + " found"
    footerKeyHints: [{
        "key": "↑↓",
        "description": "Navigate"
    }, {
        "key": "󰌑",
        "description": "Select"
    }, {
        "key": "DEL",
        "description": "Delete"
    }]
    popupId: "clipboard"
    preferredHeight: 480
    preferredWidth: 600
    onPopupOpened: {
        clipboardView.currentIndex = -1;
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

    Timer {
        id: deletingResetTimer

        interval: Constants.animSlow + 50
        repeat: false
        onTriggered: root.isDeleting = false
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
                let imageIds = [];
                lines.forEach(function(line) {
                    if (line.trim() === "")
                        return ;

                    let parts = line.split('\t');
                    if (parts.length >= 2) {
                        let text = parts.slice(1).join('\t');
                        let isImage = text.startsWith("[[ binary data") && text.includes("]]");
                        if (isImage)
                            imageIds.push(parts[0]);

                        clipboardModel.append({
                            "itemId": parts[0],
                            "text": text,
                            "fullLine": line,
                            "isImage": isImage
                        });
                    }
                });
                if (imageIds.length > 0) {
                    let cmd = "mkdir -p /tmp/quickshell-clipboard && for id in " + imageIds.join(" ") + "; do if [ ! -f /tmp/quickshell-clipboard/$id.png ]; then cliphist decode $id > /tmp/quickshell-clipboard/$id.png; fi; done";
                    decodeImagesProc.command = ["bash", "-c", cmd];
                    decodeImagesProc.running = true;
                } else {
                    filterClipboard("");
                }
            }
        }

        stdout: StdioCollector {
            id: clipboardOutput
        }

    }

    Process {
        id: decodeImagesProc

        onExited: function(exitCode) {
            filterClipboard("");
        }
    }

    Process {
        id: copyProc
    }

    Process {
        id: deleteProc
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
        spacing: Constants.sizeLg

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeXs

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: Theme.bgSecondary
                radius: Constants.sizeXl
                border.color: searchField.activeFocus ? Qt.rgba(Theme.purple.r, Theme.purple.g, Theme.purple.b, 0.4) : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.2)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Constants.sizeLg
                    anchors.rightMargin: Constants.sizeLg
                    spacing: Constants.sizeXs

                    ThemedText {
                        text: ""
                        font.pixelSize: Constants.sizeLg
                    }

                    TextField {
                        id: searchField

                        Layout.fillWidth: true
                        placeholderText: "Search clipboard history..."
                        placeholderTextColor: Theme.muted
                        color: Theme.fg
                        font.pixelSize: Constants.sizeMd
                        font.family: Constants.fontFamily
                        background: null
                        onTextChanged: root.filterClipboard(text)
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Down) {
                                clipboardView.currentIndex = Math.min(clipboardView.currentIndex + 1, filteredModel.count - 1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up) {
                                clipboardView.currentIndex = Math.max(clipboardView.currentIndex - 1, 0);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                let idx = clipboardView.currentIndex >= 0 ? clipboardView.currentIndex : 0;
                                if (filteredModel.count > idx) {
                                    let item = filteredModel.get(idx);
                                    copyToClipboard(item.itemId);
                                    event.accepted = true;
                                }
                            } else if (event.key === Qt.Key_Delete) {
                                let idx = clipboardView.currentIndex;
                                if (idx >= 0 && filteredModel.count > idx) {
                                    let item = filteredModel.get(idx);
                                    deleteItem(idx, item.fullLine);
                                    event.accepted = true;
                                }
                            }
                        }
                    }

                }

            }

            IconButton {
                icon: "󰆴"
                iconColor: Theme.red
                iconSize: Constants.sizeXl
                visible: filteredModel.count > 0
                onClicked: root.clearHistory()
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                opacity: filteredModel.count === 0 && searchField.text === "" ? 1 : 0
                visible: opacity > 0

                ThemedText {
                    text: "󰅍"
                    color: Theme.muted
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                ThemedText {
                    text: "Clipboard is empty"
                    color: Theme.muted
                    font.pixelSize: Constants.sizeMd
                    Layout.alignment: Qt.AlignHCenter
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Constants.animNormal
                    }

                }

            }

            ColumnLayout {
                anchors.centerIn: parent
                opacity: filteredModel.count === 0 && searchField.text !== "" ? 1 : 0
                visible: opacity > 0

                ThemedText {
                    text: "󰩉"
                    color: Theme.muted
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                ThemedText {
                    text: "No results found"
                    color: Theme.muted
                    font.pixelSize: Constants.sizeMd
                    Layout.alignment: Qt.AlignHCenter
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Constants.animNormal
                    }

                }

            }

            ListView {
                id: clipboardView

                anchors.fill: parent
                clip: true
                model: filteredModel
                spacing: Constants.sizeXs
                currentIndex: -1
                highlightResizeDuration: 0
                highlightMoveDuration: Constants.animNormal
                highlightFollowsCurrentItem: true
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Down) {
                        clipboardView.currentIndex = Math.min(clipboardView.currentIndex + 1, filteredModel.count - 1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up) {
                        clipboardView.currentIndex = Math.max(clipboardView.currentIndex - 1, 0);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        let idx = clipboardView.currentIndex;
                        if (idx >= 0) {
                            let item = filteredModel.get(idx);
                            root.copyToClipboard(item.itemId);
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Delete) {
                        let idx = clipboardView.currentIndex;
                        if (idx >= 0 && filteredModel.count > idx) {
                            let item = filteredModel.get(idx);
                            root.deleteItem(idx, item.fullLine);
                            event.accepted = true;
                        }
                    }
                }

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: root.isOpen ? Constants.animNormal : 0
                        easing.type: Easing.OutQuint
                    }

                }

                populate: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: root.isOpen ? Constants.animNormal : 0
                        easing.type: Easing.OutQuint
                    }

                }

                remove: Transition {
                    NumberAnimation {
                        property: "x"
                        to: root.isDeleting ? clipboardView.width : 0
                        duration: root.isDeleting ? Constants.animSlow : Constants.animFast
                        easing.type: Easing.InExpo
                    }

                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: root.isDeleting ? Constants.animSlow : Constants.animFast
                    }

                }

                removeDisplaced: Transition {
                    SequentialAnimation {
                        PauseAnimation {
                            duration: root.isDeleting ? Constants.animSlow : 0
                        }

                        NumberAnimation {
                            properties: "y"
                            duration: root.isDeleting ? Constants.animSlow : Constants.animFast
                            easing.type: Easing.OutExpo
                        }

                    }

                }

                addDisplaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: root.isOpen ? Constants.animSlow : 0
                        easing.type: Easing.OutExpo
                    }

                }

                highlight: Item {
                    width: clipboardView.width
                    height: clipboardView.currentItem ? clipboardView.currentItem.height : 44
                    z: 1

                    Rectangle {
                        anchors.fill: parent
                        radius: Constants.sizeXs
                        color: Qt.rgba(Theme.purple.r, Theme.purple.g, Theme.purple.b, 0.08)
                        border.color: Qt.rgba(Theme.purple.r, Theme.purple.g, Theme.purple.b, 0.2)
                        border.width: 1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 2
                            anchors.topMargin: 8
                            anchors.bottomMargin: 8
                            width: 3
                            radius: 2
                            color: Theme.purple
                        }

                    }

                }

                delegate: Item {
                    id: delegateRoot

                    readonly property bool isCurrent: clipboardView.currentIndex === index

                    width: clipboardView.width
                    height: Math.max(44, delegateLayout.implicitHeight + Constants.sizeLg)
                    z: 2

                    Rectangle {
                        anchors.fill: parent
                        radius: Constants.sizeXs
                        color: Theme.bgSecondary
                        opacity: hoverHandler.hovered && !isCurrent ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Constants.animNormal
                            }

                        }

                    }

                    RowLayout {
                        id: delegateLayout

                        anchors.fill: parent
                        anchors.leftMargin: Constants.sizeLg
                        anchors.rightMargin: Constants.sizeLg
                        spacing: Constants.sizeLg

                        ThemedText {
                            text: model.text
                            visible: !(model.isImage !== undefined ? model.isImage : false)
                            color: isCurrent ? Theme.purple : Theme.fg
                            font.bold: isCurrent
                            font.pixelSize: Constants.sizeMd
                            wrapMode: isCurrent ? Text.Wrap : Text.NoWrap
                            Layout.fillWidth: true
                            maximumLineCount: isCurrent ? 3 : 1
                            elide: Text.ElideRight
                            scale: isCurrent ? 1.02 : 1
                            transformOrigin: Item.Left

                            Behavior on color {
                                ColorAnimation {
                                    duration: Constants.animNormal
                                }

                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Constants.animNormal
                                    easing.type: Easing.OutQuint
                                }

                            }

                        }

                        Item {
                            visible: model.isImage !== undefined ? model.isImage : false
                            Layout.preferredHeight: visible ? 80 : 0
                            Layout.preferredWidth: visible ? 160 : 0
                            Layout.alignment: Qt.AlignLeft
                            scale: isCurrent ? 1.02 : 1
                            transformOrigin: Item.Left

                            Rectangle {
                                anchors.fill: parent
                                radius: Constants.sizeXs
                                color: Theme.bgSecondary
                                border.color: isCurrent ? Theme.purple : Theme.border
                                border.width: 1
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: parent.parent.visible ? "file:///tmp/quickshell-clipboard/" + model.itemId + ".png" : ""
                                    asynchronous: true
                                    fillMode: Image.PreserveAspectFit
                                }

                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Constants.animNormal
                                    easing.type: Easing.OutQuint
                                }

                            }

                        }

                        Item {
                            Layout.fillWidth: true
                            visible: model.isImage !== undefined ? model.isImage : false
                        }

                        IconButton {
                            icon: "󰅖"
                            iconColor: Theme.red
                            iconSize: Constants.sizeMd
                            Layout.alignment: Qt.AlignVCenter
                            opacity: (hoverHandler.hovered || isCurrent) ? 1 : 0
                            visible: opacity > 0
                            onClicked: {
                                root.deleteItem(index, model.fullLine);
                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Constants.animFast
                                }

                            }

                        }

                    }

                    HoverHandler {
                        id: hoverHandler
                    }

                    TapHandler {
                        onTapped: root.copyToClipboard(model.itemId)
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: Constants.animNormal
                            easing.type: Easing.OutQuint
                        }

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
