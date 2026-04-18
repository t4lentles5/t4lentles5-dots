import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import qs.Core

BarButton {
    id: root

    property var widget
    property var managedPlayers: []
    property bool hasMusic: false
    property var activePlayer: null

    function truncate(str) {
        if (!str)
            return "";

        let s = str.toString();
        return s.length > 25 ? s.substring(0, 20) + "..." : s;
    }

    function updateText() {
        let players = managedPlayers;
        let selected = null;
        let playing = null;
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            if (!p)
                continue;

            let id = (p.identity || "").toLowerCase();
            if (id.includes("spotify") || id.includes("youtube")) {
                if (p.playbackState === Mpris.Playing) {
                    playing = p;
                    break;
                }
                if (!selected)
                    selected = p;

            }
        }
        let finalPlayer = playing || selected;
        root.activePlayer = finalPlayer;
        if (finalPlayer) {
            let artist = finalPlayer.trackArtist;
            if (Array.isArray(artist))
                artist = artist.join(", ");

            artist = artist || "Unknown";
            let title = finalPlayer.trackTitle;
            if (title) {
                root.text = ` [ ${truncate(artist)} - ${truncate(title)} ]`;
                root.hasMusic = true;
                return ;
            }
        }
        root.text = " [ No music ]";
        root.hasMusic = false;
    }

    function registerPlayer(p) {
        if (managedPlayers.indexOf(p) === -1) {
            managedPlayers.push(p);
            updateText();
        }
    }

    function unregisterPlayer(p) {
        let index = managedPlayers.indexOf(p);
        if (index !== -1) {
            managedPlayers.splice(index, 1);
            updateText();
        }
    }

    Component.onCompleted: updateText()
    textColor: Theme.green
    mouseArea.acceptedButtons: Qt.LeftButton | Qt.RightButton
    mouseArea.onClicked: (mouse) => {
        if (mouse.button === Qt.RightButton) {
            Hyprland.dispatch("workspace 9");
        } else if (mouse.button === Qt.LeftButton) {
            if (root.activePlayer)
                widget.isOpen = !widget.isOpen;
            else
                Hyprland.dispatch("exec sh -c 'youtube-music || spotify'");
        }
    }

    Instantiator {
        model: Mpris.players

        delegate: QtObject {
            property var p: modelData
            property var state: p.playbackState
            property var title: p.trackTitle
            property var artist: p.trackArtist
            property var identity: p.identity

            onStateChanged: root.updateText()
            onTitleChanged: root.updateText()
            onArtistChanged: root.updateText()
            onIdentityChanged: root.updateText()
            Component.onCompleted: root.registerPlayer(p)
            Component.onDestruction: root.unregisterPlayer(p)
        }

    }

}
