import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

FloatingWindow {
    id: root

    property string popupId: ""
    property string windowTitle: ""
    property string windowIcon: ""
    property color windowIconColor: Theme.purple
    property bool showHeader: true
    default property alias content: innerLayout.data
    property alias headerActions: headerActionsRow.data
    property color backgroundColor: Theme.bg
    property int contentPadding: Constants.sizeLg

    signal windowClosed()

    title: windowTitle
    color: backgroundColor
    visible: false
    onClosed: {
        visible = false;
    }
    onVisibleChanged: {
        if (!visible)
            root.windowClosed();

    }
    Component.onCompleted: {
        if (root.popupId !== "")
            socketCleanup.running = true;

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.contentPadding
        spacing: Constants.sizeLg

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeMd
            visible: root.showHeader
            Layout.leftMargin: Constants.sizeXs
            Layout.rightMargin: Constants.sizeXs

            ThemedText {
                text: root.windowIcon
                font.pixelSize: Constants.sizeLg
                color: root.windowIconColor
                visible: root.windowIcon !== ""

                Behavior on color {
                    ColorAnimation {
                        duration: Constants.animNormal
                    }

                }

            }

            ThemedText {
                text: root.windowTitle
                font.pixelSize: Constants.sizeSm + 2
                font.bold: true
                color: Theme.fg
                visible: root.windowTitle !== ""
            }

            Item {
                Layout.fillWidth: true
            }

            Row {
                id: headerActionsRow

                spacing: Constants.sizeXs
            }

            IconButton {
                icon: "󰅖"
                iconColor: Theme.muted
                hoverColor: Theme.red
                bgColor: "transparent"
                onClicked: root.visible = false
            }

        }

        ColumnLayout {
            id: innerLayout

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Constants.sizeLg
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
                        root.visible = !root.visible;
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
