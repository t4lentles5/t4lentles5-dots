import QtQuick
import QtQuick.Layouts
import qs.Core

Card {
    id: root

    property date currentTime: new Date()

    implicitWidth: 80
    implicitHeight: 204

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.currentTime = new Date();
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Constants.sizeXs
        Layout.alignment: Qt.AlignHCenter

        ThemedText {
            text: {
                let hours = root.currentTime.getHours();
                hours = hours % 12;
                hours = hours ? hours : 12;
                return hours < 10 ? "0" + hours : String(hours);
            }
            font.pixelSize: 24
            font.bold: true
            color: Theme.fg
            Layout.alignment: Qt.AlignHCenter
        }

        ThemedText {
            text: "•••"
            font.pixelSize: 16
            font.bold: true
            color: Theme.purple
            opacity: 0.8
            Layout.alignment: Qt.AlignHCenter
        }

        ThemedText {
            text: {
                let minutes = root.currentTime.getMinutes();
                return minutes < 10 ? "0" + minutes : String(minutes);
            }
            font.pixelSize: 24
            font.bold: true
            color: Theme.fg
            Layout.alignment: Qt.AlignHCenter
        }

        ThemedText {
            text: root.currentTime.getHours() >= 12 ? "PM" : "AM"
            font.pixelSize: Constants.sizeSm - 1
            font.bold: true
            color: Theme.purple
            Layout.alignment: Qt.AlignHCenter
        }

    }

}
