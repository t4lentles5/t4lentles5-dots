import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

TopPopup {
    id: root

    implicitWidth: 450
    preferredHeight: Math.min(mainCol.implicitHeight + (root.contentPadding * 2), 650)
    onIsOpenChanged: {
        if (!isOpen) {
            wifiControl.expanded = false;
            btControl.expanded = false;
            screenshotControl.expanded = false;
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
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    spacing: 16

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
                        spacing: 16

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

                    NightLightControl {
                        id: nlControl
                    }

                    MicControl {
                        id: micControl
                    }

                    ColorPickerControl {
                        id: cpControl

                        onRequestClose: root.isOpen = false
                    }

                    QuickActionButton {
                        id: todoBtn

                        icon: "󰄲"
                        iconColor: Theme.colGreen
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

        }

    }

    Behavior on preferredHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }

    }

}
