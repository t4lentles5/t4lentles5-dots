import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

IconButton {
    id: root

    property bool activeState: false

    icon: activeState ? "󰖔" : "󰖙"
    isActive: activeState
    activeColor: Colors.yellow
    iconColor: Colors.yellow
    hoverColor: Colors.yellow
    iconSize: Constants.sizeXl
    onClicked: {
        activeState = !activeState;
        if (activeState)
            nightLightProc.command = ["sh", "-c", "hyprsunset -t 4500"];
        else
            nightLightProc.command = ["pkill", "hyprsunset"];
        nightLightProc.running = false;
        nightLightProc.running = true;
    }

    Process {
        id: nightLightProc

        command: ["sh", "-c", "pkill hyprsunset; if [ '$1' = 'true' ]; then hyprsunset -t 4500 & fi", "--", String(activeState)]
    }

}
