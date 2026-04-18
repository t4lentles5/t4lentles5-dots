import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

Rectangle {
    id: root

    property bool expanded: false
    property bool isActive: false
    property var btList: []
    property bool timedOut: false

    signal connect(string mac)

    Layout.fillWidth: true
    Layout.preferredHeight: expanded ? Math.max(btListCol.implicitHeight + 16, 80) : 0
    opacity: expanded ? 1 : 0
    visible: opacity > 0
    clip: true
    radius: Constants.sizeXs
    color: Theme.bgSecondary

    Timer {
        id: scanTimeout

        interval: 10000
        running: root.expanded && root.btList.length === 0
        onTriggered: root.timedOut = true
        onRunningChanged: {
            if (!running && !root.expanded)
                root.timedOut = false;

        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Constants.sizeXs
        visible: root.expanded && root.btList.length === 0

        Item {
            Layout.alignment: Qt.AlignHCenter
            width: 20
            height: 20
            visible: !root.timedOut

            ThemedText {
                anchors.centerIn: parent
                text: "󰑐"
                color: Theme.muted
                font.pixelSize: Constants.sizeMd
            }

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 1200
                loops: Animation.Infinite
                running: parent.visible && !root.timedOut
            }

        }

        ThemedText {
            Layout.alignment: Qt.AlignHCenter
            text: root.timedOut ? "No devices found" : "Scanning..."
            color: Theme.muted
            font.pixelSize: Constants.sizeSm
        }

    }

    ColumnLayout {
        id: btListCol

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Constants.sizeSm
        anchors.leftMargin: Constants.sizeSm
        anchors.rightMargin: Constants.sizeSm
        anchors.bottomMargin: Constants.sizeSm
        visible: root.btList.length > 0

        ThemedText {
            text: "Devices"
            font.pixelSize: Constants.sizeSm
            font.letterSpacing: 1
            color: Theme.muted
        }

        Repeater {
            model: root.btList

            Item {
                Layout.fillWidth: true
                implicitHeight: 28

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Constants.sizeSm
                    anchors.rightMargin: Constants.sizeXs
                    spacing: Constants.sizeXs

                    ThemedText {
                        text: "󰂱"
                        font.pixelSize: Constants.sizeXs
                        color: Theme.blue
                        opacity: 0.5
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ThemedText {
                        text: modelData.name
                        font.pixelSize: Constants.sizeSm
                        opacity: hoverHandlerB.hovered ? 1 : 0.65
                        Layout.fillWidth: true
                        elide: Text.ElideRight

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Constants.animNormal
                            }

                        }

                    }

                }

                HoverHandler {
                    id: hoverHandlerB
                }

                TapHandler {
                    onTapped: root.connect(modelData.mac)
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
