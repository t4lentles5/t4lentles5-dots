import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

TopPopup {
    id: root

    property bool quickSettingsOpen: false

    onPopupClosed: {
        wifiControl.expanded = false;
        btControl.expanded = false;
    }

    implicitWidth: mainCol.implicitWidth + Constants.sizeLg * 2
    implicitHeight: mainCol.implicitHeight + Constants.sizeLg * 2

    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: availableWidth
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: mainCol

            width: parent.width
            spacing: Constants.sizeLg

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Constants.sizeLg

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Constants.sizeLg

                    WifiControl {
                        id: wifiControl

                        onExpandedChanged: {
                            if (expanded)
                                btControl.expanded = false;

                        }
                    }

                    BluetoothControl {
                        id: btControl

                        onExpandedChanged: {
                            if (expanded)
                                wifiControl.expanded = false;

                        }
                    }

                    NightLightControl {
                    }

                    VolumeControl {
                        id: volControl
                    }

                    MicControl {
                    }

                    ColorPickerControl {
                        onRequestClose: root.controlCenterOpen = false
                    }

                }

            }

            WifiList {
                Layout.fillWidth: true
                expanded: wifiControl.expanded
                enabled: wifiControl.enabled
                wifiList: wifiControl.wifiList
                onConnect: (ssid) => {
                    return wifiControl.connect(ssid);
                }
            }

            BluetoothList {
                Layout.fillWidth: true
                expanded: btControl.expanded
                enabled: btControl.enabled
                btList: btControl.btList
                onConnect: (mac) => {
                    return btControl.connect(mac);
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: sliderCol.implicitHeight + (Constants.sizeLg * 2)
                color: Colors.bgSecondary
                radius: Constants.sizeXs

                ColumnLayout {
                    id: sliderCol

                    anchors.fill: parent
                    anchors.margins: Constants.sizeLg
                    spacing: Constants.sizeLg

                    VolumeSlider {
                        Layout.fillWidth: true
                        volume: volControl.volume
                        muted: volControl.muted
                        onMoved: (val) => {
                            return volControl.setVolume(val);
                        }
                    }

                    BrightnessSlider {
                        Layout.fillWidth: true
                    }

                }

            }

        }

    }

}
