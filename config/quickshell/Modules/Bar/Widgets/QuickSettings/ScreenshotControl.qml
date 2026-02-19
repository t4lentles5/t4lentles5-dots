import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

QuickActionButton {
    id: root

    property bool expanded: false

    signal closeRequested()

    function capture(mode) {
        root.closeRequested();
        let scriptPath = "~/.config/quickshell/Scripts/screenshot.sh";
        let cmd = `nohup sh ${scriptPath} ${mode} > /dev/null 2>&1 &`;
        runShot(cmd);
    }

    function runShot(cmd) {
        if (screenshotProc.running)
            screenshotProc.running = false;

        screenshotProc.command = ["sh", "-c", cmd];
        screenshotProc.running = true;
    }

    icon: ""
    active: expanded
    activeColor: Theme.colPurple
    iconColor: Theme.colPurple
    onClicked: expanded = !expanded

    Process {
        id: screenshotProc

        command: ["true"]
    }

}
