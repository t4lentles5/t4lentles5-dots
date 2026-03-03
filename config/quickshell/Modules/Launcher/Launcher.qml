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
                placeholderText: "Search applications..."
                placeholderTextColor: Theme.colMuted
                color: Theme.colFg
                font.family: Theme.fontFamily
                font.pixelSize: 14
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

        Behavior on border.color {
            ColorAnimation {
                duration: 250
            }

        }

    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

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
                text: "No applications found"
                color: Theme.colMuted
                font.pixelSize: 16
                font.family: Theme.fontFamily
                Layout.alignment: Qt.AlignHCenter
            }

        }

        ListView {
            id: appsView

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

                readonly property bool isCurrent: appsView.currentIndex === index

                width: appsView.width
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
                        color: "transparent"

                        Image {
                            anchors.centerIn: parent
                            width: 28
                            height: 28
                            source: model.icon ? "image://icon/" + model.icon : ""
                            fillMode: Image.PreserveAspectFit
                            scale: isCurrent ? 1.15 : 1

                            Text {
                                anchors.centerIn: parent
                                visible: parent.status !== Image.Ready
                                text: ""
                                color: isCurrent ? Theme.colPurple : Theme.colMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 20
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 250
                                    easing.type: Easing.OutBack
                                }

                            }

                        }

                    }

                    Text {
                        text: model.name
                        color: isCurrent ? Theme.colPurple : Theme.colFg
                        font.family: Theme.fontFamily
                        font.bold: isCurrent
                        font.pixelSize: 14
                        Layout.fillWidth: true
                        scale: isCurrent ? 1.02 : 1
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
