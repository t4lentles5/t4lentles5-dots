import QtQuick
import qs.Core

BarButton {
    text: Qt.formatDateTime(new Date(), "HH:mm")
    textColor: Theme.blue

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            text = Qt.formatDateTime(new Date(), "HH:mm");
        }
    }

}
