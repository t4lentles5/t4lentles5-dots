import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Modules.Bar.Widgets.MainPanel.Components

TopPopup {
    id: root

    anchor.window: mainBar
    anchor.rect.x: (mainBar.width - implicitWidth) / 2
    anchor.rect.y: mainBar.height
    anchor.adjustment: PopupAdjustment.None
    implicitWidth: 750

    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: availableWidth
        contentHeight: mainCol.implicitHeight
        clip: true

        ColumnLayout {
            id: mainCol

            width: parent.width
            spacing: Theme.spacingLg

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                spacing: Theme.spacingLg

                UserCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 2
                }

                SystemUpdatesCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 2
                }

            }

            SystemMonitorCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
            }

        }

    }

}
