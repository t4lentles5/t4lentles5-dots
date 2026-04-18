import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Core

BarButton {
    id: root

    implicitWidth: layout.implicitWidth + 24
    mouseArea.hoverEnabled: false

    RowLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Constants.sizeSm

        Repeater {
            model: 10

            Rectangle {
                id: wsItem

                readonly property int wsId: index + 1
                readonly property var workspace: Hyprland.workspaces.values.find((ws) => {
                    return ws.id === wsId;
                })
                readonly property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === wsId : false
                readonly property bool hasWindows: workspace !== undefined && (workspace.windows > 0 || workspace.id === wsId)

                Layout.preferredWidth: isActive ? 28 : (hasWindows ? 10 : 8)
                Layout.preferredHeight: isActive ? 10 : (hasWindows ? 10 : 8)
                radius: isActive ? 5 : (hasWindows ? 5 : 4)
                color: isActive ? Theme.yellow : (hasWindows ? Theme.cyan : (mouseArea.containsMouse ? Theme.fg : Theme.muted))

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent
                    anchors.margins: -12
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + wsId)
                }

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: Constants.animSlow
                        easing.type: Easing.OutBack
                    }

                }

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: Constants.animSlow
                        easing.type: Easing.OutBack
                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: Constants.animSlow
                    }

                }

            }

        }

    }

}
