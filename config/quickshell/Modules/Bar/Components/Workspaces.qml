import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Core

Rectangle {
    id: container
    
    color: Theme.colBgSecondary 
    radius: 20
    
    implicitWidth: layout.implicitWidth + 30 
    implicitHeight: 30

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 10
        

        Repeater {
            model: 10

            Rectangle {
                id: wsItem
                Layout.preferredWidth: 20
                Layout.preferredHeight: 30
                color: "transparent"

                property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                property bool hasWindows: workspace !== null

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }

                Text {
                    id: wsIcon
                    text: wsItem.isActive ? "󰮯" : "󰊠"
                    color: wsItem.isActive ? Theme.colYellow : (wsItem.hasWindows ? Theme.colCyan : (mouseArea.containsMouse ? Theme.colFg : Theme.colMuted))
                    font.pixelSize: Theme.fontSize
                    font.family: Theme.fontFamily
                    anchors.centerIn: parent
                    scale: wsItem.isActive ? 1.2 : (mouseArea.containsMouse ? 1.1 : 1.0)
                    opacity: wsItem.isActive || wsItem.hasWindows || mouseArea.containsMouse ? 1.0 : 0.6

                    Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutQuart } }
                    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }
            }
        }
    }
}