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
    property var allResults: []
    property string installingPkg: ""
    property bool isSearching: false
    property string actionMode: "install"
    property var selectedPackages: ([])
    property var selectedPackageObjects: ({
    })

    function doSearch(query) {
        if (root.actionMode === "install") {
            if (query.length < 2) {
                root.allResults = [];
                root.updateModel();
                root.isSearching = false;
                return ;
            }
            root.isSearching = true;
            searchProc.running = false;
            searchProc.command = ["python3", Quickshell.shellDir + "/Scripts/search_packages.py", query];
            searchProc.running = true;
        } else {
            root.isSearching = true;
            searchProc.running = false;
            searchProc.command = ["python3", Quickshell.shellDir + "/Scripts/search_packages.py", "--list-installed"];
            searchProc.running = true;
        }
    }

    function updateModel() {
        let currentPkgName = "";
        if (pkgView && pkgView.currentIndex >= 0 && resultsModel.count > pkgView.currentIndex)
            currentPkgName = resultsModel.get(pkgView.currentIndex).name;

        resultsModel.clear();
        let data = root.allResults;
        if (root.actionMode === "remove" && root.searchText.length > 0) {
            let q = root.searchText.toLowerCase();
            data = data.filter(function(p) {
                return p.name.toLowerCase().indexOf(q) !== -1 || p.description.toLowerCase().indexOf(q) !== -1;
            });
        }
        let selectedNames = root.selectedPackages;
        for (let i = 0; i < selectedNames.length; i++) {
            let name = selectedNames[i];
            let pkgObj = root.selectedPackageObjects[name];
            if (pkgObj) {
                pkgObj.selected = true;
                resultsModel.append(pkgObj);
            }
        }
        for (let i = 0; i < data.length; i++) {
            let pkg = data[i];
            if (selectedNames.indexOf(pkg.name) === -1) {
                pkg.selected = false;
                resultsModel.append(pkg);
            }
        }
        if (pkgView) {
            let found = false;
            if (currentPkgName !== "") {
                for (let i = 0; i < resultsModel.count; i++) {
                    if (resultsModel.get(i).name === currentPkgName) {
                        pkgView.currentIndex = i;
                        found = true;
                        break;
                    }
                }
            }
            if (!found)
                pkgView.currentIndex = resultsModel.count > 0 ? 0 : -1;

        }
    }

    function toggleSelect(pkgName) {
        let arr = root.selectedPackages.slice();
        let idx = arr.indexOf(pkgName);
        let objs = {
        };
        for (let i = 0; i < arr.length; i++) {
            if (arr[i] !== pkgName)
                objs[arr[i]] = root.selectedPackageObjects[arr[i]];

        }
        if (idx !== -1) {
            arr.splice(idx, 1);
        } else {
            arr.push(pkgName);
            let found = false;
            for (let i = 0; i < resultsModel.count; i++) {
                if (resultsModel.get(i).name === pkgName) {
                    objs[pkgName] = {
                        "name": resultsModel.get(i).name,
                        "version": resultsModel.get(i).version,
                        "repo": resultsModel.get(i).repo,
                        "source": resultsModel.get(i).source,
                        "description": resultsModel.get(i).description,
                        "installed": resultsModel.get(i).installed
                    };
                    found = true;
                    break;
                }
            }
            if (!found) {
                for (let i = 0; i < root.allResults.length; i++) {
                    if (root.allResults[i].name === pkgName) {
                        objs[pkgName] = {
                            "name": root.allResults[i].name,
                            "version": root.allResults[i].version,
                            "repo": root.allResults[i].repo,
                            "source": root.allResults[i].source,
                            "description": root.allResults[i].description,
                            "installed": root.allResults[i].installed
                        };
                        found = true;
                        break;
                    }
                }
            }
        }
        root.selectedPackages = arr;
        root.selectedPackageObjects = objs;
        root.updateModel();
    }

    function executeBatch() {
        if (root.selectedPackages.length === 0)
            return ;

        let names = root.selectedPackages.join(" ");
        if (root.actionMode === "remove") {
            removeProc.running = false;
            removeProc.command = ["kitty", "--class", "kitty-floating", "--hold", "-e", "yay", "-Rns"].concat(root.selectedPackages);
            removeProc.startDetached();
        } else {
            installProc.running = false;
            installProc.command = ["kitty", "--class", "kitty-floating", "--hold", "-e", "yay", "-S"].concat(root.selectedPackages);
            installProc.startDetached();
        }
        root.selectedPackages = [];
        focusKittyTimer.start();
        root.isOpen = false;
    }

    function installPackage(name) {
        root.installingPkg = name;
        installProc.running = false;
        installProc.command = ["sh", "-c", "kitty --class kitty-floating --hold -e yay -S " + name + " & sleep 0.2; hyprctl dispatch focuswindow class:kitty-floating"];
        installProc.startDetached();
        root.isOpen = false;
    }

    function removePackage(name) {
        root.installingPkg = name;
        removeProc.running = false;
        removeProc.command = ["sh", "-c", "kitty --class kitty-floating --hold -e yay -Rns " + name + " & sleep 0.2; hyprctl dispatch focuswindow class:kitty-floating"];
        removeProc.startDetached();
        root.isOpen = false;
    }

    function handleKeyPress(event, fromSearch) {
        if (event.key === Qt.Key_Down) {
            if (pkgView.count > 0 && pkgView.currentIndex < pkgView.count - 1) {
                pkgView.currentIndex++;
                event.accepted = true;
            }
        } else if (event.key === Qt.Key_Up) {
            if (pkgView.currentIndex <= -1 && !fromSearch) {
                searchField.forceActiveFocus();
                pkgView.currentIndex = -1;
                event.accepted = true;
            } else if (pkgView.currentIndex > 0) {
                pkgView.currentIndex--;
                event.accepted = true;
            }
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            let idx = pkgView.currentIndex >= 0 ? pkgView.currentIndex : 0;
            if (root.selectedPackages.length === 0 && resultsModel.count > idx) {
                let pkg = resultsModel.get(idx);
                root.selectedPackages = [pkg.name];
            }
            root.executeBatch();
            event.accepted = true;
        } else if (event.key === Qt.Key_Tab) {
            if (event.modifiers & Qt.ControlModifier) {
                root.actionMode = root.actionMode === "install" ? "remove" : "install";
                root.selectedPackages = [];
                root.selectedPackageObjects = {
                };
                root.allResults = [];
                resultsModel.clear();
                root.doSearch(root.searchText);
            } else {
                let idx = pkgView.currentIndex >= 0 ? pkgView.currentIndex : 0;
                if (resultsModel.count > idx) {
                    let pkg = resultsModel.get(idx);
                    root.toggleSelect(pkg.name);
                }
            }
            event.accepted = true;
        }
    }

    popupId: "packagemanager"
    preferredHeight: 520
    preferredWidth: 650
    onPopupOpened: {
        focusTimer.start();
        searchField.text = "";
        root.allResults = [];
        root.installingPkg = "";
        root.actionMode = "install";
        root.selectedPackages = [];
        root.selectedPackageObjects = {
        };
        root.doSearch("");
    }

    ListModel {
        id: resultsModel
    }

    Timer {
        id: focusTimer

        interval: 50
        repeat: false
        onTriggered: searchField.forceActiveFocus()
    }

    Timer {
        id: focusKittyTimer

        interval: 300
        repeat: false
        onTriggered: {
            focusKittyProc.running = false;
            focusKittyProc.command = ["hyprctl", "dispatch", "focuswindow", "class:kitty-floating"];
            focusKittyProc.startDetached();
        }
    }

    Timer {
        id: debounceTimer

        interval: 300
        repeat: false
        onTriggered: {
            if (root.actionMode === "remove")
                root.updateModel();
            else
                root.doSearch(root.searchText);
        }
    }

    Process {
        id: searchProc

        command: ["echo", ""]
        onExited: function(exitCode) {
            root.isSearching = false;
            if (exitCode === 0) {
                try {
                    root.allResults = JSON.parse(searchOutput.text);
                    root.updateModel();
                } catch (e) {
                    console.error("PackageManager: Error parsing search results: " + e);
                    root.allResults = [];
                    resultsModel.clear();
                }
            }
        }

        stdout: StdioCollector {
            id: searchOutput
        }

    }

    Process {
        id: installProc
    }

    Process {
        id: removeProc
    }

    Process {
        id: copyNameProc
    }

    Process {
        id: focusKittyProc
    }

    ColumnLayout {
        spacing: Constants.sizeSm

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Theme.bgSecondary
            radius: Constants.sizeXl
            border.color: root.actionMode === "install" ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.2) : Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.2)
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
                    placeholderText: root.actionMode === "remove" ? "Search to remove" : "Search to install"
                    placeholderTextColor: Theme.muted
                    color: Theme.fg
                    font.pixelSize: Constants.sizeMd
                    font.family: Constants.fontFamily
                    background: null
                    onTextChanged: {
                        root.searchText = text;
                        debounceTimer.restart();
                    }
                    Keys.onPressed: function(event) {
                        root.handleKeyPress(event, true);
                    }
                }

                ThemedText {
                    visible: root.selectedPackages.length > 0
                    text: root.selectedPackages.length + (root.selectedPackages.length === 1 ? " selected" : " selected")
                    font.pixelSize: Constants.sizeSm
                    font.bold: true
                    color: root.actionMode === "install" ? Theme.green : Theme.red
                    opacity: 0.8

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.OutQuint
                        }

                    }

                }

                Rectangle {
                    visible: root.selectedPackages.length > 0
                    width: execLabel.implicitWidth + 24
                    height: 24
                    radius: 12
                    color: root.actionMode === "install" ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, execHover.hovered ? 0.3 : 0.15) : Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, execHover.hovered ? 0.3 : 0.15)
                    border.color: root.actionMode === "install" ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.4) : Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.4)
                    border.width: 1

                    ThemedText {
                        id: execLabel

                        anchors.centerIn: parent
                        text: root.actionMode === "install" ? "Install" : "Remove"
                        font.pixelSize: 10
                        font.bold: true
                        color: root.actionMode === "install" ? Theme.green : Theme.red
                    }

                    HoverHandler {
                        id: execHover

                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: root.executeBatch()
                    }

                }

            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 250
                    easing.type: Easing.OutQuint
                }

            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                visible: root.actionMode === "install" && root.searchText.length < 2 && resultsModel.count === 0 && !root.isSearching
                opacity: visible ? 1 : 0

                ThemedText {
                    text: "󰏖"
                    color: Theme.muted
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                ThemedText {
                    text: "Search packages"
                    color: Theme.muted
                    font.pixelSize: Constants.sizeMd
                    Layout.alignment: Qt.AlignHCenter
                }

                ThemedText {
                    text: "Type at least 2 characters to search"
                    color: Theme.muted
                    font.pixelSize: Constants.sizeSm
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0.6
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Constants.animNormal
                    }

                }

            }

            ColumnLayout {
                anchors.centerIn: parent
                visible: resultsModel.count === 0 && !root.isSearching && !(root.actionMode === "install" && root.searchText.length < 2)
                opacity: visible ? 1 : 0

                ThemedText {
                    text: "󰩉"
                    color: Theme.muted
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                ThemedText {
                    text: "No packages found"
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
                visible: root.isSearching
                opacity: visible ? 1 : 0

                ThemedText {
                    text: "󰑐"
                    color: Theme.purple
                    font.pixelSize: 36
                    Layout.alignment: Qt.AlignHCenter

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: root.isSearching
                    }

                }

                ThemedText {
                    text: "Searching..."
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
                id: pkgView

                anchors.fill: parent
                clip: true
                model: resultsModel
                spacing: Constants.sizeXs
                currentIndex: -1
                highlightResizeDuration: 0
                highlightMoveDuration: 250
                highlightFollowsCurrentItem: true
                visible: resultsModel.count > 0 && !root.isSearching
                Keys.onPressed: function(event) {
                    root.handleKeyPress(event, false);
                }

                highlight: Item {
                    width: pkgView.width
                    height: pkgView.currentItem ? pkgView.currentItem.height : 52
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
                            color: root.actionMode === "install" ? Theme.green : Theme.red

                            Behavior on color {
                                ColorAnimation {
                                    duration: 250
                                    easing.type: Easing.OutQuint
                                }

                            }

                        }

                    }

                }

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Constants.animNormal
                        easing.type: Easing.OutQuint
                    }

                }

                remove: Transition {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: Constants.animFast
                    }

                }

                removeDisplaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: Constants.animFast
                        easing.type: Easing.OutExpo
                    }

                }

                addDisplaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: Constants.animNormal
                        easing.type: Easing.OutExpo
                    }

                }

                displaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: Constants.animNormal
                        easing.type: Easing.OutExpo
                    }

                }

                populate: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Constants.animNormal
                        easing.type: Easing.OutQuint
                    }

                }

                delegate: Item {
                    id: delegateRoot

                    readonly property bool isCurrent: pkgView.currentIndex === index
                    readonly property bool isSelected: selected

                    width: pkgView.width
                    height: delegateContent.implicitHeight + Constants.sizeLg
                    z: 2

                    Rectangle {
                        anchors.fill: parent
                        radius: Constants.sizeXs
                        color: root.actionMode === "install" ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.06) : Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.06)
                        opacity: isSelected ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Constants.animFast
                            }

                        }

                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Constants.sizeXs
                        color: Theme.bgSecondary
                        opacity: delegateHover.hovered && !isCurrent ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Constants.animNormal
                            }

                        }

                    }

                    RowLayout {
                        id: delegateContent

                        anchors.fill: parent
                        anchors.leftMargin: Constants.sizeLg
                        anchors.rightMargin: Constants.sizeLg
                        spacing: Constants.sizeSm

                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            Layout.alignment: Qt.AlignVCenter
                            radius: 4
                            color: isSelected ? (root.actionMode === "install" ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.15) : Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.15)) : "transparent"
                            border.color: isSelected ? (root.actionMode === "install" ? Theme.green : Theme.red) : Theme.muted
                            border.width: 1
                            opacity: isSelected ? 1 : (isCurrent ? 0.6 : 0.3)

                            ThemedText {
                                anchors.centerIn: parent
                                text: "󰄬"
                                font.pixelSize: 14
                                font.bold: true
                                color: root.actionMode === "install" ? Theme.green : Theme.red
                                visible: isSelected
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Constants.animFast
                                }

                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: Constants.animFast
                                }

                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Constants.animFast
                                }

                            }

                        }

                        ColumnLayout {
                            id: detailColumn

                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                spacing: Constants.sizeXs

                                ThemedText {
                                    text: name
                                    color: isSelected ? (root.actionMode === "install" ? Theme.green : Theme.red) : (isCurrent ? Theme.purple : Theme.fg)
                                    font.pixelSize: Constants.sizeMd
                                    font.bold: true

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 250
                                            easing.type: Easing.OutQuint
                                        }

                                    }

                                }

                                ThemedText {
                                    text: version
                                    color: Theme.muted
                                    font.pixelSize: 10
                                    opacity: 0.6
                                    Layout.alignment: Qt.AlignBottom
                                    Layout.bottomMargin: 2
                                }

                            }

                            ThemedText {
                                text: description
                                color: isCurrent ? Theme.fg : Theme.muted
                                font.pixelSize: Constants.sizeSm
                                Layout.fillWidth: true
                                maximumLineCount: isCurrent ? 3 : 1
                                elide: Text.ElideRight
                                wrapMode: isCurrent ? Text.WordWrap : Text.NoWrap
                                opacity: isCurrent ? 0.9 : 0.7

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 250
                                        easing.type: Easing.OutQuint
                                    }

                                }

                            }

                        }

                        ColumnLayout {
                            spacing: 8
                            Layout.alignment: Qt.AlignRight | Qt.AlignTop
                            Layout.topMargin: 4

                            RowLayout {
                                Layout.alignment: Qt.AlignRight
                                spacing: 4

                                Rectangle {
                                    visible: installed
                                    width: instText.implicitWidth + 12
                                    height: 18
                                    radius: 4
                                    color: Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.1)
                                    border.color: Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.2)
                                    border.width: 1

                                    ThemedText {
                                        id: instText

                                        anchors.centerIn: parent
                                        text: "INSTALLED"
                                        font.pixelSize: 8
                                        font.bold: true
                                        color: Theme.green
                                    }

                                }

                                Rectangle {
                                    width: repoText.implicitWidth + 12
                                    height: 18
                                    radius: 4
                                    color: source === "AUR" ? Qt.rgba(Theme.cyan.r, Theme.cyan.g, Theme.cyan.b, 0.1) : Qt.rgba(Theme.blue.r, Theme.blue.g, Theme.blue.b, 0.1)
                                    border.color: source === "AUR" ? Qt.rgba(Theme.cyan.r, Theme.cyan.g, Theme.cyan.b, 0.2) : Qt.rgba(Theme.blue.r, Theme.blue.g, Theme.blue.b, 0.2)
                                    border.width: 1

                                    ThemedText {
                                        id: repoText

                                        anchors.centerIn: parent
                                        text: (source === "AUR" ? "AUR" : repo).toUpperCase()
                                        font.pixelSize: 8
                                        font.bold: true
                                        color: source === "AUR" ? Theme.cyan : Theme.blue
                                        textFormat: Text.PlainText
                                    }

                                }

                            }

                        }

                    }

                    HoverHandler {
                        id: delegateHover
                    }

                    TapHandler {
                        onTapped: {
                            pkgView.currentIndex = index;
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

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 18
            spacing: Constants.sizeXs

            ThemedText {
                text: {
                    if (root.isSearching)
                        return "Searching...";

                    if (resultsModel.count > 0)
                        return resultsModel.count + (resultsModel.count === 1 ? " package found" : " packages found");

                    return "";
                }
                font.pixelSize: Constants.sizeSm
                color: Theme.muted
            }

            Item {
                Layout.fillWidth: true
            }

            ThemedText {
                text: "󰌒  Select  •  Ctrl+󰌒  Switch Mode  •  󰌑  Execute"
                font.pixelSize: Constants.sizeSm
                color: Theme.muted
            }

        }

    }

}
