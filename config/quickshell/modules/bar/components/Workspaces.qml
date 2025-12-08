import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: container
    
    color: root.colBgSecondary 
    radius: 20
    
    implicitWidth: layout.implicitWidth + 30 
    implicitHeight: 30

    Theme {
        id: theme
    }

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

                Text {
                    text: parent.isActive ? "󰮯" : "󰊠"
                    color: parent.isActive ? theme.colYellow : (parent.hasWindows ? theme.colCyan : theme.colMuted)
                    font.pixelSize: theme.fontSize
                    font.family: theme.fontFamily
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }
    }
}