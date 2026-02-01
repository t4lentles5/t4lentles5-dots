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
                    text: parent.isActive ? "󰮯" : "󰊠"
                    color: parent.isActive ? Theme.colYellow : (parent.hasWindows ? Theme.colCyan : (mouseArea.containsMouse ? Theme.colFg : Theme.colMuted))
                    font.pixelSize: Theme.fontSize
                    font.family: Theme.fontFamily
                    anchors.centerIn: parent

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
            }
        }
    }
}