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
    property var wifiList: []
    property var _tempWifiList: []

    function toggle() {
        wifiSetProc.command = ["nmcli", "radio", "wifi", root.enabled ? "off" : "on"];
        wifiSetProc.running = true;
        root.enabled = !root.enabled;
    }

    function scan() {
        if (root.expanded)
            wifiScanProc.running = true;

    }

    function connect(ssid) {
        wifiConnectProc.command = ["nmcli", "device", "wifi", "connect", ssid];
        wifiConnectProc.running = true;
    }

    onEnabledChanged: {
        if (!enabled)
            expanded = false;

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
                    root.enabled = (data.trim() === "enabled");

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
                icon: root.enabled ? "󰤨" : "󰤭"
                iconSize: Constants.sizeXl
                iconColor: root.enabled ? Colors.purple : Colors.muted
                hoverColor: root.enabled ? Colors.purple : Colors.muted
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
