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
        Layout.preferredWidth: 88
        Layout.fillWidth: true
        Layout.preferredHeight: rowLayout.implicitHeight

        Rectangle {
            id: bgRect

            anchors.fill: parent
            radius: Constants.sizeLg
            color: Colors.bgSecondary
        }

        RowLayout {
            id: rowLayout

            anchors.fill: parent
            spacing: 0
            layer.enabled: true

            IconButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: root.enabled ? "󰂯" : "󰂲"
                iconSize: Constants.sizeXl
                iconColor: root.enabled ? Colors.blue : Colors.muted
                hoverColor: root.enabled ? Colors.blue : Colors.muted
                bgColor: "transparent"
                onClicked: root.toggle()
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                Layout.topMargin: Constants.sizeXs
                Layout.bottomMargin: Constants.sizeXs
                color: Colors.muted
                opacity: 0.3
                visible: root.enabled
            }

            IconButton {
                icon: root.expanded ? "" : ""
                iconSize: Constants.sizeMd
                hoverColor: Colors.purple
                visible: root.enabled
                bgColor: "transparent"
                onClicked: {
                    if (root.enabled)
                        root.expanded = !root.expanded;

                }
            }

            layer.effect: Component {
                OpacityMask {

                    maskSource: Rectangle {
                        width: bgRect.width
                        height: bgRect.height
                        radius: Constants.sizeLg
                    }

                }

            }

        }

    }

}
