import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.Core

Rectangle {
    id: root

    property int cardPadding: 20
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
            if (id.includes("spotify") || id.includes("youtube") || id.includes("chrome")) {
                if (p.playbackState === root.statePlaying) {
                    playing = p;
                    break;
                }
                if (!selected)
                    selected = p;

            }
        }
        let newPlayer = playing || selected;
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

    color: Theme.colBgSecondary
    radius: 10
    clip: true

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

    Image {
        id: bgArt

        anchors.fill: parent
        source: root.activePlayer ? (root.activePlayer.trackArtUrl || "") : ""
        fillMode: Image.PreserveAspectCrop
        visible: false
        asynchronous: true
    }

    Item {
        id: blurContainer

        anchors.fill: parent
        visible: root.activePlayer !== null && bgArt.status === Image.Ready

        FastBlur {
            id: blurEffect

            anchors.fill: parent
            source: bgArt
            radius: 48
            cached: true
            visible: false
        }

        Rectangle {
            id: maskRect

            anchors.fill: parent
            radius: root.radius
            visible: false
        }

        OpacityMask {
            anchors.fill: parent
            source: blurEffect
            maskSource: maskRect
        }

    }

    Rectangle {
        anchors.fill: parent
        color: root.activePlayer ? "#D9121218" : Theme.colBgSecondary
        radius: root.radius
        visible: root.activePlayer !== null
    }

    Item {
        anchors.fill: parent
        visible: root.activePlayer === null

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "󰎆"
                color: Theme.colMuted
                font.pixelSize: 48
                font.family: Theme.fontFamily
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "No Media"
                color: Theme.colMuted
                font.pixelSize: 16
                font.family: Theme.fontFamily
                Layout.alignment: Qt.AlignHCenter
            }

        }

    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: parent.cardPadding
        spacing: 20
        visible: root.activePlayer !== null

        Rectangle {
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            radius: 12
            color: Theme.colBgLighter
            clip: true

            Image {
                anchors.fill: parent
                source: root.activePlayer ? (root.activePlayer.trackArtUrl || "") : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: parent.children[0].status !== Image.Ready
                text: ""
                color: Theme.colPurple
                font.pixelSize: 42
                font.family: Theme.fontFamily
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 5

            Text {
                text: root.activePlayer ? (root.activePlayer.trackTitle || "Unknown Title") : ""
                color: Theme.colFg
                font.pixelSize: 16
                font.bold: true
                font.family: Theme.fontFamily
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.activePlayer ? (root.activePlayer.trackArtist || "Unknown Artist") : ""
                color: Theme.colCyan
                font.pixelSize: 14
                font.family: Theme.fontFamily
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Item {
                Layout.preferredHeight: 10
            }

            RowLayout {
                spacing: 25

                Text {
                    text: ""
                    color: Theme.colFg
                    font.pixelSize: 20
                    font.family: Theme.fontFamily

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.activePlayer)
                                root.activePlayer.previous();

                        }
                    }

                }

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 21
                    color: Theme.colPurple

                    Text {
                        anchors.centerIn: parent
                        text: (root.activePlayer && root.activePlayer.playbackState === root.statePlaying) ? "" : ""
                        color: Theme.colBg
                        font.pixelSize: 20
                        font.family: Theme.fontFamily
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.activePlayer)
                                root.activePlayer.togglePlaying();

                        }
                    }

                }

                Text {
                    text: ""
                    color: Theme.colFg
                    font.pixelSize: 20
                    font.family: Theme.fontFamily

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.activePlayer)
                                root.activePlayer.next();

                        }
                    }

                }

            }

        }

    }

}
