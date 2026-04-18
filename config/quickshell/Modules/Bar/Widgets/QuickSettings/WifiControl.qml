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
    property var wifiList: []
    property var _tempWifiList: []

    function toggle() {
        wifiSetProc.command = ["nmcli", "radio", "wifi", root.isActive ? "off" : "on"];
        wifiSetProc.running = true;
        wifiNotifyProc.command = ["notify-send", "-a", "System", "-i", Constants.iconPath.replace("file://", "") + (root.isActive ? "network-wireless-disconnected.svg" : "network-wireless-connected.svg"), "Wi-Fi", root.isActive ? "Disabled" : "Enabled", "-t", "1500"];
        wifiNotifyProc.running = true;
        root.isActive = !root.isActive;
    }

    function scan() {
        if (root.expanded)
            wifiScanProc.running = true;

    }

    function connect(ssid) {
        wifiConnectProc.command = ["nmcli", "device", "wifi", "connect", ssid];
        wifiConnectProc.running = true;
    }

    onIsActiveChanged: {
        if (!isActive)
            expanded = false;

    }

    Process {
        id: wifiNotifyProc
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            wifiGetProc.running = true;
            if (root.expanded)
                scan();

        }
    }

    Process {
        id: wifiGetProc

        command: ["nmcli", "radio", "wifi"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    root.isActive = (data.trim() === "enabled");

            }
        }

    }

    Process {
        id: wifiSetProc
    }

    Process {
        id: wifiScanProc

        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,IN-USE", "device", "wifi", "list"]
        onRunningChanged: {
            if (running)
                root._tempWifiList = [];
            else
                root.wifiList = root._tempWifiList;
        }

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                let parts = data.split(":");
                if (parts.length < 3)
                    return ;

                let inUse = parts[2] === "*";
                let ssid = parts[0];
                let signal = parseInt(parts[1]);
                if (!ssid)
                    return ;

                let list = root._tempWifiList;
                let exists = false;
                for (let i = 0; i < list.length; i++) {
                    if (list[i].ssid === ssid) {
                        exists = true;
                        break;
                    }
                }
                if (!exists) {
                    list.push({
                        "ssid": ssid,
                        "signal": signal,
                        "active": inUse
                    });
                    root._tempWifiList = list;
                }
            }
        }

    }

    Process {
        id: wifiConnectProc
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
                icon: root.isActive ? "󰤨" : "󰤭"
                iconSize: Constants.sizeXl
                iconColor: root.isActive ? Theme.purple : Theme.muted
                hoverColor: root.isActive ? Theme.purple : Theme.muted
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
