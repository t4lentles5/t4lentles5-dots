import "./components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

Scope {
    // System Info Aliases
    // property alias cpuUsage: sys.cpuUsage
    // property alias memUsage: sys.memUsage
    // property alias diskUsage: sys.diskUsage
    // property alias volumeLevel: sys.volumeLevel

    id: root

    // Theme Aliases
    property alias colBg: theme.colBg
    property alias colBgSecondary: theme.colBgSecondary
    property alias colFg: theme.colFg
    property alias colMuted: theme.colMuted
    property alias colCyan: theme.colCyan
    property alias colPurple: theme.colPurple
    property alias colRed: theme.colRed
    property alias colYellow: theme.colYellow
    property alias colBlue: theme.colBlue
    property alias colBlueArch: theme.colBlueArch
    property alias colGreen: theme.colGreen
    property alias fontFamily: theme.fontFamily
    property alias fontSize: theme.fontSize

    // Components
    Theme {
        id: theme
    }

    SystemMonitor {
        id: sys
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData

            screen: modelData
            implicitHeight: 45
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: 10
                bottom: 10
                left: 10
                right: 10
            }

            Rectangle {
                anchors.fill: parent
                color: root.colBg
                radius: 24

                RowLayout {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    Text {
                        text: "󰣇 "
                        color: root.colBlueArch
                        font.pixelSize: 20
                        font.family: root.fontFamily
                        Layout.leftMargin: 20
                    }

                    Music {
                    }

                }

                // Center: Workspaces
                Workspaces {
                    anchors.centerIn: parent
                }

                // Right: System Info & Clock
                RowLayout {
                    // SystemUsage {
                    //     cpuUsage: root.cpuUsage
                    //     memUsage: root.memUsage
                    //     diskUsage: root.diskUsage
                    // }
                    // Text {
                    //     text: "Vol: " + volumeLevel + "%"
                    //     color: root.colPurple
                    //     font.pixelSize: root.fontSize
                    //     font.family: root.fontFamily
                    //     font.bold: true
                    //     Layout.rightMargin: 8
                    // }

                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    spacing: 15

                    KeyboardLayout {
                    }

                    QuickSettings {
                    }

                    Clock {
                    }

                    Notifications {
                    }

                    RowLayout {
                        spacing: 10

                        Text {
                            text: "⏻ "
                            color: root.colRed
                            font.pixelSize: 16
                            font.family: root.fontFamily
                            font.bold: true
                            Layout.maximumWidth: 300
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            Layout.rightMargin: 15
                        }

                    }

                }

            }

        }

    }

}
