import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.Core

TopPopup {
    id: root

    property int cardPadding: 16
    property var managedPlayers: []
    property var activePlayer: null
    readonly property int statePlaying: 1

    function updatePlayer() {
        let players = managedPlayers;
        let selected = null;
        let playing = null;
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            if (!p)
                continue;

            let id = (p.identity || "").toLowerCase();
            if (id.includes("spotify") || id.includes("youtube")) {
                if (p.playbackState === root.statePlaying) {
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

    implicitWidth: 260

    Instantiator {
        model: Mpris.players

        delegate: QtObject {
            property var p: modelData
            property var state: p.playbackState

            onStateChanged: root.updatePlayer()
            Component.onCompleted: root.registerPlayer(p)
            Component.onDestruction: root.unregisterPlayer(p)
        }

    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 140
        visible: root.activePlayer === null

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            ThemedText {
                text: "󰎆"
                color: Theme.colMuted
                font.pixelSize: 48
                Layout.alignment: Qt.AlignHCenter
            }

            ThemedText {
                text: "No Media Playing"
                color: Theme.colMuted
                font.pixelSize: Theme.fontSizeMd
                Layout.alignment: Qt.AlignHCenter
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animNormal
            }

        }

    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8
        visible: root.activePlayer !== null

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 300
            color: Theme.colBgSecondary
            radius: Theme.radiusSm

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        id: artMask

                        anchors.fill: parent
                        radius: Theme.radiusSm
                        visible: false
                    }

                    Image {
                        id: albumArt

                        anchors.fill: parent
                        source: root.activePlayer ? (root.activePlayer.trackArtUrl || "") : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: false
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusSm
                        color: Theme.colBgLighter
                        opacity: albumArt.status === Image.Ready ? 0 : 1

                        ThemedText {
                            anchors.centerIn: parent
                            text: ""
                            color: Theme.colPurple
                            font.pixelSize: 60
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.animSlow
                                easing.type: Easing.OutQuint
                            }

                        }

                    }

                    OpacityMask {
                        anchors.fill: parent
                        source: albumArt
                        maskSource: artMask
                        opacity: albumArt.status === Image.Ready ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.animSlow
                                easing.type: Easing.OutQuint
                            }

                        }

                    }

                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    ThemedText {
                        text: root.activePlayer ? (root.activePlayer.trackTitle || "Unknown Title") : ""
                        color: Theme.colFg
                        font.pixelSize: Theme.fontSizeMd
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    ThemedText {
                        text: root.activePlayer ? (root.activePlayer.trackArtist || "Unknown Artist") : ""
                        color: Theme.colCyan
                        font.pixelSize: Theme.fontSizeSm
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    IconButton {
                        icon: "󰒮"
                        iconSize: 26
                        width: 36
                        height: 36
                        iconColor: (root.activePlayer && root.activePlayer.canGoPrevious) ? Theme.colFg : Theme.colMuted
                        onClicked: {
                            if (root.activePlayer)
                                root.activePlayer.previous();

                        }
                    }

                    IconButton {
                        icon: (root.activePlayer && root.activePlayer.playbackState === root.statePlaying) ? "󰏤" : "󰐊"
                        iconSize: 28
                        width: 48
                        height: 48
                        radius: Theme.radiusLg
                        iconColor: Theme.colBg
                        hoverColor: Theme.colCyan
                        baseColor: Theme.colPurple
                        onClicked: {
                            if (root.activePlayer)
                                root.activePlayer.togglePlaying();

                        }
                    }

                    IconButton {
                        icon: "󰒭"
                        iconSize: 26
                        width: 36
                        height: 36
                        iconColor: (root.activePlayer && root.activePlayer.canGoNext) ? Theme.colFg : Theme.colMuted
                        onClicked: {
                            if (root.activePlayer)
                                root.activePlayer.next();

                        }
                    }

                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animNormal
            }

        }

    }

}
