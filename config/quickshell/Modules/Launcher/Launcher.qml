import QtQml
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
    property var allApps: []
    property var filteredApps: []

    function filterApps(query) {
        query = query.toLowerCase();
        let newFiltered = [];
        for (let i = 0; i < root.allApps.length; i++) {
            let app = root.allApps[i];
            if (app.name.toLowerCase().includes(query))
                newFiltered.push(app);

        }
        root.filteredApps = newFiltered;
        if (appsView) {
            appsView.expandedIndex = -1;
            if (root.filteredApps.length > 0)
                appsView.currentIndex = 0;
            else
                appsView.currentIndex = -1;
        }
    }

    function handleKeyPress(event, fromSearch) {
        let currentDelegate = appsView.currentItem;
        if (event.key === Qt.Key_Down) {
            if (currentDelegate && currentDelegate.isExpanded && currentDelegate.currentActionIndex < currentDelegate.actionCount - 1) {
                currentDelegate.currentActionIndex++;
                event.accepted = true;
            } else if (appsView.count > 0 && appsView.currentIndex < appsView.count - 1) {
                appsView.expandedIndex = -1;
                appsView.currentIndex++;
                event.accepted = true;
            }
        } else if (event.key === Qt.Key_Up) {
            if (currentDelegate && currentDelegate.isExpanded && currentDelegate.currentActionIndex >= 0) {
                currentDelegate.currentActionIndex--;
                event.accepted = true;
            } else {
                appsView.expandedIndex = -1;
                if (appsView.currentIndex <= 0 && !fromSearch) {
                    searchField.forceActiveFocus();
                    appsView.currentIndex = -1;
                    event.accepted = true;
                } else if (appsView.currentIndex > 0) {
                    appsView.currentIndex--;
                    event.accepted = true;
                }
            }
        } else if (event.key === Qt.Key_Right) {
            if (currentDelegate && currentDelegate.hasActions && !currentDelegate.isExpanded) {
                appsView.expandedIndex = appsView.currentIndex;
                currentDelegate.currentActionIndex = 0;
                event.accepted = true;
            }
        } else if (event.key === Qt.Key_Left) {
            if (currentDelegate && currentDelegate.isExpanded) {
                appsView.expandedIndex = -1;
                event.accepted = true;
            }
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            let idx = appsView.currentIndex >= 0 ? appsView.currentIndex : 0;
            if (root.filteredApps.length > idx) {
                if (currentDelegate && currentDelegate.isExpanded && currentDelegate.currentActionIndex >= 0) {
                    let action = root.filteredApps[idx].actions[currentDelegate.currentActionIndex];
                    launchApp(action.exec, false);
                } else {
                    let app = root.filteredApps[idx];
                    launchApp(app.exec, app.terminal);
                }
                event.accepted = true;
            }
        }
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
        if (appsView)
            appsView.expandedIndex = -1;

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

    Process {
        id: loadAppsProc

        command: ["python3", Quickshell.shellDir + "/Scripts/get_apps.py"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    root.allApps = JSON.parse(appFetcherOutput.text);
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
        color: Colors.bgSecondary
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
                placeholderText: "Search applications..."
                placeholderTextColor: Colors.muted
                color: Colors.fg
                font.pixelSize: Constants.sizeMd
                font.family: Constants.fontFamily
                background: null
                onTextChanged: root.filterApps(text)
                Keys.onPressed: function(event) {
                    root.handleKeyPress(event, true);
                }
            }

        }

    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            anchors.centerIn: parent
            visible: root.filteredApps.length === 0 && searchField.text !== ""

            ThemedText {
                text: "󰩉"
                color: Colors.muted
                font.pixelSize: 72
                Layout.alignment: Qt.AlignHCenter
            }

            ThemedText {
                text: "No applications found"
                color: Colors.muted
                font.pixelSize: Constants.sizeMd
                Layout.alignment: Qt.AlignHCenter
            }

        }

        ListView {
            id: appsView

            property int expandedIndex: -1

            anchors.fill: parent
            clip: true
            model: root.filteredApps
            spacing: Constants.sizeXs
            currentIndex: -1
            highlightResizeDuration: 0
            highlightMoveDuration: 250
            highlightFollowsCurrentItem: true
            visible: root.filteredApps.length > 0
            Keys.onPressed: function(event) {
                root.handleKeyPress(event, false);
            }

            highlight: Item {
                width: appsView.width
                height: 44
                z: 1

                Rectangle {
                    anchors.fill: parent
                    radius: Constants.sizeXs
                    color: Colors.bgSecondary

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 2
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        width: 3
                        radius: 2
                        color: Colors.purple
                    }

                }

            }

            add: Transition {
                NumberAnimation {
                    properties: "opacity"
                    from: 0
                    to: 1
                    duration: Constants.animNormal
                    easing.type: Easing.OutQuint
                }

            }

            populate: Transition {
                NumberAnimation {
                    properties: "opacity"
                    from: 0
                    to: 1
                    duration: Constants.animNormal
                    easing.type: Easing.OutQuint
                }

            }

            delegate: Item {
                id: delegateRoot

                readonly property bool isCurrent: appsView.currentIndex === index
                readonly property bool hasActions: modelData.actions && modelData.actions.length > 0
                readonly property int actionCount: modelData.actions ? modelData.actions.length : 0
                readonly property bool isExpanded: appsView.expandedIndex === index
                property int currentActionIndex: -1

                onIsExpandedChanged: {
                    if (!isExpanded)
                        currentActionIndex = -1;

                }
                width: appsView.width
                height: 44 + (isExpanded ? actionsColumn.implicitHeight : 0)
                z: 2
                clip: true

                Item {
                    id: mainContent

                    width: parent.width
                    height: 44

                    Rectangle {
                        anchors.fill: parent
                        radius: Constants.sizeXs
                        color: Colors.bgSecondary
                        opacity: hoverHandler.hovered && !isCurrent ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Constants.animNormal
                            }

                        }

                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Constants.sizeLg
                        anchors.rightMargin: Constants.sizeLg
                        spacing: Constants.sizeLg

                        Image {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            source: modelData.icon ? "image://icon/" + modelData.icon : ""
                            fillMode: Image.PreserveAspectFit

                            ThemedText {
                                anchors.centerIn: parent
                                visible: parent.status !== Image.Ready || !parent.source
                                text: ""
                                color: isCurrent ? Colors.purple : Colors.muted
                                font.pixelSize: Constants.sizeLg
                            }

                        }

                        ThemedText {
                            text: modelData.name
                            color: isCurrent ? Colors.purple : Colors.fg
                            font.bold: isCurrent
                            font.pixelSize: Constants.sizeMd
                            Layout.fillWidth: true
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
                            Layout.preferredWidth: Constants.sizeLg * 2
                            Layout.preferredHeight: Constants.sizeLg * 2
                            visible: delegateRoot.hasActions
                        }

                    }

                    HoverHandler {
                        id: hoverHandler
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton && delegateRoot.hasActions) {
                                if (appsView.expandedIndex === index) {
                                    appsView.expandedIndex = -1;
                                } else {
                                    appsView.expandedIndex = index;
                                    appsView.currentIndex = index;
                                    delegateRoot.currentActionIndex = -1;
                                }
                            } else {
                                launchApp(modelData.exec, modelData.terminal);
                            }
                        }
                    }

                    IconButton {
                        icon: "󰅂"
                        iconSize: Constants.sizeMd
                        visible: delegateRoot.hasActions
                        bgColor: "transparent"
                        iconColor: Colors.muted
                        hoverColor: Colors.purple
                        activeColor: Colors.purple
                        isActive: delegateRoot.isExpanded
                        hoverScale: 1.1
                        width: Constants.sizeLg * 2
                        height: Constants.sizeLg * 2
                        anchors.right: parent.right
                        anchors.rightMargin: Constants.sizeLg
                        anchors.verticalCenter: mainContent.verticalCenter
                        rotation: delegateRoot.isExpanded ? 90 : 0
                        onClicked: {
                            if (appsView.expandedIndex === index) {
                                appsView.expandedIndex = -1;
                            } else {
                                appsView.expandedIndex = index;
                                appsView.currentIndex = index;
                                delegateRoot.currentActionIndex = -1;
                            }
                        }

                        Behavior on rotation {
                            NumberAnimation {
                                duration: Constants.animNormal
                                easing.type: Easing.OutQuint
                            }

                        }

                    }

                }

                ColumnLayout {
                    id: actionsColumn

                    y: 44
                    width: parent.width
                    spacing: 0
                    opacity: delegateRoot.isExpanded ? 1 : 0
                    visible: opacity > 0

                    Repeater {
                        model: modelData.actions || []

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            color: ((delegateRoot.isExpanded && delegateRoot.currentActionIndex === index) || actionMouseArea.containsMouse) ? Colors.bgSecondary : "transparent"
                            radius: Constants.sizeXs

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Constants.sizeLg * 2 + 24
                                anchors.rightMargin: Constants.sizeLg

                                ThemedText {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: ((delegateRoot.isExpanded && delegateRoot.currentActionIndex === index) || actionMouseArea.containsMouse) ? Colors.purple : Colors.fg
                                    font.pixelSize: Constants.sizeMd
                                }

                            }

                            MouseArea {
                                id: actionMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: launchApp(modelData.exec, false)
                            }

                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Constants.animNormal
                        }

                    }

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

    Process {
        id: appLauncher
    }

}
