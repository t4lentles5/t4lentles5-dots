import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.Core

TopPopup {
    id: root

    property var currentTrayItem: null

    function openMenu(trayItem) {
        if (!trayItem || !trayItem.menu)
            return ;

        if (currentTrayItem === trayItem && trayMenu.isOpen) {
            trayMenu.isOpen = false;
            currentTrayItem = null;
        } else {
            trayMenu.menuHandle = trayItem.menu;
            trayMenu.isOpen = true;
            currentTrayItem = trayItem;
        }
    }

    implicitWidth: 180 + (root.contentPadding * 2)
    onIsOpenChanged: {
        if (!isOpen) {
            trayMenu.isOpen = false;
            currentTrayItem = null;
        }
    }

    ColumnLayout {
        spacing: Constants.sizeXs

        GridLayout {
            id: gridLayout

            columns: Math.max(1, Math.min(trayRepeater.count, 6))
            columnSpacing: Constants.sizeLg
            rowSpacing: Constants.sizeLg

            Repeater {
                id: trayRepeater

                model: SystemTray.items

                delegate: TrayItem {
                    trayItem: modelData
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            root.isOpen = false;
                        } else if (mouse.button === Qt.RightButton) {
                            if (modelData.menu)
                                root.openMenu(modelData);
                            else if (modelData.secondaryActivate)
                                modelData.secondaryActivate();
                        }
                    }
                }

            }

        }

        TrayMenu {
            id: trayMenu

            isOpen: false
            onIsOpenChanged: {
                if (!isOpen) {
                    trayMenu.menuHandle = null;
                    root.currentTrayItem = null;
                }
            }
        }

    }

}
