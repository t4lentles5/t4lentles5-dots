import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Core

PanelWindow {
    id: root

    property string popupId: ""
    property bool isOpen: false
    property int cornerRadius: 8
    property int contentPadding: 16
    default property alias content: innerLayout.data
    property int animationDuration: 300
    property color backgroundColor: Theme.colBg
    property int preferredWidth: 600
    property int preferredHeight: 500
    property bool _windowVisible: false

    signal popupOpened()
    signal popupClosed()

    onIsOpenChanged: {
        if (popupId === "")
            return ;

        if (isOpen) {
            if (AppState.activePopup !== popupId)
                AppState.activePopup = popupId;

            closeDelayTimer.stop();
            _windowVisible = true;
            root.popupOpened();
        } else {
            if (AppState.activePopup === popupId)
                AppState.activePopup = "";

            closeDelayTimer.start();
            root.popupClosed();
        }
    }
    color: "transparent"
    focusable: true
    exclusionMode: ExclusionMode.Ignore
    visible: _windowVisible
    Component.onCompleted: {
        if (root.popupId !== "")
            socketCleanup.running = true;

    }

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

    MouseArea {
        anchors.fill: parent
        onClicked: root.isOpen = false
    }

    Timer {
        id: closeDelayTimer

        interval: root.animationDuration * 0.8
        repeat: false
        onTriggered: root._windowVisible = false
    }

    Item {
        id: container

        width: root.preferredWidth
        height: root.preferredHeight
        anchors.centerIn: parent
        transformOrigin: Item.Center
        focus: root.isOpen
        Keys.onEscapePressed: root.isOpen = false
        states: [
            State {
                name: "open"
                when: root.isOpen

                PropertyChanges {
                    target: container
                    opacity: 1
                    scale: 1
                }

                PropertyChanges {
                    target: containerTranslate
                    y: 0
                }

            },
            State {
                name: "closed"
                when: !root.isOpen

                PropertyChanges {
                    target: container
                    opacity: 0
                    scale: 0.95
                }

                PropertyChanges {
                    target: containerTranslate
                    y: 20
                }

            }
        ]
        transitions: [
            Transition {
                from: "closed"
                to: "open"

                ParallelAnimation {
                    NumberAnimation {
                        target: container
                        property: "opacity"
                        duration: root.animationDuration
                        easing.type: Easing.OutQuad
                    }

                    NumberAnimation {
                        target: container
                        property: "scale"
                        duration: root.animationDuration
                        easing.type: Easing.OutQuint
                    }

                    NumberAnimation {
                        target: containerTranslate
                        property: "y"
                        duration: root.animationDuration
                        easing.type: Easing.OutQuint
                    }

                }

            },
            Transition {
                from: "open"
                to: "closed"

                ParallelAnimation {
                    NumberAnimation {
                        target: container
                        property: "opacity"
                        duration: root.animationDuration * 0.8
                        easing.type: Easing.InQuad
                    }

                    NumberAnimation {
                        target: container
                        property: "scale"
                        duration: root.animationDuration * 0.8
                        easing.type: Easing.InQuint
                    }

                    NumberAnimation {
                        target: containerTranslate
                        property: "y"
                        duration: root.animationDuration * 0.8
                        easing.type: Easing.InQuint
                    }

                }

            }
        ]

        MouseArea {
            anchors.fill: parent
        }

        Rectangle {
            anchors.fill: parent
            color: root.backgroundColor
            radius: root.cornerRadius
            border.color: Qt.rgba(1, 1, 1, 0.05)
            border.width: 1
            clip: true
        }

        ColumnLayout {
            id: innerLayout

            anchors.fill: parent
            anchors.margins: root.contentPadding
            spacing: Theme.spacingLg
        }

        transform: Translate {
            id: containerTranslate

            y: 0
        }

    }

    SocketServer {
        id: server

        path: "/tmp/quickshell_" + root.popupId
        active: false

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

    Process {
        id: socketCleanup

        command: ["rm", "-f", "/tmp/quickshell_" + root.popupId]
        onExited: function(exitCode) {
            if (root.popupId !== "")
                server.active = true;

        }
    }

}
