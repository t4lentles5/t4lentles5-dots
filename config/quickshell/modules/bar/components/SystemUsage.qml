import QtQuick
import QtQuick.Layouts

RowLayout {
    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0

    spacing: 0

    Theme {
        id: theme
    }

    Text {
        text: "CPU: " + cpuUsage + "%"
        color: theme.colYellow
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
        Layout.rightMargin: 8
    }

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 0
        Layout.rightMargin: 8
        color: theme.colMuted
    }

    Text {
        text: "Mem: " + memUsage + "%"
        color: theme.colCyan
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
        Layout.rightMargin: 8
    }

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: 0
        Layout.rightMargin: 8
        color: theme.colMuted
    }

    Text {
        text: "Disk: " + diskUsage + "%"
        color: theme.colBlue
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
        Layout.rightMargin: 8
    }

}
