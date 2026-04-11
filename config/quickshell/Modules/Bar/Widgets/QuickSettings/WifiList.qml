import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

Rectangle {
    id: root

    property bool expanded: false
    property bool isActive: false
    property var wifiList: []
    property bool timedOut: false

    signal connect(string ssid)

    Layout.fillWidth: true
    Layout.preferredHeight: expanded ? Math.max(wifiListCol.implicitHeight + (Constants.sizeSm * 2), 80) : 0
    opacity: expanded ? 1 : 0
    visible: opacity > 0
    clip: true
    radius: Constants.sizeXs
    color: Colors.bgSecondary

    Timer {
        id: scanTimeout

        interval: 10000
        running: root.expanded && root.wifiList.length === 0
        onTriggered: root.timedOut = true
        onRunningChanged: {
            if (!running && !root.expanded)
                root.timedOut = false;

        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Constants.sizeXs
        visible: root.expanded && root.wifiList.length === 0

        Item {
            Layout.alignment: Qt.AlignHCenter
            width: 20
            height: 20
            visible: !root.timedOut

            ThemedText {
                anchors.centerIn: parent
                text: "󰑐"
                color: Colors.muted
                font.pixelSize: Constants.sizeMd
            }

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 1200
                loops: Animation.Infinite
                running: parent.visible
            }

        }

        ThemedText {
            Layout.alignment: Qt.AlignHCenter
            text: root.timedOut ? "No networks found" : "Scanning..."
            color: Colors.muted
            font.pixelSize: Constants.sizeSm
        }

    }

    ColumnLayout {
        id: wifiListCol

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Constants.sizeSm
        anchors.leftMargin: Constants.sizeSm
        anchors.rightMargin: Constants.sizeSm
        anchors.bottomMargin: Constants.sizeSm
        visible: root.wifiList.length > 0

        ThemedText {
            text: "Networks"
            font.pixelSize: Constants.sizeSm
            font.letterSpacing: 1
            color: Colors.muted
        }

        Repeater {
            model: root.wifiList

            Item {
                Layout.fillWidth: true
                implicitHeight: 28

                RowLayout {
                    anchors.fill: parent
                    spacing: Constants.sizeXs

                    Rectangle {
                        width: 4
                        height: 4
                        radius: 2
                        color: Colors.purple
                        opacity: modelData.active ? 0.8 : 0
                        Layout.alignment: Qt.AlignVCenter

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Constants.animNormal
                            }

                        }

                    }

                    ThemedText {
                        text: modelData.ssid
                        color: modelData.active ? Colors.purple : Colors.fg
                        font.pixelSize: Constants.sizeSm
                        font.weight: modelData.active ? Font.Medium : Font.Normal
                        opacity: hoverHandlerW.hovered ? 1 : (modelData.active ? 0.9 : 0.65)
                        Layout.fillWidth: true
                        elide: Text.ElideRight

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Constants.animNormal
                            }

                        }

                    }

                    ThemedText {
                        text: modelData.signal + "%"
                        color: Colors.muted
                        font.pixelSize: 9
                        opacity: 0.4
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

    transform: Translate {
        y: root.expanded ? 0 : -Constants.sizeSm

        Behavior on y {
            NumberAnimation {
                duration: Constants.animFast
                easing.type: Easing.Bezier
                easing.bezierCurve: root.expanded ? [0.05, 0.9, 0.1, 1] : [0.3, 0, 0.8, 0.15]
            }

        }

    }

    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: Constants.animFast
            easing.type: Easing.Bezier
            easing.bezierCurve: root.expanded ? [0.05, 0.9, 0.1, 1] : [0.3, 0, 0.8, 0.15]
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: Constants.animFast
            easing.type: Easing.Bezier
            easing.bezierCurve: root.expanded ? [0.05, 0.9, 0.1, 1] : [0.3, 0, 0.8, 0.15]
        }

    }

}
