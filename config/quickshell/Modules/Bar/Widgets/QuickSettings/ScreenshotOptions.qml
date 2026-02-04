import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Rectangle {
    id: root

    property bool expanded: false

    signal capture(string mode)

    Layout.fillWidth: true
    Layout.preferredHeight: expanded ? (shotGrid.implicitHeight + 20) : 0
    opacity: expanded ? 1 : 0
    visible: expanded || Layout.preferredHeight > 0
    color: Theme.colBgSecondary
    radius: 12
    clip: true

    GridLayout {
        id: shotGrid

        columns: 2
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        rowSpacing: 10
        columnSpacing: 10

        ShotBtn {
            label: "Full"
            icon: "󰹑"
            mode: "full"
        }

        ShotBtn {
            label: "Select"
            icon: "󰆞"
            mode: "area"
        }

        ShotBtn {
            label: "Window"
            icon: ""
            mode: "window"
        }

        ShotBtn {
            label: "Full (3s)"
            icon: "󰔝"
            mode: "full_delay"
        }

        ShotBtn {
            label: "Select (3s)"
            icon: "󰆞 󰔝"
            mode: "area_delay"
        }

        component ShotBtn: Rectangle {
            id: btnRoot

            property string label
            property string icon
            property string mode

            Layout.preferredWidth: 140
            Layout.preferredHeight: 36
            radius: 18
            color: shotHover.hovered ? Theme.colBgLighter : Theme.colBg

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: btnRoot.icon
                    color: Theme.colPurple
                    font.pixelSize: 16
                    font.family: Theme.fontFamily
                }

                Text {
                    text: btnRoot.label
                    color: Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }

            }

            HoverHandler {
                id: shotHover
            }

            TapHandler {
                onTapped: root.capture(btnRoot.mode)
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
