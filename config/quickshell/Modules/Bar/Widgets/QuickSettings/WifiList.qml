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
    property var wifiList: []

    signal connect(string ssid)

    Layout.fillWidth: true
    Layout.preferredHeight: expanded ? Math.max(wifiListCol.implicitHeight + 20, 100) : 0
    opacity: expanded ? 1 : 0
    visible: expanded || Layout.preferredHeight > 0
    color: Theme.colBgSecondary
    radius: 12
    clip: true

    Item {
        anchors.centerIn: parent
        width: 100
        height: 50
        visible: root.expanded && root.wifiList.length === 0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            Item {
                Layout.alignment: Qt.AlignHCenter
                width: 32
                height: 32

                Text {
                    anchors.centerIn: parent
                    text: "󰑐"
                    color: Theme.colPurple
                    font.pixelSize: 24
                    font.family: Theme.fontFamily
                }

                RotationAnimation on rotation {
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: parent.visible
                }

            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Scanning..."
                color: Theme.colMuted
                font.pixelSize: 12
                font.family: Theme.fontFamily
            }

        }

    }

    ColumnLayout {
        id: wifiListCol

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 5
        visible: root.wifiList.length > 0

        Text {
            text: "Available Networks"
            color: Theme.colMuted
            font.pixelSize: 12
            font.family: Theme.fontFamily
            Layout.bottomMargin: 5
        }

        Repeater {
            model: root.wifiList

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                color: hoverHandlerW.hovered ? Theme.colBgLighter : "transparent"
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Text {
                        text: modelData.ssid
                        color: modelData.active ? Theme.colPurple : Theme.colFg
                        font.family: Theme.fontFamily
                        font.bold: modelData.active
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        text: modelData.signal + "%"
                        color: Theme.colMuted
                        font.pixelSize: 10
                        font.family: Theme.fontFamily
                        verticalAlignment: Text.AlignVCenter
                    }

                }

                HoverHandler {
                    id: hoverHandlerW
                }

                TapHandler {
                    onTapped: root.connect(modelData.ssid)
                }

            }

        }

    }

    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }

    }

}
