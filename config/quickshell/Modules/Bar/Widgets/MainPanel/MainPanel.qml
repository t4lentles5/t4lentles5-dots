import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Core
import qs.Modules.Bar.Widgets.MainPanel.Dashboard as MainPanelDashboard
import qs.Modules.Bar.Widgets.MainPanel.Performance as MainPanelPerformance

TopPopup {
    id: mainPanelPopup

    property int activeTab: 0

    onIsOpenChanged: {
        if (isOpen)
            activeTab = 0;

    }

    ColumnLayout {
        id: mainLayout

        implicitWidth: 760
        spacing: Constants.sizeLg

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 48

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Theme.border
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                TabButton {
                    tabIcon: "󱂬"
                    tabText: "Dashboard"
                    isActive: mainPanelPopup.activeTab === 0
                    onClicked: mainPanelPopup.activeTab = 0
                }

                TabButton {
                    tabIcon: "󰓅"
                    tabText: "Performance"
                    isActive: mainPanelPopup.activeTab === 1
                    onClicked: mainPanelPopup.activeTab = 1
                }

            }

        }

        Item {
            Layout.fillWidth: true
            implicitWidth: 760
            implicitHeight: 330

            MainPanelDashboard.Dashboard {
                id: dashboardTabContent

                widget: mainPanelPopup
                visible: opacity > 0.01
                opacity: mainPanelPopup.activeTab === 0 ? 1 : 0
                anchors.fill: parent

                transform: Translate {
                    x: mainPanelPopup.activeTab === 0 ? 0 : -30

                    Behavior on x {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }

                }

            }

            MainPanelPerformance.Performance {
                id: performanceTabContent

                visible: opacity > 0.01
                opacity: mainPanelPopup.activeTab === 1 ? 1 : 0
                anchors.fill: parent

                transform: Translate {
                    x: mainPanelPopup.activeTab === 1 ? 0 : 30

                    Behavior on x {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

    }

    component TabButton: Item {
        id: tabBtn

        property string tabIcon: ""
        property string tabText: ""
        property bool isActive: false

        signal clicked()

        Layout.fillWidth: true
        Layout.fillHeight: true

        RowLayout {
            anchors.centerIn: parent
            spacing: Constants.sizeSm

            ThemedText {
                text: tabBtn.tabIcon
                font.pixelSize: Constants.sizeMd + 2
                color: tabBtn.isActive ? Theme.purple : (hoverHandler.hovered ? Theme.fg : Theme.muted)
                Layout.alignment: Qt.AlignVCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

            ThemedText {
                text: tabBtn.tabText
                font.pixelSize: Constants.sizeSm
                font.weight: tabBtn.isActive ? Font.Bold : Font.Normal
                color: tabBtn.isActive ? Theme.purple : (hoverHandler.hovered ? Theme.fg : Theme.muted)
                Layout.alignment: Qt.AlignVCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: tabBtn.isActive ? 100 : 0
            height: 3
            radius: 1.5
            color: Theme.purple

            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }

            }

        }

        HoverHandler {
            id: hoverHandler

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: tabBtn.clicked()
        }

    }

}
