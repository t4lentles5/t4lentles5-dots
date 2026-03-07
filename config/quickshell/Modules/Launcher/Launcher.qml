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

    function filterApps(query) {
        filteredModel.clear();
        query = query.toLowerCase();
        for (let i = 0; i < appModel.count; i++) {
            let app = appModel.get(i);
            if (app.name.toLowerCase().includes(query))
                filteredModel.append(app);

        }
        if (filteredModel.count > 0)
            appsView.currentIndex = 0;
        else
            appsView.currentIndex = -1;
    }

    function launchApp(exec, terminal) {
        if (!exec)
            return ;

        let command = exec.split(' ').filter(function(arg) {
            return !arg.startsWith('%');
        });
        command = command.map(function(arg) {
            return arg.replace(/^"|"$/g, '');
        });
        if (terminal)
            command = ["kitty", "-e"].concat(command);

        appLauncher.running = false;
        appLauncher.command = command;
        appLauncher.startDetached();
        root.isOpen = false;
    }

    popupId: "launcher"
    preferredHeight: 400
    preferredWidth: 600
    onPopupOpened: {
        focusTimer.start();
        searchField.text = "";
        loadAppsProc.running = true;
    }

    Timer {
        id: focusTimer

        interval: 50
        repeat: false
        onTriggered: searchField.forceActiveFocus()
    }

    ListModel {
        id: appModel
    }

    ListModel {
        id: filteredModel
    }

    Process {
        id: loadAppsProc

        command: ["python3", Quickshell.shellDir + "/Scripts/get_apps.py"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    let apps = JSON.parse(appFetcherOutput.text);
                    appModel.clear();
                    apps.forEach(function(app) {
                        appModel.append(app);
                    });
                    filterApps("");
                } catch (e) {
                    console.error("Error parsing apps JSON: " + e);
                }
            }
        }

        stdout: StdioCollector {
            id: appFetcherOutput
        }

    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        color: Theme.colBgLighter
        radius: Theme.radiusLg + 4

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingLg
            anchors.rightMargin: Theme.spacingLg
            spacing: Theme.spacingMd

            ThemedText {
                text: ""
                color: Theme.colFg
                font.pixelSize: Theme.fontSizeLg
            }

            TextField {
                id: searchField

                Layout.fillWidth: true
                placeholderText: "Search applications..."
                placeholderTextColor: Theme.colMuted
                color: Theme.colFg
                font.pixelSize: Theme.fontSizeMd
                font.family: Theme.fontFamily
                background: null
                onTextChanged: root.filterApps(text)
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Down) {
                        if (appsView.count > 0) {
                            appsView.currentIndex = Math.min(appsView.currentIndex + 1, appsView.count - 1);
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Up) {
                        if (appsView.count > 0) {
                            appsView.currentIndex = Math.max(appsView.currentIndex - 1, 0);
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        let idx = appsView.currentIndex >= 0 ? appsView.currentIndex : 0;
                        if (filteredModel.count > idx) {
                            let app = filteredModel.get(idx);
                            launchApp(app.exec, app.terminal);
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
            spacing: Theme.spacingLg
            anchors.centerIn: parent
            visible: filteredModel.count === 0 && searchField.text !== ""

            ThemedText {
                text: "󰩉"
                color: Theme.colBgLighter
                font.pixelSize: 72
                Layout.alignment: Qt.AlignHCenter
            }

            ThemedText {
                text: "No applications found"
                color: Theme.colMuted
                font.pixelSize: Theme.fontSizeMd
                Layout.alignment: Qt.AlignHCenter
            }

        }

        ListView {
            id: appsView

            anchors.fill: parent
            clip: true
            model: filteredModel
            spacing: 2
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
                        let app = filteredModel.get(currentIndex);
                        launchApp(app.exec, app.terminal);
                        event.accepted = true;
                    }
                }
            }

            highlight: Item {
                width: appsView.width
                height: 44
                z: 1

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSm
                    color: Theme.colBgLighter

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

                readonly property bool isCurrent: appsView.currentIndex === index

                width: appsView.width
                height: 44
                z: 2

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSm
                    color: Theme.colBgLighter
                    opacity: hoverHandler.hovered && !isCurrent ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animNormal
                        }

                    }

                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: Theme.spacingLg

                    Image {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        source: model.icon ? "image://icon/" + model.icon + "?fallback=application-x-executable" : ""
                        fillMode: Image.PreserveAspectFit

                        ThemedText {
                            anchors.centerIn: parent
                            visible: parent.status !== Image.Ready
                            text: ""
                            color: isCurrent ? Theme.colPurple : Theme.colMuted
                            font.pixelSize: 18
                        }

                    }

                    ThemedText {
                        text: model.name
                        color: isCurrent ? Theme.colPurple : Theme.colFg
                        font.bold: isCurrent
                        font.pixelSize: 14
                        Layout.fillWidth: true
                        scale: isCurrent ? 1.02 : 1
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
                    onTapped: launchApp(model.exec, model.terminal)
                }

            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                active: true
            }

        }

    }

    Process {
        id: appLauncher
    }

}
