import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.Core

TopPopup {
    id: root

    property var managedPlayers: []
    property var activePlayer: null
    property real position: 0
    property bool isSliderPressed: false
    property string currentTrackId: ""

    function updatePlayer() {
        let players = managedPlayers;
        let selected = null;
        let playing = null;
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            if (!p)
                continue;

            let id = (p.identity || "").toLowerCase();
            if (id.includes("spotify") || id.includes("youtube") || id.includes("music")) {
                let isPlaying = (p.playbackState === 1 || p.playbackState === Mpris.Playing || String(p.playbackState).toLowerCase().includes("playing"));
                if (isPlaying) {
                    playing = p;
                    break;
                }
                if (!selected)
                    selected = p;

            }
        }
        let newPlayer = playing || selected || (players.length > 0 ? players[0] : null);
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

    implicitWidth: 360

    Timer {
        interval: 100
        running: {
            if (!root.activePlayer)
                return false;

            let s = root.activePlayer.playbackState;
            return s === 1 || s === Mpris.Playing || String(s).toLowerCase().includes("playing");
        }
        repeat: true
        onTriggered: {
            if (root.activePlayer && !root.isSliderPressed)
                root.position += 0.1;

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

    RowLayout {
        id: rowLayout

        spacing: Constants.sizeLg
        visible: root.activePlayer !== null
        Layout.fillWidth: true

        Item {
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                id: albumArtContainer

                anchors.fill: parent
                radius: Constants.sizeXs
                color: Colors.bgSecondary
                border.width: 1
                border.color: Colors.border
            }

            Image {
                id: albumArt

                anchors.fill: albumArtContainer
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
                id: albumArtMask

                anchors.fill: albumArtContainer
                radius: albumArtContainer.radius
                color: "white"
                visible: false
            }

            OpacityMask {
                anchors.fill: albumArtContainer
                source: albumArt
                maskSource: albumArtMask
            }

            ThemedText {
                anchors.centerIn: parent
                text: ""
                color: Colors.purple
                font.pixelSize: 28
                visible: albumArt.status !== Image.Ready
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: Constants.sizeLg

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                ThemedText {
                    text: root.activePlayer ? (root.activePlayer.trackTitle || "Not Playing") : ""
                    font.pixelSize: Constants.sizeLg
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                ThemedText {
                    text: root.activePlayer ? (root.activePlayer.trackArtist || "Unknown Artist") : ""
                    color: Colors.purple
                    font.pixelSize: Constants.sizeSm
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Constants.sizeXs

                IconButton {
                    icon: "󰒮"
                    iconSize: Constants.sizeXl
                    iconColor: (root.activePlayer && root.activePlayer.canGoPrevious) ? Colors.fg : Colors.muted
                    hoverColor: Colors.fg
                    onClicked: {
                        if (root.activePlayer)
                            root.activePlayer.previous();

                    }
                }

                IconButton {
                    id: playButton

                    property bool isPlaying: root.activePlayer && (root.activePlayer.playbackState === 1 || root.activePlayer.playbackState === Mpris.Playing || String(root.activePlayer.playbackState).toLowerCase().includes("playing"))

                    icon: (root.activePlayer && playButton.isPlaying) ? "󰏤" : "󰐊"
                    iconSize: Constants.sizeXl
                    iconColor: Colors.bg
                    hoverColor: Colors.bg
                    bgColor: Colors.purple
                    onClicked: {
                        if (root.activePlayer)
                            root.activePlayer.togglePlaying();

                    }
                }

                IconButton {
                    icon: "󰒭"
                    iconSize: Constants.sizeXl
                    iconColor: (root.activePlayer && root.activePlayer.canGoNext) ? Colors.fg : Colors.muted
                    hoverColor: Colors.fg
                    onClicked: {
                        if (root.activePlayer)
                            root.activePlayer.next();

                    }
                }

            }

        }

    }

}
