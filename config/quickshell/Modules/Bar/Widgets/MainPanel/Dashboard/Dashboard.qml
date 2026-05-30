import QtQuick
import QtQuick.Layouts
import qs.Core

RowLayout {
    id: root

    property var widget

    spacing: Constants.sizeLg

    ColumnLayout {
        spacing: Constants.sizeLg
        Layout.preferredWidth: 520
        Layout.fillHeight: true

        RowLayout {
            spacing: Constants.sizeLg
            Layout.fillWidth: true
            Layout.preferredHeight: 130

            UserCard {
                id: userCard

                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            UpdatesCard {
                id: updatesCard

                Layout.fillWidth: true
                Layout.fillHeight: true
            }

        }

        RowLayout {
            spacing: Constants.sizeLg
            Layout.fillWidth: true
            Layout.fillHeight: true

            ClockCard {
                id: clockCard

                Layout.preferredWidth: 90
                Layout.fillHeight: true
            }

            GithubWidget {
                id: githubWidget

                Layout.preferredWidth: 250
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

        }

    }

    NowPlayingCard {
        id: nowPlayingCard

        widget: root.widget
        Layout.preferredWidth: 200
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
    }

}
