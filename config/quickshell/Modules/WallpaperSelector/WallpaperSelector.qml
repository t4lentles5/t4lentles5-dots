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

    function filterWallpapers(query) {
        filteredModel.clear();
        query = query.toLowerCase();
        for (let i = 0; i < wallModel.count; i++) {
            let wall = wallModel.get(i);
            if (wall.name.toLowerCase().includes(query))
                filteredModel.append(wall);

        }
        if (filteredModel.count > 0)
            wallView.currentIndex = 0;
        else
            wallView.currentIndex = -1;
    }

    function setWallpaper(targetPath) {
        if (!targetPath)
            return ;

        wallpaperProc.command = ["swww", "img", targetPath, "--transition-type", "grow", "--transition-pos", "0.5,0.5", "--transition-step", "90"];
        wallpaperProc.startDetached();
        root.isOpen = false;
    }

    popupId: "wallpaper"
    preferredHeight: 550
    preferredWidth: 800
    onPopupOpened: {
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

        command: ["sh", "-c", "find ~/Pictures/Wallpapers -maxdepth 1 -type f | grep -iE '\\.(jpg|jpeg|png|webp)$'"]
        onExited: function(exitCode) {
            wallModel.clear();
            let sortedLines = lines.sort(function(a, b) {
                return a.name.localeCompare(b.name);
            });
            for (let i = 0; i < sortedLines.length; i++) {
                wallModel.append(sortedLines[i]);
            }
            lines = [];
            filterWallpapers("");
        }

        stdout: SplitParser {
            onRead: function(data) {
                let linesArr = data.split('\n');
                for (let i = 0; i < linesArr.length; i++) {
                    let rawPath = linesArr[i].trim();
                    if (rawPath !== "") {
                        let parts = rawPath.split('/');
                        let fileName = parts[parts.length - 1];
                        loadWallpapersProc.lines.push({
                            "filePath": "file://" + rawPath,
                            "rawPath": rawPath,
                            "name": fileName
                        });
                    }
                }
            }
        }

    }

    Process {
        id: wallpaperProc
    }

    ColumnLayout {
        spacing: Theme.spacingLg

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Theme.colBgLighter
            radius: 20

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingLg
                anchors.rightMargin: Theme.spacingLg
                spacing: Theme.spacingLg

                ThemedText {
                    text: "󰸉"
                    color: Theme.colFg
                    font.pixelSize: Theme.fontSizeLg
                }

                TextField {
                    id: searchField

                    Layout.fillWidth: true
                    placeholderText: "Search wallpapers..."
                    placeholderTextColor: Theme.colMuted
                    color: Theme.colFg
                    font.pixelSize: Theme.fontSizeMd
                    font.family: Theme.fontFamily
                    background: null
                    onTextChanged: root.filterWallpapers(text)
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Right) {
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
                                setWallpaper(wall.rawPath);
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
                spacing: Theme.spacingLg

                ThemedText {
                    text: "󰸉"
                    color: Theme.colBgLighter
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                ThemedText {
                    text: "No wallpapers found in ~/Pictures/Wallpapers"
                    color: Theme.colMuted
                    font.pixelSize: Theme.fontSizeMd
                    Layout.alignment: Qt.AlignHCenter
                }

            }

            ColumnLayout {
                anchors.centerIn: parent
                visible: filteredModel.count === 0 && searchField.text !== ""
                spacing: Theme.spacingLg

                ThemedText {
                    text: "󰩉"
                    color: Theme.colBgLighter
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                ThemedText {
                    text: "No matches found"
                    color: Theme.colMuted
                    font.pixelSize: Theme.fontSizeMd
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
                        duration: Theme.animSlow
                        easing.type: Easing.OutQuint
                    }

                }

                highlight: Item {
                    width: wallView.cellWidth
                    height: wallView.cellHeight
                    z: 6

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSm
                        radius: Theme.radiusSm
                        color: "transparent"
                        border.color: Theme.colPurple
                        border.width: 2
                        scale: 1.05

                        Behavior on scale {
                            NumberAnimation {
                                duration: Theme.animSlow
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
                        duration: Theme.animSlow
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
                        anchors.margins: Theme.spacingSm
                        radius: Theme.radiusSm
                        color: Theme.colBgSecondary
                        scale: isCurrent || hoverHandler.hovered ? 1.05 : 1

                        Rectangle {
                            id: maskRect

                            anchors.fill: parent
                            anchors.margins: isCurrent ? 2 : 1
                            radius: Theme.radiusSm
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

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 60

                                gradient: Gradient {
                                    GradientStop {
                                        position: 0
                                        color: "transparent"
                                    }

                                    GradientStop {
                                        position: 1
                                        color: "#cc000000"
                                    }

                                }

                            }

                            ThemedText {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: Theme.spacingLg
                                anchors.rightMargin: Theme.spacingLg
                                anchors.bottomMargin: 14
                                text: model.name
                                color: isCurrent ? Theme.colPurple : "#ffffff"
                                font.pixelSize: Theme.fontSizeMd
                                font.bold: isCurrent
                                verticalAlignment: Text.AlignBottom
                                elide: Text.ElideMiddle

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.animNormal
                                    }

                                }

                            }

                            layer.effect: OpacityMask {
                                maskSource: maskRect
                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: Theme.animSlow
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
                            setWallpaper(model.rawPath);
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
