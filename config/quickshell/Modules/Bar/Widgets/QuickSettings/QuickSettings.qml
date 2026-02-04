import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

TopPopup {
    id: root

    property bool micMuted: false
    property bool nightLightActive: false

    implicitWidth: 450
    preferredHeight: Math.min(mainCol.implicitHeight + (root.contentPadding * 2), 650)
    onIsOpenChanged: {
        if (!isOpen) {
            wifiControl.expanded = false;
            btControl.expanded = false;
            screenshotControl.expanded = false;
        }
    }
    Component.onCompleted: micCheckProc.running = true

    Process {
        id: colorPickerProc

        command: ["sh", "-c", "hyprpicker -a"]
    }

    Process {
        id: micCheckProc

        command: ["sh", "-c", "pamixer --default-source --get-mute"]

        stdout: SplitParser {
            onRead: (data) => {
                const val = data.trim();
                if (val !== "")
                    micMuted = (val === "true");

            }
        }

    }

    Process {
        id: micToggleProc

        command: ["sh", "-c", "pamixer --default-source -t"]
        onExited: (code) => {
            if (code === 0) {
                micCheckProc.running = false;
                micCheckProc.running = true;
            }
        }
    }

    Process {
        id: nightLightProc

        command: ["sh", "-c", "pkill hyprsunset; if [ \"$1\" = \"true\" ]; then hyprsunset -t 4500 & fi", "--", String(nightLightActive)]
    }

    Timer {
        id: colorPickerTimer

        interval: 400
        repeat: false
        onTriggered: {
            colorPickerProc.running = false;
            colorPickerProc.running = true;
        }
    }

    ScrollView {
        id: scrollView

        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: availableWidth
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: mainCol

            width: scrollView.availableWidth
            spacing: 16

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Theme.colBgSecondary
                        radius: 16

                        WifiControl {
                            id: wifiControl

                            anchors.centerIn: parent
                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Theme.colBgSecondary
                        radius: 16

                        BluetoothControl {
                            id: btControl

                            anchors.centerIn: parent
                        }

                    }

                }

                WifiList {
                    expanded: wifiControl.expanded
                    enabled: wifiControl.enabled
                    wifiList: wifiControl.wifiList
                    onConnect: (ssid) => {
                        return wifiControl.connect(ssid);
                    }
                }

                BluetoothList {
                    expanded: btControl.expanded
                    enabled: btControl.enabled
                    btList: btControl.btList
                    onConnect: (mac) => {
                        return btControl.connect(mac);
                    }
                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: slidersCol.implicitHeight + 32
                color: Theme.colBgSecondary
                radius: 16

                ColumnLayout {
                    id: slidersCol

                    anchors.centerIn: parent
                    width: parent.width - 32
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        VolumeControl {
                            id: volControl
                        }

                        VolumeSlider {
                            Layout.fillWidth: true
                            volume: volControl.volume
                            onMoved: (val) => {
                                return volControl.setVolume(val);
                            }
                        }

                    }

                    BrightnessControl {
                        id: brightControl

                        Layout.fillWidth: true
                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: Theme.colBgSecondary
                radius: 16

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 20

                    ScreenshotControl {
                        id: screenshotControl

                        onCloseRequested: root.isOpen = false
                    }

                    Rectangle {
                        id: nlBtn

                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: nightLightActive ? Theme.colYellow : (nlHover.hovered ? Theme.colBgLighter : Theme.colBg)

                        HoverHandler {
                            id: nlHover

                            enabled: !nightLightActive
                        }

                        Text {
                            anchors.centerIn: parent
                            text: nightLightActive ? "󰖔" : "󰖙"
                            color: nightLightActive ? Theme.colBg : Theme.colFg
                            font.family: Theme.fontFamily
                            font.pixelSize: 20
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                nightLightActive = !nightLightActive;
                                if (nightLightActive)
                                    nightLightProc.command = ["sh", "-c", "hyprsunset -t 4500"];
                                else
                                    nightLightProc.command = ["pkill", "hyprsunset"];
                                nightLightProc.running = false;
                                nightLightProc.running = true;
                            }
                        }

                    }

                    Rectangle {
                        id: micBtn

                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: micMuted ? Theme.colRed : (micHover.hovered ? Theme.colBgLighter : Theme.colBg)

                        HoverHandler {
                            id: micHover

                            enabled: !micMuted
                        }

                        Text {
                            anchors.centerIn: parent
                            text: micMuted ? "󰍭" : "󰍬"
                            color: micMuted ? Theme.colBg : Theme.colCyan
                            font.family: Theme.fontFamily
                            font.pixelSize: 20
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                micToggleProc.running = false;
                                micToggleProc.running = true;
                            }
                        }

                    }

                    Rectangle {
                        id: cpBtn

                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: cpHover.hovered ? Theme.colBgLighter : Theme.colBg

                        HoverHandler {
                            id: cpHover
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰈋"
                            color: Theme.colCyan
                            font.family: Theme.fontFamily
                            font.pixelSize: 20
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.isOpen = false;
                                colorPickerTimer.start();
                            }
                        }

                    }

                    Rectangle {
                        id: todoBtn

                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: todoHover.hovered ? Theme.colBgLighter : Theme.colBg

                        HoverHandler {
                            id: todoHover
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰄲"
                            color: Theme.colCyan
                            font.family: Theme.fontFamily
                            font.pixelSize: 20
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                        }

                    }

                    WallpaperControl {
                        id: wallControl
                    }

                }

            }

            ScreenshotOptions {
                expanded: screenshotControl.expanded
                onCapture: (mode) => {
                    return screenshotControl.capture(mode);
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                color: Theme.colBgSecondary
                radius: 16

                BatteryControl {
                    id: batteryControl

                    anchors.fill: parent
                }

            }

        }

    }

}
