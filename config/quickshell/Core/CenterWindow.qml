import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Core

PanelWindow {
    id: root

    property string popupId: ""
    property bool isOpen: false
    default property alias content: innerLayout.data
    property int animationDuration: 500
    property color backgroundColor: Colors.bg
    property int preferredWidth: 600
    property int preferredHeight: 500
    property bool _windowVisible: false

    signal popupOpened()
    signal popupClosed()

    surfaceFormat.opaque: false
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

        interval: root.animationDuration
        repeat: false
        onTriggered: root._windowVisible = false
    }

    Item {
        anchors.fill: parent
        clip: true

        Item {
            id: container

            width: root.preferredWidth
            height: root.preferredHeight
            anchors.horizontalCenter: parent.horizontalCenter
            transformOrigin: Item.Center
            focus: root.isOpen
            Keys.onEscapePressed: root.isOpen = false
            layer.enabled: true
            y: root.height > 0 ? (root.isOpen ? (root.height - root.preferredHeight) / 2 : root.height + root.preferredHeight) : 3000
            opacity: root.isOpen ? 1 : 0

            MouseArea {
                anchors.fill: parent
            }

            Rectangle {
                anchors.fill: parent
                color: root.backgroundColor
                radius: Constants.sizeLg
                border.width: 1
                border.color: Colors.border
                clip: true
            }

            ColumnLayout {
                id: innerLayout

                anchors.fill: parent
                anchors.margins: Constants.sizeLg
                spacing: Constants.sizeLg
            }

            Behavior on y {
                enabled: root.height > 0

                NumberAnimation {
                    duration: root.isOpen ? root.animationDuration : 250
                    easing.type: root.isOpen ? Easing.OutBack : Easing.InOutQuad
                    easing.overshoot: 0.4
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.25, 0.1, 0.25, 1]
                }

            }

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
