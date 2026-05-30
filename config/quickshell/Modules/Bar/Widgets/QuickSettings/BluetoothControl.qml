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
    property bool isActive: false
    property var btList: []

    function addOrUpdateDevice(mac, name) {
        let list = root.btList;
        let found = false;
        let cleanName = name ? name.trim() : "";
        if (!cleanName || cleanName === "Unknown Device")
            cleanName = mac;

        for (let i = 0; i < list.length; i++) {
            if (list[i].mac === mac) {
                found = true;
                if (cleanName && cleanName !== mac && list[i].name !== cleanName) {
                    list[i].name = cleanName;
                    root.btList = list.slice();
                }
                break;
            }
        }
        if (!found) {
            list.push({
                "name": cleanName,
                "mac": mac
            });
            root.btList = list.slice();
        }
    }

    function removeDevice(mac) {
        let list = root.btList;
        for (let i = 0; i < list.length; i++) {
            if (list[i].mac === mac) {
                list.splice(i, 1);
                root.btList = list.slice();
                break;
            }
        }
    }

    function toggle() {
        btSetProc.command = ["bluetoothctl", "power", root.isActive ? "off" : "on"];
        btSetProc.running = true;
        btNotifyProc.command = ["notify-send", "-a", "System", "-i", root.isActive ? "preferences-system-bluetooth-inactive" : "preferences-system-bluetooth-active", "Bluetooth", root.isActive ? "Disabled" : "Enabled", "-t", "1500"];
        btNotifyProc.running = true;
        root.isActive = !root.isActive;
    }

    function scan() {
        if (root.expanded && root.isActive) {
            if (!btScanProc.running)
                btScanProc.running = true;

        }
    }

    function connect(mac) {
        btConnectProc.command = ["bluetoothctl", "connect", mac];
        btConnectProc.running = true;
    }

    onExpandedChanged: {
        if (expanded && isActive) {
            root.btList = [];
            if (!btDiscoveryProc.running)
                btDiscoveryProc.running = true;

            scan();
        } else {
            btDiscoveryProc.running = false;
        }
    }
    onIsActiveChanged: {
        if (expanded && isActive) {
            root.btList = [];
            if (!btDiscoveryProc.running)
                btDiscoveryProc.running = true;

            scan();
        } else {
            btDiscoveryProc.running = false;
        }
        if (!isActive)
            expanded = false;

    }

    Process {
        id: btNotifyProc
    }

    Timer {
        id: updateTimer

        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            btGetProc.running = true;
        }
    }

    Process {
        id: btGetProc

        command: ["bluetoothctl", "show"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                let cleanData = data.replace(/\u001b\[[0-9;]*m/g, "").trim();
                if (cleanData.includes("Powered: yes"))
                    root.isActive = true;
                else if (cleanData.includes("Powered: no"))
                    root.isActive = false;
            }
        }

    }

    Process {
        id: btSetProc
    }

    Process {
        id: btDiscoveryProc

        command: ["bluetoothctl", "scan", "on"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                let line = data.replace(/\u001b\[[0-9;]*m/g, "").trim();
                if (line.includes("[CHG]")) {
                    let matchName = line.match(/\[CHG\]\s+Device\s+([0-9A-F:]{17})\s+(?:Name|Alias):\s+(.*)$/i);
                    if (matchName) {
                        root.addOrUpdateDevice(matchName[1], matchName[2]);
                    } else {
                        let matchConn = line.match(/\[CHG\]\s+Device\s+([0-9A-F:]{17})\s+Connected:\s+no/i);
                        if (matchConn)
                            root.removeDevice(matchConn[1]);

                    }
                } else if (line.includes("[DEL]")) {
                    let match = line.match(/\[DEL\]\s+Device\s+([0-9A-F:]{17})/i);
                    if (match)
                        root.removeDevice(match[1]);

                } else if (line.includes("[NEW]") || line.startsWith("Device ")) {
                    let match = line.match(/(?:\[NEW\]\s+)?Device\s+([0-9A-F:]{17})\s*(.*)$/i);
                    if (match) {
                        let mac = match[1];
                        let name = match[2].trim() || "Unknown Device";
                        if (!name.startsWith("RSSI:") && !name.startsWith("TxPower:") && !name.startsWith("Connected:") && !name.startsWith("UUIDs:"))
                            root.addOrUpdateDevice(mac, name);

                    }
                }
            }
        }

    }

    Process {
        id: btScanProc

        command: ["bluetoothctl", "devices", "Connected"]

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
                root.addOrUpdateDevice(mac, name);
            }
        }

    }

    Process {
        id: btConnectProc

        onRunningChanged: {
            if (!running)
                btScanProc.running = true;

        }
    }

    Item {
        Layout.preferredWidth: 88
        Layout.fillWidth: true
        Layout.preferredHeight: rowLayout.implicitHeight

        Rectangle {
            id: bgRect

            anchors.fill: parent
            radius: Constants.sizeLg
            color: Theme.bgSecondary
        }

        RowLayout {
            id: rowLayout

            anchors.fill: parent
            spacing: 0
            layer.enabled: true

            IconButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: root.isActive ? "󰂯" : "󰂲"
                iconSize: Constants.sizeXl
                iconColor: root.isActive ? Theme.blue : Theme.muted
                hoverColor: "transparent"
                bgColor: "transparent"
                onClicked: root.toggle()
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                Layout.topMargin: Constants.sizeXs
                Layout.bottomMargin: Constants.sizeXs
                color: Theme.muted
                opacity: 0.3
                visible: root.isActive
            }

            IconButton {
                icon: root.expanded ? "" : ""
                iconSize: Constants.sizeMd
                visible: root.isActive
                hoverColor: "transparent"
                bgColor: "transparent"
                onClicked: {
                    if (root.isActive)
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
