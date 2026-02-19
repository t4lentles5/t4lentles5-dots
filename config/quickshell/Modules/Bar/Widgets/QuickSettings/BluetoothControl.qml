import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

RowLayout {
    id: root

    property bool expanded: false
    property bool enabled: false
    property var btList: []
    property var _tempBtList: []

    function toggle() {
        btSetProc.command = ["bluetoothctl", "power", root.enabled ? "off" : "on"];
        btSetProc.running = true;
        root.enabled = !root.enabled;
    }

    function scan() {
        if (root.expanded && root.enabled) {
            if (!btScanProc.running)
                btScanProc.running = true;

        }
    }

    function connect(mac) {
        btConnectProc.command = ["bluetoothctl", "connect", mac];
        btConnectProc.running = true;
    }

    spacing: 2
    onExpandedChanged: {
        if (expanded && enabled) {
            btDiscoveryProc.running = true;
            scan();
        } else {
            btDiscoveryProc.running = false;
        }
    }
    onEnabledChanged: {
        if (expanded && enabled) {
            btDiscoveryProc.running = true;
            scan();
        } else {
            btDiscoveryProc.running = false;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            btGetProc.running = true;
            if (root.expanded)
                scan();

        }
    }

    Process {
        id: btGetProc

        command: ["bluetoothctl", "show"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                let cleanData = data.replace(/\u001b\[[0-9;]*m/g, "");
                if (cleanData.includes("Powered: yes"))
                    root.enabled = true;
                else if (cleanData.includes("Powered: no"))
                    root.enabled = false;
            }
        }

    }

    Process {
        id: btSetProc
    }

    Process {
        id: btDiscoveryProc

        command: ["bluetoothctl", "scan", "on"]
    }

    Process {
        id: btScanProc

        command: ["bluetoothctl", "devices"]
        onRunningChanged: {
            if (running)
                root._tempBtList = [];
            else
                root.btList = root._tempBtList;
        }

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                let line = data.replace(/\u001b\[[0-9;]*m/g, "").trim();
                let match = line.match(/(?:^|\s)Device\s+([0-9A-F:]{17})\s+(.*)$/);
                if (!match)
                    return ;

                let mac = match[1];
                let name = match[2];
                let list = root._tempBtList;
                let exists = false;
                for (let i = 0; i < list.length; i++) {
                    if (list[i].mac === mac) {
                        exists = true;
                        break;
                    }
                }
                if (!exists) {
                    list.push({
                        "name": name,
                        "mac": mac
                    });
                    root._tempBtList = list;
                }
            }
        }

    }

    Process {
        id: btConnectProc
    }

    Rectangle {
        Layout.preferredWidth: root.enabled ? 84 : 44
        Layout.preferredHeight: 40
        radius: 20
        color: root.enabled ? Theme.colBlue : (btHover.hovered ? Theme.colBgLighter : Theme.colBgSecondary)
        clip: true

        HoverHandler {
            id: btHover

            enabled: !root.enabled
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.centerIn: parent
                    text: "󰂯"
                    color: root.enabled ? Theme.colBg : Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggle()
                }

            }

            Rectangle {
                visible: root.enabled
                width: 1
                Layout.fillHeight: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
                color: root.enabled ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.1)
            }

            Item {
                visible: root.enabled
                Layout.preferredWidth: 24
                Layout.fillHeight: true

                Text {
                    anchors.centerIn: parent
                    text: root.expanded ? "▲" : "▼"
                    color: root.enabled ? Theme.colBg : Theme.colMuted
                    font.pixelSize: 10
                    opacity: root.enabled ? 0.8 : 1
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.expanded = !root.expanded
                }

            }

        }

    }

}
