import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

IconButton {
    id: root

    signal requestClose()

    icon: "󰈋"
    iconColor: Theme.red
    hoverColor: Theme.red
    iconSize: Constants.sizeXl
    onClicked: {
        root.requestClose();
        colorPickerTimer.start();
    }

    Process {
        id: colorPickerProc

        command: ["sh", "-c", "hyprpicker -a"]
    }

    Timer {
        id: colorPickerTimer

        interval: 400
        repeat: false
        onTriggered: {
            colorPickerProc.running = false;
            colorPickerProc.running = true;
        }
    }

}
