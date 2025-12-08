import QtQml
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris

Rectangle {
    id: root

    property var managedPlayers: []
    property bool hasMusic: false

    function truncate(str) {
        if (!str)
            return "";

        let s = str.toString();
        return s.length > 20 ? s.substring(0, 15) + "..." : s;
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
        if (finalPlayer) {
            let artist = finalPlayer.trackArtist;
            if (Array.isArray(artist))
                artist = artist.join(", ");

            artist = artist || "Unknown";
            let title = finalPlayer.trackTitle;
            if (title) {
                musicText.text = ` [ ${truncate(artist)} - ${truncate(title)} ]`;
                root.hasMusic = true;
                return ;
            }
        }
        musicText.text = " [ No music ]";
        root.hasMusic = false;
    }

    function registerPlayer(p) {
        let list = managedPlayers;
        if (list.indexOf(p) === -1) {
            list.push(p);
            managedPlayers = list;
            updateText();
        }
    }

    function unregisterPlayer(p) {
        let list = managedPlayers;
        let index = list.indexOf(p);
        if (index !== -1) {
            list.splice(index, 1);
            managedPlayers = list;
            updateText();
        }
    }

    color: theme.colBgSecondary
    radius: 20
    implicitWidth: musicText.implicitWidth + 30
    implicitHeight: 30
    Component.onCompleted: updateText()

    Theme {
        id: theme
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                Hyprland.dispatch("workspace 9");
            } else if (mouse.button === Qt.LeftButton) {
                if (!root.hasMusic)
                    Hyprland.dispatch("exec youtube-music");

            }
        }
    }

    Text {
        id: musicText

        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: " [ No music ]"
        color: theme.colGreen
        font.pixelSize: theme.fontSize
        font.family: theme.fontFamily
        font.bold: true
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
