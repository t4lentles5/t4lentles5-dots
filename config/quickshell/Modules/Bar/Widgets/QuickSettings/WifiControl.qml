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

    Rectangle {
        Layout.preferredWidth: root.enabled ? 84 : 44
        Layout.preferredHeight: 40
        radius: 20
        color: root.enabled ? Theme.colPurple : (wifiHover.hovered ? Theme.colBgLighter : Theme.colBgSecondary)
        clip: true

        HoverHandler {
            id: wifiHover

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
                    text: "󰤨"
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
