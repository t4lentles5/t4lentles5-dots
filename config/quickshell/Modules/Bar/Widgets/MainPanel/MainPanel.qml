import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Modules.Bar.Widgets.MainPanel.Dashboard
import qs.Modules.Bar.Widgets.MainPanel.Pomodoro

TopPopup {
    id: root

    property alias swipeView: swipeView
    property int internalPadding: 0

    anchor.window: mainBar
    anchor.rect.x: (mainBar.width - implicitWidth) / 2
    anchor.rect.y: mainBar.height
    anchor.adjustment: PopupAdjustment.None
    implicitWidth: 800
    preferredHeight: 450

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: root.internalPadding
        spacing: 15

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Theme.colMuted
                opacity: 0.5
            }

            RowLayout {
                anchors.fill: parent
                spacing: 10

                Repeater {
                    id: tabRepeater

                    model: ["󰕮 Dashboard", "󰔛 Pomodoro"]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: swipeView.currentIndex === index ? Theme.colPurple : Theme.colFg
                            font.bold: true
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize

                            Behavior on font.pixelSize {
                                NumberAnimation {
                                    duration: 200
                                }

                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }

                            }

                        }

                        TapHandler {
                            onTapped: swipeView.currentIndex = index
                        }

                        HoverHandler {
                            id: hoverHandler

                            enabled: swipeView.currentIndex !== index
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 8
                            color: Theme.colFg
                            opacity: hoverHandler.hovered ? 0.08 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 250
                                }

                            }

                        }

                    }

                }

            }

            Rectangle {
                anchors.bottom: parent.bottom
                height: 3
                color: Theme.colPurple
                width: parent.width / tabRepeater.count
                x: swipeView.width > 0 ? (swipeView.contentItem.contentX / swipeView.width) * width : 0
            }

        }

        SwipeView {
            id: swipeView

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            padding: 0

            Dashboard {
            }

            Pomodoro {
            }

        }

    }

}
