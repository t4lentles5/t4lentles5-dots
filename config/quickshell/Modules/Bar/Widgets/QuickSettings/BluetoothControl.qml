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
    property var _tempBtList: []

    function toggle() {
        btSetProc.command = ["bluetoothctl", "power", root.isActive ? "off" : "on"];
        btSetProc.running = true;
        btNotifyProc.command = ["notify-send", "-a", "System", "-i", Constants.iconPath.replace("file://", "") + (root.isActive ? "preferences-system-bluetooth-inactive.svg" : "preferences-system-bluetooth-active.svg"), "Bluetooth", root.isActive ? "Disabled" : "Enabled", "-t", "1500"];
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
            btDiscoveryProc.running = true;
            scan();
        } else {
            btDiscoveryProc.running = false;
        }
    }
    onIsActiveChanged: {
        if (expanded && isActive) {
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
                hoverColor: root.isActive ? Theme.blue : Theme.muted
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
                hoverColor: Theme.purple
                visible: root.isActive
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
