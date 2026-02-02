import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Modules.Bar.Widgets.MainPanel.Dashboard.Components

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        RowLayout {
            spacing: 15
            Layout.fillWidth: true
            Layout.fillHeight: true

            UserCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            MusicPlayerCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

        }

        SystemMonitorCard {
            Layout.fillWidth: true
        }

    }

}
