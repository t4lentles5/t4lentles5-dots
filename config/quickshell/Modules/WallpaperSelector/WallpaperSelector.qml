import Qt5Compat.GraphicalEffects
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
    property int currentTab: 0

    function filterWallpapers(query) {
        filteredModel.clear();
        query = query.toLowerCase();
        for (let i = 0; i < wallModel.count; i++) {
            let wall = wallModel.get(i);
            let matchesTab = false;
            if (currentTab === 0 && wall.type === "Dark")
                matchesTab = true;
            else if (currentTab === 1 && wall.type === "Light")
                matchesTab = true;
            if (matchesTab && wall.name.toLowerCase().includes(query))
                filteredModel.append(wall);

        }
        if (WallpaperManager.currentWallpaper) {
            for (let j = 0; j < filteredModel.count; j++) {
                if (filteredModel.get(j).name === WallpaperManager.currentWallpaper) {
                    wallView.currentIndex = j;
                    return ;
                }
            }
        }
        if (filteredModel.count > 0)
            wallView.currentIndex = 0;
        else
            wallView.currentIndex = -1;
    }

    function setWallpaper(targetPath, wType) {
        if (!targetPath)
            return ;

        let parts = targetPath.split('/');
        let wallName = parts[parts.length - 1];
        WallpaperManager.applyWallpaperWithSync(wallName, targetPath, wType);
        root.isOpen = false;
    }

    popupId: "wallpaper"
    preferredHeight: 550
    preferredWidth: 800
    onPopupOpened: {
        let brightness = Theme.bg.r * 0.299 + Theme.bg.g * 0.587 + Theme.bg.b * 0.114;
        currentTab = (brightness <= 0.5) ? 0 : 1;
        focusTimer.start();
        searchField.text = "";
        loadWallpapersProc.lines = [];
        loadWallpapersProc.running = true;
    }

    Timer {
        id: focusTimer

        interval: 50
        repeat: false
        onTriggered: searchField.forceActiveFocus()
    }

    ListModel {
        id: wallModel
    }

    ListModel {
        id: filteredModel
    }

    Process {
        id: loadWallpapersProc

        property var lines: []

        command: ["bash", "-c", "find ~/Pictures/Wallpapers -type f 2>/dev/null | grep -iE '\\.(jpg|jpeg|png|webp|gif)$'"]
        onExited: function(exitCode) {
            wallModel.clear();
            let sortedLines = lines.sort(function(a, b) {
                return a.name.localeCompare(b.name);
            });
            for (let i = 0; i < sortedLines.length; i++) {
                wallModel.append(sortedLines[i]);
            }
            lines = [];
            filterWallpapers(searchField.text);
        }

        stdout: SplitParser {
            onRead: function(data) {
                let linesArr = data.split('\n');
                for (let i = 0; i < linesArr.length; i++) {
                    let rawPath = linesArr[i].trim();
                    if (rawPath !== "") {
                        let parts = rawPath.split('/');
                        let fileName = parts[parts.length - 1];
                        let wType = "Dark";
                        if (rawPath.includes("/Light/"))
                            wType = "Light";

                        loadWallpapersProc.lines.push({
                            "filePath": "file://" + rawPath,
                            "rawPath": rawPath,
                            "name": fileName,
                            "type": wType
                        });
                    }
                }
            }
        }

    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        color: Theme.bgSecondary
        radius: Constants.sizeXl

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
                placeholderText: currentTab === 0 ? "Search Dark wallpapers... (Tab to switch)" : "Search Light wallpapers... (Tab to switch)"
                placeholderTextColor: Theme.muted
                color: Theme.fg
                font.pixelSize: Constants.sizeMd
                font.family: Constants.fontFamily
                background: null
                onTextChanged: root.filterWallpapers(text)
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Tab) {
                        currentTab = currentTab === 0 ? 1 : 0;
                        filterWallpapers(searchField.text);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right) {
                        if (wallView.count > 0) {
                            wallView.currentIndex = Math.min(wallView.currentIndex + 1, wallView.count - 1);
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Left) {
                        if (wallView.count > 0) {
                            wallView.currentIndex = Math.max(wallView.currentIndex - 1, 0);
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Down) {
                        if (wallView.count > 0) {
                            let nextIdx = wallView.currentIndex + 3;
                            wallView.currentIndex = Math.min(nextIdx, wallView.count - 1);
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Up) {
                        if (wallView.count > 0) {
                            let prevIdx = wallView.currentIndex - 3;
                            wallView.currentIndex = Math.max(prevIdx, 0);
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        let idx = wallView.currentIndex >= 0 ? wallView.currentIndex : 0;
                        if (filteredModel.count > idx) {
                            let wall = filteredModel.get(idx);
                            setWallpaper(wall.rawPath, wall.type);
                            event.accepted = true;
                        }
                    }
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

            ThemedText {
                text: "󰸉"
                color: Theme.bgSecondary
                font.pixelSize: 72
                Layout.alignment: Qt.AlignHCenter
            }

            ThemedText {
                text: "No wallpapers found in ~/Pictures/Wallpapers"
                color: Theme.muted
                font.pixelSize: Constants.sizeMd
                Layout.alignment: Qt.AlignHCenter
            }

        }

        ColumnLayout {
            anchors.centerIn: parent
            visible: filteredModel.count === 0 && searchField.text !== ""

            ThemedText {
                text: "󰩉"
                color: Theme.muted
                font.pixelSize: 72
                Layout.alignment: Qt.AlignHCenter
            }

            ThemedText {
                text: "No matches found"
                color: Theme.muted
                font.pixelSize: Constants.sizeMd
                Layout.alignment: Qt.AlignHCenter
            }

        }

        GridView {
            id: wallView

            anchors.fill: parent
            clip: true
            model: filteredModel
            cellWidth: Math.floor(width / 3)
            cellHeight: Math.floor(cellWidth * 0.65)
            currentIndex: -1
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 250
            visible: filteredModel.count > 0

            add: Transition {
                NumberAnimation {
                    properties: "opacity, scale"
                    from: 0
                    to: 1
                    duration: Constants.animSlow
                    easing.type: Easing.OutQuint
                }

            }

            highlight: Item {
                width: wallView.cellWidth
                height: wallView.cellHeight
                z: 6

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Constants.sizeXs
                    radius: Constants.sizeXs
                    color: "transparent"
                    border.color: Theme.purple
                    border.width: 2
                    scale: 1.05

                    Behavior on scale {
                        NumberAnimation {
                            duration: Constants.animSlow
                            easing.type: Easing.OutQuint
                        }

                    }

                }

            }

            populate: Transition {
                NumberAnimation {
                    properties: "opacity, scale"
                    from: 0
                    to: 1
                    duration: Constants.animSlow
                    easing.type: Easing.OutQuint
                }

            }

            delegate: Item {
                id: delegateRoot

                readonly property bool isCurrent: wallView.currentIndex === index

                width: wallView.cellWidth
                height: wallView.cellHeight
                z: isCurrent || hoverHandler.hovered ? 5 : 1

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Constants.sizeXs
                    radius: Constants.sizeXs
                    color: Theme.bgSecondary
                    scale: isCurrent || hoverHandler.hovered ? 1.05 : 1

                    Rectangle {
                        id: maskRect

                        anchors.fill: parent
                        anchors.margins: isCurrent ? 2 : 1
                        radius: Constants.sizeXs
                        visible: false
                    }

                    Item {
                        anchors.fill: maskRect
                        layer.enabled: true

                        Image {
                            id: thumbImg

                            anchors.fill: parent
                            source: model.filePath
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            sourceSize: Qt.size(400, 300)
                        }

                        layer.effect: OpacityMask {
                            maskSource: maskRect
                        }

                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: nameText.contentHeight + Constants.sizeXs
                        color: Theme.bgSecondary
                        radius: Constants.sizeXs

                        ThemedText {
                            id: nameText

                            anchors.centerIn: parent
                            width: parent.width - Constants.sizeSm
                            text: model.name
                            font.pixelSize: Constants.sizeSm
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }

                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: Constants.animSlow
                            easing.type: Easing.OutQuint
                        }

                    }

                }

                HoverHandler {
                    id: hoverHandler
                }

                TapHandler {
                    onTapped: {
                        wallView.currentIndex = index;
                        setWallpaper(model.rawPath, model.type);
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
