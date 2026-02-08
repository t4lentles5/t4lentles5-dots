import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Core

PanelWindow {
    id: root

    property string popupId: ""
    property bool isOpen: false
    property int cornerRadius: 20
    property int contentPadding: 20
    default property alias content: innerLayout.data
    property int animationDuration: 250
    property color backgroundColor: Theme.colBg
    property int preferredWidth: 600
    property int preferredHeight: 500

    onIsOpenChanged: {
        if (popupId === "")
            return ;

        if (isOpen) {
            if (AppState.activePopup !== popupId)
                AppState.activePopup = popupId;

        } else {
            if (AppState.activePopup === popupId)
                AppState.activePopup = "";

        }
    }
    color: "transparent"
    focusable: true
    exclusionMode: ExclusionMode.Ignore
    visible: isOpen || container.opacity > 0

    Connections {
        function onActivePopupChanged() {
            if (popupId !== "" && AppState.activePopup !== popupId)
                root.isOpen = false;

        }

        target: AppState
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    TapHandler {
        onTapped: root.isOpen = false
    }

    Item {
        id: container

        width: root.preferredWidth
        height: root.preferredHeight
        anchors.centerIn: parent
        transformOrigin: Item.Center
        scale: 0.9
        opacity: 0
        focus: root.isOpen
        Keys.onEscapePressed: root.isOpen = false
        states: [
            State {
                name: "open"
                when: root.isOpen

                PropertyChanges {
                    target: container
                    scale: 1
                    opacity: 1
                }

            },
            State {
                name: "closed"
                when: !root.isOpen

                PropertyChanges {
                    target: container
                    scale: 0.9
                    opacity: 0
                }

            }
        ]
        transitions: [
            Transition {
                from: "closed"
                to: "open"

                NumberAnimation {
                    properties: "scale, opacity"
                    duration: 300
                    easing.type: Easing.OutBack
                    easing.overshoot: 1
                }

            },
            Transition {
                from: "open"
                to: "closed"

                NumberAnimation {
                    properties: "scale, opacity"
                    duration: 200
                    easing.type: Easing.InQuad
                }

            }
        ]

        TapHandler {
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 15
            anchors.leftMargin: 15
            color: "#000000"
            opacity: 0.4
            radius: root.cornerRadius
            z: -1
        }

        Rectangle {
            anchors.fill: parent
            color: root.backgroundColor
            radius: root.cornerRadius
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1
            clip: true
        }

        ColumnLayout {
            id: innerLayout

            anchors.fill: parent
            anchors.margins: root.contentPadding
            spacing: 15
        }

    }

}
