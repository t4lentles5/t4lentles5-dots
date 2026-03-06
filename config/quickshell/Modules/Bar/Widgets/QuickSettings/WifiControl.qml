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

    spacing: 2
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
        Layout.preferredWidth: 84
        Layout.preferredHeight: 40

        Rectangle {
            id: bgRect

            anchors.fill: parent
            radius: Theme.radiusSm
            color: root.enabled ? Theme.colPurple : Theme.colBg
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0
            layer.enabled: true

            IconButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "󰤨"
                iconSize: 20
                radius: 0
                iconColor: Theme.colFg
                useText: false
                isActive: false
                baseColor: root.enabled ? Theme.colPurple : "transparent"
                hoverColor: root.enabled ? Qt.lighter(Theme.colPurple, 1.2) : Theme.colBgLighter
                onClicked: root.toggle()

                ThemedText {
                    anchors.centerIn: parent
                    text: parent.icon
                    color: root.enabled ? Theme.colBg : Theme.colFg
                    font.pixelSize: parent.iconSize
                }

            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                Layout.topMargin: Theme.spacingSm
                Layout.bottomMargin: Theme.spacingSm
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
                baseColor: root.enabled ? Theme.colPurple : "transparent"
                hoverColor: root.enabled ? Qt.lighter(Theme.colPurple, 1.2) : Theme.colBgLighter
                onClicked: {
                    if (root.enabled)
                        root.expanded = !root.expanded;

                }

                ThemedText {
                    anchors.centerIn: parent
                    text: parent.icon
                    color: root.enabled ? (parent.hovered ? Theme.colFg : Theme.colBg) : Theme.colMuted
                    font.pixelSize: parent.iconSize
                    opacity: root.enabled ? (parent.hovered ? 1 : 0.8) : 0.3

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animSlow
                        }

                    }

                }

            }

            layer.effect: Component {
                OpacityMask {

                    maskSource: Rectangle {
                        width: bgRect.width
                        height: bgRect.height
                        radius: Theme.radiusSm
                    }

                }

            }

        }

    }

}
