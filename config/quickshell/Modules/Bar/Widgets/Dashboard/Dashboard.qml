import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Core
import qs.Modules.Bar.Widgets.Dashboard.Widgets
import qs.Modules.Bar.Widgets.QuickSettings

TopPopup {
    ColumnLayout {
        id: mainLayout

        spacing: Constants.sizeLg

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeLg
            Layout.preferredHeight: Math.max(userCard.implicitHeight, updatesCard.implicitHeight)

            UserCard {
                id: userCard

                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            UpdatesCard {
                id: updatesCard

                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(userCard.implicitHeight, implicitHeight)
            }

        }

        ResourcesCard {
            Layout.alignment: Qt.AlignHCenter
        }

    }

}
