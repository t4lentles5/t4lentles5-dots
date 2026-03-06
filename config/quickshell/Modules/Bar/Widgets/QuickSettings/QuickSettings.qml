import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

TopPopup {
    id: root

    implicitWidth: 450
    preferredHeight: Math.min(mainCol.implicitHeight + (root.contentPadding * 2), 650)
    animateHeight: true
    onPopupClosed: {
        wifiControl.expanded = false;
        btControl.expanded = false;
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
            spacing: Theme.spacingLg

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingLg

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    color: Theme.colBgSecondary
                    radius: Theme.radiusSm

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingLg
                        anchors.rightMargin: Theme.spacingLg

                        RowLayout {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            spacing: Theme.spacingLg

                            WifiControl {
                                id: wifiControl
                            }

                            BluetoothControl {
                                id: btControl
                            }

                        }

                        RowLayout {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            spacing: Theme.spacingLg

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
                Layout.preferredHeight: slidersCol.implicitHeight + 36
                color: Theme.colBgSecondary
                radius: Theme.radiusSm

                ColumnLayout {
                    id: slidersCol

                    anchors.centerIn: parent
                    width: parent.width - 32
                    spacing: 20

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

        }

    }

}
