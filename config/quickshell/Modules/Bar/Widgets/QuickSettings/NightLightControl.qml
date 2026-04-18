import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

IconButton {
    id: root

    property bool activeState: false

    icon: activeState ? "󰖔" : "󰖙"
    isActive: activeState
    activeColor: Theme.yellow
    iconColor: Theme.yellow
    hoverColor: Theme.yellow
    iconSize: Constants.sizeXl
    onClicked: {
        activeState = !activeState;
        if (activeState)
            nightLightProc.command = ["sh", "-c", "hyprsunset -t 4500"];
        else
            nightLightProc.command = ["pkill", "hyprsunset"];
        nightLightProc.running = false;
        nightLightProc.running = true;
        nlNotifyProc.command = ["notify-send", "-a", "System", "-i", Constants.iconPath.replace("file://", "") + (activeState ? "weather-clear-night.svg" : "weather-clear.svg"), "Night Light", activeState ? "Enabled" : "Disabled", "-t", "1500"];
        nlNotifyProc.running = true;
    }

    Process {
        id: nlNotifyProc
    }

    Process {
        id: nightLightProc

        command: ["sh", "-c", "pkill hyprsunset; if [ '$1' = 'true' ]; then hyprsunset -t 4500 & fi", "--", String(activeState)]
    }

}
