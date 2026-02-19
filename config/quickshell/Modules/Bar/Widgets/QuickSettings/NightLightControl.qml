import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

QuickActionButton {
    id: root

    property bool activeState: false

    icon: activeState ? "󰖔" : "󰖙"
    active: activeState
    activeColor: Theme.colYellow
    iconColor: activeState ? Theme.colBg : Theme.colYellow
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
