import QtQuick
import Quickshell.Hyprland
import qs.Core

BarButton {
    id: root

    property string displayedTitle: "Desktop"
    property string activeTitle: "Desktop"

    function updateTitle() {
        if (!Hyprland.focusedWorkspace) {
            activeTitle = "Desktop";
            return ;
        }
        let ws = Hyprland.focusedWorkspace;
        let windowsCount = 0;
        if (ws.lastIpcObject && ws.lastIpcObject.windows !== undefined)
            windowsCount = ws.lastIpcObject.windows;

        if (windowsCount === 0) {
            activeTitle = "Desktop";
            return ;
        }
        if (Hyprland.activeToplevel && Hyprland.activeToplevel.title)
            activeTitle = Hyprland.activeToplevel.title;
        else
            activeTitle = "Desktop";
    }

    onActiveTitleChanged: {
        transitionAnim.restart();
    }
    Component.onCompleted: {
        root.updateTitle();
        displayedTitle = activeTitle;
    }
    text: ""
    textColor: Theme.purple
    fontSize: Constants.sizeSm
    isButton: false
    bgColor: Theme.bgSecondary
    implicitWidth: contentRow.implicitWidth + 24

    Connections {
        function onFocusedWorkspaceChanged() {
            Hyprland.refreshWorkspaces();
            root.updateTitle();
        }

        function onActiveToplevelChanged() {
            root.updateTitle();
        }

        function onRawEvent(event) {
            if (event.name === "openwindow" || event.name === "closewindow" || event.name === "movewindow" || event.name === "workspace") {
                Hyprland.refreshWorkspaces();
                root.updateTitle();
            }
        }

        target: Hyprland
    }

    Connections {
        function onLastIpcObjectChanged() {
            root.updateTitle();
        }

        target: Hyprland.focusedWorkspace
        ignoreUnknownSignals: true
    }

    Connections {
        function onTitleChanged() {
            root.updateTitle();
        }

        target: Hyprland.activeToplevel
        ignoreUnknownSignals: true
    }

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: Constants.sizeSm
        height: parent.height

        ThemedText {
            id: iconText

            text: ""
            color: Theme.purple
            font.bold: true
            font.pixelSize: Constants.sizeSm
            anchors.verticalCenter: parent.verticalCenter
            transform: [
                Scale {
                    id: iconScale

                    origin.x: iconText.width / 2
                    origin.y: iconText.height / 2
                    xScale: 1
                    yScale: 1
                },
                Rotation {
                    id: iconRotation

                    origin.x: iconText.width / 2
                    origin.y: iconText.height / 2
                    angle: 0
                }
            ]
        }

        Item {
            id: textContainer

            width: Math.min(titleText.implicitWidth, 200)
            height: parent.height
            clip: true
            anchors.verticalCenter: parent.verticalCenter

            ThemedText {
                id: titleText

                text: root.displayedTitle
                color: Theme.purple
                font.bold: true
                font.pixelSize: Constants.sizeSm
                anchors.verticalCenter: parent.verticalCenter
                x: 0
            }

            Behavior on width {
                NumberAnimation {
                    duration: Constants.animNormal
                    easing.type: Easing.OutQuint
                }

            }

        }

    }

    SequentialAnimation {
        id: scrollAnim

        running: titleText.implicitWidth > 200 && textContainer.opacity > 0.99
        loops: Animation.Infinite

        PauseAnimation {
            duration: 2000
        }

        NumberAnimation {
            target: titleText
            property: "x"
            from: 0
            to: 200 - titleText.implicitWidth
            duration: Math.max(1000, (titleText.implicitWidth - 200) * 30)
            easing.type: Easing.Linear
        }

        PauseAnimation {
            duration: 2000
        }

        NumberAnimation {
            target: titleText
            property: "x"
            to: 0
            duration: 800
            easing.type: Easing.InOutQuad
        }

    }

    SequentialAnimation {
        id: transitionAnim

        ParallelAnimation {
            NumberAnimation {
                target: textContainer
                property: "opacity"
                to: 0
                duration: Constants.animUltraFast
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: textContainer
                property: "anchors.verticalCenterOffset"
                to: 8
                duration: Constants.animUltraFast
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: iconScale
                properties: "xScale,yScale"
                to: 0.7
                duration: Constants.animUltraFast
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: iconRotation
                property: "angle"
                from: 0
                to: 180
                duration: Constants.animUltraFast
                easing.type: Easing.OutCubic
            }

        }

        ScriptAction {
            script: {
                root.displayedTitle = root.activeTitle;
                titleText.x = 0;
            }
        }

        PropertyAction {
            target: textContainer
            property: "anchors.verticalCenterOffset"
            value: -8
        }

        ParallelAnimation {
            NumberAnimation {
                target: textContainer
                property: "opacity"
                to: 1
                duration: Constants.animFast
                easing.type: Easing.OutBack
            }

            NumberAnimation {
                target: textContainer
                property: "anchors.verticalCenterOffset"
                to: 0
                duration: Constants.animFast
                easing.type: Easing.OutBack
            }

            NumberAnimation {
                target: iconScale
                properties: "xScale,yScale"
                to: 1
                duration: Constants.animFast
                easing.type: Easing.OutBack
            }

            NumberAnimation {
                target: iconRotation
                property: "angle"
                from: 180
                to: 360
                duration: Constants.animFast
                easing.type: Easing.OutBack
            }

        }

    }

}
