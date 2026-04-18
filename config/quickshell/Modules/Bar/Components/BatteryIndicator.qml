import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

BarButton {
    id: root

    property int batteryLevel: 0
    property string batteryStatus: "Discharging"
    property bool hasBattery: false
    property string batPath: ""
    property var notificationService
    property string _prevStatus: ""
    property int _prevLevel: -1
    property color activeColor: {
        if (root.batteryStatus === "Charging")
            return Theme.green;

        if (root.batteryLevel < 20)
            return Theme.red;

        return Theme.yellow;
    }

    onBatteryStatusChanged: {
        if (batteryStatus === "" || batteryStatus === _prevStatus)
            return ;

        if (_prevStatus !== "") {
            let summary = "Battery";
            let body = "";
            let icon = "";
            if (batteryStatus === "Charging") {
                summary = "Battery";
                body = "Charger connected";
                icon = Constants.iconPath + "battery-good-charging.svg";
            } else if (batteryStatus === "Discharging") {
                summary = "Battery";
                body = "Charger disconnected";
                icon = Constants.iconPath + "battery-good.svg";
            } else if (batteryStatus === "Full") {
                summary = "Battery";
                body = "Battery fully charged";
                icon = Constants.iconPath + "battery-full.svg";
            }
            if (body !== "" && notificationService)
                notificationService.notify(summary, body, icon);

        }
        _prevStatus = batteryStatus;
    }
    onBatteryLevelChanged: {
        if (batteryLevel <= 0 || batteryLevel === _prevLevel)
            return ;

        if (_prevLevel !== -1 && batteryStatus === "Discharging") {
            let threshold = 0;
            if (batteryLevel <= 5 && _prevLevel > 5)
                threshold = 5;
            else if (batteryLevel <= 10 && _prevLevel > 10)
                threshold = 10;
            else if (batteryLevel <= 20 && _prevLevel > 20)
                threshold = 20;
            if (threshold > 0 && notificationService)
                notificationService.notify("Low Battery", "Battery level: " + batteryLevel + "%", Constants.iconPath + "battery-caution.svg");

        }
        _prevLevel = batteryLevel;
    }
    isButton: false
    visible: hasBattery && batPath !== ""
    implicitWidth: mainRow.implicitWidth + 24
    Component.onCompleted: findBattery.running = true
    text: ""

    Process {
        id: findBattery

        command: ["sh", "-c", "ls /sys/class/power_supply/ | grep -E 'BAT|battery' | head -n 1"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim() !== "") {
                    root.batPath = "/sys/class/power_supply/" + data.trim();
                    updateTimer.start();
                    udevMonitor.running = true;
                }
            }
        }

    }

    Process {
        id: udevMonitor

        running: false
        command: ["stdbuf", "-oL", "udevadm", "monitor", "-k", "-s", "power_supply"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data && root.batPath !== "") {
                    batLevelProc.running = true;
                    batStatusProc.running = true;
                }
            }
        }

    }

    Timer {
        id: updateTimer

        interval: 10000
        running: false
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.batPath !== "") {
                batLevelProc.running = true;
                batStatusProc.running = true;
            }
        }
    }

    Process {
        id: batLevelProc

        command: ["cat", root.batPath + "/capacity"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data) {
                    root.batteryLevel = parseInt(data.trim()) || 0;
                    root.hasBattery = true;
                }
            }
        }

    }

    Process {
        id: batStatusProc

        command: ["cat", root.batPath + "/status"]

        stdout: SplitParser {
            onRead: (data) => {
                if (data)
                    root.batteryStatus = data.trim();

            }
        }

    }

    RowLayout {
        id: mainRow

        anchors.centerIn: parent
        spacing: Constants.sizeXs

        ThemedText {
            id: batIcon

            text: {
                if (root.batteryStatus === "Charging")
                    return "󰂄";

                if (root.batteryLevel >= 90)
                    return "󰁹";

                if (root.batteryLevel >= 70)
                    return "󰂁";

                if (root.batteryLevel >= 50)
                    return "󰁾";

                if (root.batteryLevel >= 30)
                    return "󰁼";

                if (root.batteryLevel >= 10)
                    return "󰁺";

                return "󰂃";
            }
            color: root.activeColor

            SequentialAnimation on opacity {
                id: breathAnim

                loops: Animation.Infinite
                running: root.batteryStatus === "Charging"
                onRunningChanged: {
                    if (!running)
                        batIcon.opacity = 1;

                }

                NumberAnimation {
                    to: 0.4
                    duration: 1000
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    to: 1
                    duration: 1000
                    easing.type: Easing.InOutSine
                }

            }

        }

        ThemedText {
            text: root.batteryLevel + "%"
            color: root.activeColor
            font.bold: true
            visible: root.batteryLevel > 0
        }

    }

    Behavior on activeColor {
        ColorAnimation {
            duration: Constants.animSlow
            easing.type: Easing.OutQuint
        }

    }

}
