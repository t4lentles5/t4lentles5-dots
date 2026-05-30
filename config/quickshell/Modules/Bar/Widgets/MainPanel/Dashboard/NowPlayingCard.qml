import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.Core

Card {
    id: root

    property var managedPlayers: []
    property var activePlayer: null
    property var widget: null
    property bool hasYoutubeMusic: false
    property bool hasSpotify: false

    function isPlayerRunning(name) {
        for (let i = 0; i < root.managedPlayers.length; i++) {
            let p = root.managedPlayers[i];
            if (!p)
                continue;

            let id = (p.identity || "").toLowerCase();
            if (id.includes(name))
                return true;

        }
        return false;
    }

    function updatePlayer() {
        let players = managedPlayers;
        let selected = null;
        let playing = null;
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            if (!p)
                continue;

            let id = (p.identity || "").toLowerCase();
            if (!id.includes("brave") && (id.includes("spotify") || id.includes("youtube"))) {
                let isPlaying = (p.playbackState === 1 || p.playbackState === Mpris.Playing || String(p.playbackState).toLowerCase().includes("playing"));
                if (isPlaying) {
                    playing = p;
                    break;
                }
                if (!selected)
                    selected = p;

            }
        }
        let newPlayer = playing || selected || null;
        if (root.activePlayer !== newPlayer)
            root.activePlayer = newPlayer;

    }

    function registerPlayer(p) {
        let list = managedPlayers;
        if (list.indexOf(p) === -1) {
            list.push(p);
            managedPlayers = list;
            updatePlayer();
        }
    }

    function unregisterPlayer(p) {
        let list = managedPlayers;
        let index = list.indexOf(p);
        if (index !== -1) {
            list.splice(index, 1);
            managedPlayers = list;
            updatePlayer();
        }
    }

    implicitWidth: mainLayout.implicitWidth + (Constants.sizeLg * 2)
    implicitHeight: mainLayout.implicitHeight + (Constants.sizeLg * 2)

    Process {
        command: ["sh", "-c", "which youtube-music"]
        running: true
        onExited: (code) => {
            root.hasYoutubeMusic = (code === 0);
        }
    }

    Process {
        command: ["sh", "-c", "which spotify"]
        running: true
        onExited: (code) => {
            root.hasSpotify = (code === 0);
        }
    }

    Instantiator {
        model: Mpris.players

        delegate: QtObject {
            property var p: modelData
            property var state: p.playbackState
            property var title: p.trackTitle

            onStateChanged: root.updatePlayer()
            onTitleChanged: root.updatePlayer()
            Component.onCompleted: root.registerPlayer(p)
            Component.onDestruction: root.unregisterPlayer(p)
        }

    }

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.margins: Constants.sizeLg
        spacing: Constants.sizeXs

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 110

            Rectangle {
                id: artContainer

                anchors.centerIn: parent
                width: 110
                height: 110
                radius: width / 2
                color: Theme.bg
                border.width: 1
                border.color: Theme.border
            }

            Image {
                id: albumArt

                anchors.fill: artContainer
                anchors.margins: 1
                source: root.activePlayer ? (root.activePlayer.trackArtUrl || "") : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                opacity: status === Image.Ready ? 1 : 0
                visible: false

                Behavior on opacity {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }

                }

            }

            Rectangle {
                id: artMask

                anchors.fill: artContainer
                radius: width / 2
                color: "white"
                visible: false
            }

            OpacityMask {
                anchors.fill: artContainer
                source: albumArt
                maskSource: artMask
            }

            ThemedText {
                anchors.centerIn: artContainer
                text: ""
                color: Theme.purple
                font.pixelSize: 36
                visible: albumArt.status !== Image.Ready
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            ThemedText {
                text: root.activePlayer ? (root.activePlayer.trackTitle || "Not Playing") : "No Music"
                font.pixelSize: Constants.sizeSm
                font.weight: Font.Bold
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            ThemedText {
                text: root.activePlayer ? (root.activePlayer.trackArtist || "Unknown") : "—"
                color: Theme.muted
                font.pixelSize: Constants.sizeSm - 1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Constants.sizeXs

            IconButton {
                icon: "󰒮"
                iconSize: Constants.sizeLg
                iconColor: (root.activePlayer && root.activePlayer.canGoPrevious) ? Theme.fg : Theme.muted
                bgColor: "transparent"
                onClicked: {
                    if (root.activePlayer)
                        root.activePlayer.previous();

                }
            }

            IconButton {
                id: playButton

                property bool isPlaying: root.activePlayer && (root.activePlayer.playbackState === 1 || root.activePlayer.playbackState === Mpris.Playing || String(root.activePlayer.playbackState).toLowerCase().includes("playing"))

                icon: (root.activePlayer && playButton.isPlaying) ? "󰏤" : "󰐊"
                iconSize: Constants.sizeLg
                iconColor: Theme.bg
                bgColor: Theme.purple
                onClicked: {
                    if (root.activePlayer)
                        root.activePlayer.togglePlaying();

                }
            }

            IconButton {
                icon: "󰒭"
                iconSize: Constants.sizeLg
                iconColor: (root.activePlayer && root.activePlayer.canGoNext) ? Theme.fg : Theme.muted
                bgColor: "transparent"
                onClicked: {
                    if (root.activePlayer)
                        root.activePlayer.next();

                }
            }

        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Constants.sizeMd

            IconButton {
                icon: "󰗃"
                iconSize: Constants.sizeMd
                iconColor: Theme.red
                bgColor: Theme.bg
                visible: root.hasYoutubeMusic
                onClicked: {
                    if (root.isPlayerRunning("youtube"))
                        Hyprland.dispatch("exec killall -9 youtube-music");
                    else
                        Hyprland.dispatch("exec youtube-music");
                }
            }

            IconButton {
                icon: "󰓇"
                iconSize: Constants.sizeMd
                iconColor: Theme.green
                bgColor: Theme.bg
                visible: root.hasSpotify
                onClicked: {
                    if (root.isPlayerRunning("spotify"))
                        Hyprland.dispatch("exec killall -9 spotify");
                    else
                        Hyprland.dispatch("exec spotify");
                }
            }

            IconButton {
                icon: "󱂬"
                iconSize: Constants.sizeMd
                iconColor: Theme.cyan
                bgColor: Theme.bg
                onClicked: Hyprland.dispatch("workspace 9")
            }

        }

    }

}
