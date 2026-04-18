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
                placeholderText: "Search applications..."
                placeholderTextColor: Theme.muted
                color: Theme.fg
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
                color: Theme.muted
                font.pixelSize: 72
                Layout.alignment: Qt.AlignHCenter
            }

            ThemedText {
                text: "No applications found"
                color: Theme.muted
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
                    color: Theme.bgSecondary

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
                height: 44 + (isExpanded ? actionsColumn.implicitHeight + Constants.sizeXs : 0)
                z: 2
                clip: true

                Item {
                    id: mainContent

                    width: parent.width
                    height: 44

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
                                color: isCurrent ? Theme.purple : Theme.muted
                                font.pixelSize: Constants.sizeLg
                            }

                        }

                        ThemedText {
                            text: modelData.name
                            color: isCurrent ? Theme.purple : Theme.fg
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
                        icon: ""
                        iconSize: Constants.sizeMd
                        visible: delegateRoot.hasActions
                        iconColor: Theme.muted
                        hoverColor: Theme.fg
                        activeColor: Theme.fg
                        isActive: delegateRoot.isExpanded
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

                Item {
                    id: connectorLines

                    y: 44 + Constants.sizeXs / 2
                    width: parent.width
                    height: actionsColumn.implicitHeight
                    opacity: delegateRoot.isExpanded ? 1 : 0
                    visible: opacity > 0

                    Rectangle {
                        x: Constants.sizeLg + 11
                        y: -Constants.sizeXs / 2
                        width: 2
                        height: parent.height - 12
                        color: Theme.muted
                        opacity: 0.3
                        radius: 1
                    }

                    Repeater {
                        model: modelData.actions || []

                        Rectangle {
                            x: Constants.sizeLg + 11
                            y: index * (34 + actionsColumn.spacing) + 16
                            width: 16
                            height: 2
                            color: Theme.muted
                            opacity: 0.3
                            radius: 1
                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Constants.animNormal
                        }

                    }

                }

                ColumnLayout {
                    id: actionsColumn

                    y: 44 + Constants.sizeXs / 2
                    width: parent.width
                    spacing: 4
                    opacity: delegateRoot.isExpanded ? 1 : 0
                    visible: opacity > 0

                    Repeater {
                        model: modelData.actions || []

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            Layout.leftMargin: Constants.sizeLg + 32
                            Layout.rightMargin: Constants.sizeLg
                            color: ((delegateRoot.isExpanded && delegateRoot.currentActionIndex === index) || actionMouseArea.containsMouse) ? Theme.bgSecondary : Qt.rgba(Theme.bgSecondary.r, Theme.bgSecondary.g, Theme.bgSecondary.b, 0)
                            radius: Constants.sizeXs

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Constants.sizeMd
                                anchors.rightMargin: Constants.sizeLg
                                spacing: Constants.sizeXs

                                Item {
                                    Layout.preferredWidth: 8
                                    Layout.preferredHeight: 8
                                    Layout.alignment: Qt.AlignVCenter

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: ((delegateRoot.isExpanded && delegateRoot.currentActionIndex === index) || actionMouseArea.containsMouse) ? Theme.purple : Theme.muted
                                        opacity: ((delegateRoot.isExpanded && delegateRoot.currentActionIndex === index) || actionMouseArea.containsMouse) ? 1 : 0.5
                                        scale: ((delegateRoot.isExpanded && delegateRoot.currentActionIndex === index) || actionMouseArea.containsMouse) ? 1.5 : 1

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: Constants.animFast
                                            }

                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Constants.animFast
                                                easing.type: Easing.OutBack
                                            }

                                        }

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: Constants.animFast
                                            }

                                        }

                                    }

                                }

                                ThemedText {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: ((delegateRoot.isExpanded && delegateRoot.currentActionIndex === index) || actionMouseArea.containsMouse) ? Theme.purple : Theme.fg
                                    font.pixelSize: Constants.sizeMd
                                    Layout.alignment: Qt.AlignVCenter

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Constants.animFast
                                        }

                                    }

                                }

                            }

                            MouseArea {
                                id: actionMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: launchApp(modelData.exec, false)
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Constants.animFast
                                }

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
