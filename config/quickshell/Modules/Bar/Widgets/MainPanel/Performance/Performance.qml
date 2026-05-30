import QtQuick
import QtQuick.Layouts
import qs.Core

ColumnLayout {
    id: root

    implicitWidth: 760
    implicitHeight: 330
    spacing: Constants.sizeLg

    RowLayout {
        spacing: Constants.sizeLg
        Layout.fillWidth: true
        Layout.preferredHeight: 110
        Layout.fillHeight: false

        CpuCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        GpuCard {
            id: gpuCard

            Layout.fillWidth: visible
            Layout.fillHeight: true
        }

    }

    RowLayout {
        spacing: Constants.sizeLg
        Layout.fillWidth: true
        Layout.fillHeight: true

        MemoryCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        StorageCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        BatteryCard {
            Layout.fillWidth: false
            Layout.preferredWidth: visible ? 120 : 0
            Layout.fillHeight: true
        }

    }

}
