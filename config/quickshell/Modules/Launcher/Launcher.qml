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

        let command = exec.split(' ').filter((arg) => {
            return !arg.startsWith('%');
        });
        command = command.map((arg) => {
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
    onIsOpenChanged: {
        if (isOpen) {
            focusTimer.start();
            searchField.text = "";
            loadAppsProc.running = true;
        }
    }
    preferredHeight: 450
    preferredWidth: 700

    Timer {
        id: focusTimer

        interval: 50
        repeat: false
        onTriggered: searchField.forceActiveFocus()
    }

    SocketServer {
        path: "/tmp/quickshell_launcher"
        active: true
        onActiveStatusChanged: {
            if (!active) {
                active = true;
            }
        }

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

    ListModel {
        id: appModel
    }

    ListModel {
        id: filteredModel
    }

    Process {
        id: loadAppsProc

        command: ["python3", Quickshell.shellDir + "/Scripts/get_apps.py"]
        onExited: (exitCode) => {
            if (exitCode === 0) {
                try {
                    let apps = JSON.parse(appFetcherOutput.text);
                    appModel.clear();
                    apps.forEach((app) => {
                        return appModel.append(app);
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
                text: "󰍉"
                color: Theme.colMuted
                font.pixelSize: 18
                font.family: Theme.fontFamily
            }

            TextField {
                id: searchField

                Layout.fillWidth: true
                placeholderText: "Search applications..."
                placeholderTextColor: Theme.colMuted
                color: Theme.colFg
                font.family: Theme.fontFamily
                font.pixelSize: 16
                background: null
                onTextChanged: root.filterApps(text)
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Down) {
                        if (appsView.count > 0) {
                            appsView.currentIndex = 0;
                            appsView.forceActiveFocus();
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (filteredModel.count > 0) {
                            let app = filteredModel.get(appsView.currentIndex >= 0 ? appsView.currentIndex : 0);
                            launchApp(app.exec, app.terminal);
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

    ListView {
        id: appsView

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
                    let app = filteredModel.get(currentIndex);
                    launchApp(app.exec, app.terminal);
                    event.accepted = true;
                }
            }
        }

        highlight: Rectangle {
            width: appsView.width
            height: 50
            radius: 10
            color: Theme.colBgLighter
            border.color: Theme.colPurple
            border.width: 1
            z: 1

            Behavior on y {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

        add: Transition {
            NumberAnimation {
                properties: "scale"
                from: 0.95
                to: 1
                duration: 200
                easing.type: Easing.OutQuad
            }

        }

        populate: Transition {
            NumberAnimation {
                properties: "scale"
                from: 0.95
                to: 1
                duration: 200
                easing.type: Easing.OutQuad
            }

        }

        delegate: Item {
            id: delegateRoot

            readonly property bool isCurrent: appsView.currentIndex === index

            width: appsView.width
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
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 15

                Item {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32

                    Image {
                        anchors.fill: parent
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
                                duration: 150
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
                    scale: isCurrent ? 1.05 : 1
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
                onTapped: launchApp(model.exec, model.terminal)
            }

        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            active: true
        }

    }

    Process {
        id: appLauncher
    }

}
