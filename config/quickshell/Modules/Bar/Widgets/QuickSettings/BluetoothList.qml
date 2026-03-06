import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Rectangle {
    id: root

    property bool expanded: false
    property bool enabled: false
    property var btList: []

    signal connect(string mac)

    Layout.fillWidth: true
    Layout.preferredHeight: expanded ? Math.max(btListCol.implicitHeight + 20, 100) : 0
    opacity: expanded ? 1 : 0
    visible: expanded || Layout.preferredHeight > 0
    color: Theme.colBgSecondary
    radius: Theme.radiusSm
    clip: true

    Item {
        anchors.centerIn: parent
        width: 100
        height: 50
        visible: root.expanded && root.btList.length === 0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacingSm

            Item {
                Layout.alignment: Qt.AlignHCenter
                width: 32
                height: 32

                ThemedText {
                    anchors.centerIn: parent
                    text: "󰑐"
                    color: Theme.colBlue
                    font.pixelSize: 24
                }

                RotationAnimation on rotation {
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: parent.visible
                }

            }

            ThemedText {
                Layout.alignment: Qt.AlignHCenter
                text: "Scanning..."
                color: Theme.colMuted
                font.pixelSize: Theme.fontSizeSm
            }

        }

    }

    ColumnLayout {
        id: btListCol

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 5
        visible: root.btList.length > 0

        ThemedText {
            text: "Available Devices"
            color: Theme.colMuted
            font.pixelSize: Theme.fontSizeSm
            Layout.bottomMargin: 5
        }

        Repeater {
            model: root.btList

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                color: hoverHandlerB.hovered ? Theme.colBgLighter : "transparent"
                radius: Theme.radiusSm

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    ThemedText {
                        text: modelData.name
                        color: Theme.colFg
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                }

                HoverHandler {
                    id: hoverHandlerB
                }

                TapHandler {
                    onTapped: root.connect(modelData.mac)
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animSlow
                    }

                }

            }

        }

    }

    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: Theme.animSlow
            easing.type: Easing.OutQuint
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutQuint
        }

    }

}
