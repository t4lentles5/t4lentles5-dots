import Qt5Compat.GraphicalEffects
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
        if (!enabled)
            expanded = false;

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

    Item {
        Layout.preferredWidth: 84
        Layout.preferredHeight: 40

        Rectangle {
            id: bgRect

            anchors.fill: parent
            radius: 8
            color: root.enabled ? Theme.colBlue : Theme.colBg
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0
            layer.enabled: true

            IconButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "󰂯"
                iconSize: 20
                radius: 0
                iconColor: Theme.colFg
                useText: false
                isActive: false
                baseColor: root.enabled ? Theme.colBlue : "transparent"
                hoverColor: root.enabled ? Qt.lighter(Theme.colBlue, 1.2) : Theme.colBgLighter
                onClicked: root.toggle()

                Text {
                    anchors.centerIn: parent
                    text: parent.icon
                    color: root.enabled ? Theme.colBg : Theme.colFg
                    font.family: Theme.fontFamily
                    font.pixelSize: parent.iconSize
                }

            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
                color: root.enabled ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.1)
                opacity: root.enabled ? 1 : 0.2
            }

            IconButton {
                Layout.preferredWidth: 24
                Layout.fillHeight: true
                icon: root.expanded ? "▲" : "▼"
                iconSize: 10
                radius: 0
                iconColor: Theme.colMuted
                useText: false
                isActive: false
                baseColor: root.enabled ? Theme.colBlue : "transparent"
                hoverColor: root.enabled ? Qt.lighter(Theme.colBlue, 1.2) : Theme.colBgLighter
                onClicked: {
                    if (root.enabled)
                        root.expanded = !root.expanded;

                }

                Text {
                    anchors.centerIn: parent
                    text: parent.icon
                    color: root.enabled ? (parent.hovered ? Theme.colFg : Theme.colBg) : Theme.colMuted
                    font.pixelSize: parent.iconSize
                    opacity: root.enabled ? (parent.hovered ? 1 : 0.8) : 0.3

                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                        }

                    }

                }

            }

            layer.effect: Component {
                OpacityMask {

                    maskSource: Rectangle {
                        width: bgRect.width
                        height: bgRect.height
                        radius: 8
                    }

                }

            }

        }

    }

}
