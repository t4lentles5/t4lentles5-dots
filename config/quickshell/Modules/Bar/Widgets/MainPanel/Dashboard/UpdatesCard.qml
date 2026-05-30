import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core

Card {
    id: root

    property string pacmanUpdates: "..."
    property string aurUpdates: "..."
    property bool hasUpdates: (parseInt(pacmanUpdates) > 0 || parseInt(aurUpdates) > 0)
    property bool isSystemUpdating: false
    readonly property bool isChecking: pacmanProc.running || aurProc.running
    readonly property bool isUpdating: updateExec.running || isSystemUpdating || AppState.isSystemUpdating

    function runUpdate() {
        AppState.packageManagerMode = "update";
        AppState.openPopup("packagemanager");
    }

    clickable: root.hasUpdates
    highlighted: root.hasUpdates
    scaleOnPress: root.hasUpdates
    cursorShape: root.hasUpdates ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: {
        root.runUpdate();
    }
    implicitWidth: mainLayout.implicitWidth + (Constants.sizeLg * 2)
    implicitHeight: mainLayout.implicitHeight + (Constants.sizeLg * 2)
    Component.onCompleted: {
        checkLockProc.running = true;
    }

    Process {
        id: pacmanProc

        command: ["sh", "-c", "checkupdates | wc -l || echo 0"]

        stdout: SplitParser {
            onRead: (data) => {
                console.log("UpdatesCard: pacmanProc output:", data.trim());
                root.pacmanUpdates = data.trim();
            }
        }

    }

    Process {
        id: aurProc

        command: ["sh", "-c", "yay -Qua | wc -l || echo 0"]

        stdout: SplitParser {
            onRead: (data) => {
                console.log("UpdatesCard: aurProc output:", data.trim());
                root.aurUpdates = data.trim();
            }
        }

    }

    Process {
        id: updateExec

        command: ["sh", "-c", "kitty --class kitty-floating --hold -e yay -Syu --noconfirm"]
        onExited: {
            console.log("UpdatesCard: updateExec exited");
            pacmanProc.running = false;
            pacmanProc.running = true;
            aurProc.running = false;
            aurProc.running = true;
        }
    }

    Process {
        id: checkLockProc

        command: ["test", "-f", "/var/lib/pacman/db.lck"]
        onExited: (code) => {
            root.isSystemUpdating = (code === 0);
        }
    }

    Timer {
        id: lockCheckTimer

        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            checkLockProc.running = true;
        }
    }

    Timer {
        id: hourlyUpdateTimer

        interval: 3.6e+06
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            console.log("UpdatesCard: hourly update trigger");
            pacmanProc.running = false;
            pacmanProc.running = true;
            aurProc.running = false;
            aurProc.running = true;
        }
    }

    Connections {
        function onActivePopupChanged() {
            console.log("UpdatesCard: onActivePopupChanged:", AppState.activePopup);
            if (AppState.activePopup === "" && !AppState.isSystemUpdating) {
                console.log("UpdatesCard: activePopup closed, triggering check");
                pacmanProc.running = false;
                pacmanProc.running = true;
                aurProc.running = false;
                aurProc.running = true;
            }
        }

        function onIsSystemUpdatingChanged() {
            console.log("UpdatesCard: onIsSystemUpdatingChanged:", AppState.isSystemUpdating);
            if (!AppState.isSystemUpdating) {
                console.log("UpdatesCard: isSystemUpdating finished, starting delay timer");
                root.pacmanUpdates = "...";
                root.aurUpdates = "...";
                checkDelayTimer.start();
            }
        }

        target: AppState
    }

    Timer {
        id: checkDelayTimer

        interval: 800
        repeat: false
        onTriggered: {
            console.log("UpdatesCard: checkDelayTimer triggered, starting checks");
            pacmanProc.running = false;
            pacmanProc.running = true;
            aurProc.running = false;
            aurProc.running = true;
        }
    }

    RowLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.margins: Constants.sizeLg
        spacing: Constants.sizeLg

        Item {
            id: iconContainer

            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.fill: parent
                radius: 24
                color: Theme.bg
                opacity: 0.5
            }

            ThemedText {
                id: statusIcon

                anchors.centerIn: parent
                text: {
                    if (root.isUpdating || root.isChecking)
                        return "󰑐";

                    return root.hasUpdates ? "󰚰" : "󰄬";
                }
                font.pixelSize: 24
                color: {
                    if (root.isUpdating)
                        return Theme.yellow;

                    if (root.isChecking)
                        return Theme.muted;

                    return root.hasUpdates ? Theme.purple : Theme.green;
                }

                RotationAnimation on rotation {
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: root.isUpdating || root.isChecking
                    onRunningChanged: {
                        if (!running)
                            statusIcon.rotation = 0;

                    }
                }

            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: Constants.sizeXs

            ThemedText {
                text: root.hasUpdates ? "System Updates" : "System Status"
                font.pixelSize: Constants.sizeSm
                color: Theme.muted
                Layout.fillWidth: true
            }

            ThemedText {
                text: {
                    if (root.isUpdating)
                        return "Updating...";

                    if (root.isChecking)
                        return "Checking...";

                    if (root.pacmanUpdates === "..." || root.aurUpdates === "...")
                        return "Checking...";

                    let total = (parseInt(root.pacmanUpdates) || 0) + (parseInt(root.aurUpdates) || 0);
                    return total > 0 ? total + " updates" : "Up to date";
                }
                font.pixelSize: Constants.sizeSm
                font.weight: Font.Bold
                color: root.isUpdating ? Theme.yellow : (root.hasUpdates ? Theme.purple : Theme.green)
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

        }

    }

}
