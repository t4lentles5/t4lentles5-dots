import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

Item {
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

    implicitWidth: 40
    implicitHeight: 40

    Process {
        id: screenshotProc

        command: ["true"]
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: root.expanded ? Theme.colPurple : (shotHover.hovered ? Theme.colBgLighter : Theme.colBg)

        HoverHandler {
            id: shotHover

            enabled: !root.expanded
        }

        Text {
            anchors.centerIn: parent
            text: ""
            color: root.expanded ? Theme.colBg : Theme.colFg
            font.family: Theme.fontFamily
            font.pixelSize: 20
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }

    }

}
