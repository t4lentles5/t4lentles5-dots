import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

CenterWindow {
    id: root

    property bool showingDark: true
    property var displayThemes: {
        let wp = getWallpaperTheme();
        let list = [wp];
        for (let i = 0; i < Theme.themes.length; i++) {
            list.push(Theme.themes[i]);
        }
        return list;
    }

    function getWallpaperTheme() {
        let colors = Theme.wallpaperColors;
        if (!colors || !colors.bg)
            colors = {
            "name": "Wallpaper Theme",
            "bg": Theme.bg,
            "bgSecondary": Theme.bgSecondary,
            "orange": Theme.orange,
            "pink": Theme.pink,
            "fg": Theme.fg,
            "muted": Theme.muted,
            "cyan": Theme.cyan,
            "purple": Theme.purple,
            "red": Theme.red,
            "yellow": Theme.yellow,
            "blue": Theme.blue,
            "green": Theme.green
        };

        return {
            "name": "Wallpaper Theme",
            "isWallpaper": true,
            "dark": colors,
            "light": colors
        };
    }

    function selectTheme(theme) {
        if (theme.isWallpaper) {
            Theme.generateFromWallpaper = true;
            let wpColors = Theme.wallpaperColors || getWallpaperTheme().dark;
            Theme.applyScheme(wpColors);
        } else {
            let scheme = root.showingDark ? theme.dark : theme.light;
            Theme.generateFromWallpaper = false;
            Theme.applyScheme(scheme);
        }
        root.isOpen = false;
    }

    function findAndApplySchemeByName(name) {
        for (let i = 0; i < Theme.themes.length; i++) {
            if (Theme.themes[i].dark.name === name) {
                Theme.applyScheme(Theme.themes[i].dark);
                return ;
            }
            if (Theme.themes[i].light.name === name) {
                Theme.applyScheme(Theme.themes[i].light);
                return ;
            }
        }
    }

    function findCurrentIndex() {
        if (Theme.generateFromWallpaper || Theme.currentScheme === "Wallpaper Theme")
            return 0;

        for (let i = 0; i < Theme.themes.length; i++) {
            if (Theme.themes[i].dark.name === Theme.currentScheme || Theme.themes[i].light.name === Theme.currentScheme)
                return i + 1;

        }
        return 0;
    }

    footerLeftText: {
        if (root.displayThemes.length > 0)
            return root.displayThemes.length + (root.displayThemes.length === 1 ? " theme available" : " themes available");

        return "No themes available";
    }
    footerKeyHints: [{
        "key": "↑↓",
        "description": "Navigate"
    }, {
        "key": "󰌑",
        "description": "Apply"
    }, {
        "key": "󰌒",
        "description": "Switch Mode"
    }]
    popupId: "colorscheme"
    preferredHeight: 580
    preferredWidth: 600
    onPopupOpened: {
        focusTimer.start();
        let idx = findCurrentIndex();
        schemeList.currentIndex = idx;
        let brightness = Theme.bg.r * 0.299 + Theme.bg.g * 0.587 + Theme.bg.b * 0.114;
        root.showingDark = (brightness <= 0.5);
    }

    Timer {
        id: focusTimer

        interval: 50
        repeat: false
        onTriggered: schemeList.forceActiveFocus()
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Constants.sizeXs

        ThemedText {
            text: "󰏘"
            font.pixelSize: Constants.sizeLg
        }

        ThemedText {
            text: "COLOR SCHEMES"
            font.pixelSize: Constants.sizeMd
            font.letterSpacing: 2
            color: Theme.purple
            Layout.fillWidth: true
        }

        IconButton {
            icon: "󰒓"
            iconColor: Theme.muted
            hoverColor: Theme.purple
            bgColor: "transparent"
            onClicked: {
                root.isOpen = false;
                AppState.openPopup("settings");
            }
        }

        Rectangle {
            Layout.preferredHeight: 28
            Layout.preferredWidth: 104
            radius: Constants.sizeSm
            color: Theme.bgSecondary

            Rectangle {
                id: toggleIndicator

                width: 48
                height: 24
                radius: Constants.sizeMd
                color: Theme.purple
                x: root.showingDark ? 3 : 53
                anchors.verticalCenter: parent.verticalCenter

                Behavior on x {
                    NumberAnimation {
                        duration: Constants.animNormal
                        easing.type: Easing.OutQuint
                    }

                }

            }

            Row {
                anchors.centerIn: parent
                spacing: 2

                Item {
                    width: 48
                    height: 24

                    ThemedText {
                        anchors.centerIn: parent
                        text: "Dark"
                        font.pixelSize: Constants.sizeSm - 1
                        color: root.showingDark ? Theme.bg : Theme.muted

                        Behavior on color {
                            ColorAnimation {
                                duration: Constants.animFast
                            }

                        }

                    }

                    TapHandler {
                        onTapped: root.showingDark = true
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                }

                Item {
                    width: 48
                    height: 24

                    ThemedText {
                        anchors.centerIn: parent
                        text: "Light"
                        font.pixelSize: Constants.sizeSm - 1
                        color: !root.showingDark ? Theme.bg : Theme.muted

                        Behavior on color {
                            ColorAnimation {
                                duration: Constants.animFast
                            }

                        }

                    }

                    TapHandler {
                        onTapped: root.showingDark = false
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                }

            }

        }

        ThemedText {
            text: Theme.currentScheme
            font.pixelSize: Constants.sizeSm
            color: Theme.muted
        }

    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
            id: schemeList

            anchors.fill: parent
            clip: true
            model: root.displayThemes
            spacing: 6
            currentIndex: 0
            highlightFollowsCurrentItem: true
            highlightMoveDuration: Constants.animNormal
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (currentIndex >= 0 && currentIndex < root.displayThemes.length)
                        root.selectTheme(root.displayThemes[currentIndex]);

                    event.accepted = true;
                } else if (event.key === Qt.Key_Tab) {
                    root.showingDark = !root.showingDark;
                    event.accepted = true;
                }
            }

            highlight: Item {
                width: schemeList.width
                height: 90
                z: 6

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: Constants.sizeXs
                    color: "transparent"
                    border.color: Theme.purple
                    border.width: 2
                }

            }

            delegate: Item {
                id: delegateRoot

                property var theme: modelData
                property bool isDarkActive: Theme.generateFromWallpaper ? (theme.isWallpaper === true && (Theme.bg.r * 0.299 + Theme.bg.g * 0.587 + Theme.bg.b * 0.114 <= 0.5)) : (theme.isWallpaper !== true && Theme.currentScheme === theme.dark.name)
                property bool isLightActive: Theme.generateFromWallpaper ? (theme.isWallpaper === true && (Theme.bg.r * 0.299 + Theme.bg.g * 0.587 + Theme.bg.b * 0.114 > 0.5)) : (theme.isWallpaper !== true && Theme.currentScheme === theme.light.name)
                property bool isActive: isDarkActive || isLightActive

                width: schemeList.width
                height: 90

                Rectangle {
                    id: card

                    anchors.fill: parent
                    anchors.margins: 2
                    radius: Constants.sizeXs
                    color: "transparent"

                    Rectangle {
                        id: cardMask

                        anchors.fill: parent
                        radius: Constants.sizeXs
                        visible: false
                    }

                    Item {
                        anchors.fill: parent
                        layer.enabled: true

                        Canvas {
                            id: bgCanvas

                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                var w = width;
                                var h = height;
                                ctx.beginPath();
                                ctx.moveTo(0, 0);
                                ctx.lineTo(w * 0.55, 0);
                                ctx.lineTo(w * 0.45, h);
                                ctx.lineTo(0, h);
                                ctx.closePath();
                                ctx.fillStyle = delegateRoot.theme.dark.bg;
                                ctx.fill();
                                ctx.beginPath();
                                ctx.moveTo(w * 0.55, 0);
                                ctx.lineTo(w, 0);
                                ctx.lineTo(w, h);
                                ctx.lineTo(w * 0.45, h);
                                ctx.closePath();
                                ctx.fillStyle = delegateRoot.theme.light.bg;
                                ctx.fill();
                                ctx.beginPath();
                                ctx.moveTo(w * 0.55, 0);
                                ctx.lineTo(w * 0.45, h);
                                ctx.strokeStyle = "rgba(128, 128, 128, 0.3)";
                                ctx.lineWidth = 1;
                                ctx.stroke();
                            }
                        }

                        Item {
                            width: parent.width * 0.45
                            height: parent.height

                            Column {
                                anchors.centerIn: parent
                                spacing: 6

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 4

                                    Repeater {
                                        model: [delegateRoot.theme.dark.cyan, delegateRoot.theme.dark.purple, delegateRoot.theme.dark.red, delegateRoot.theme.dark.yellow, delegateRoot.theme.dark.blue, delegateRoot.theme.dark.green, delegateRoot.theme.dark.pink, delegateRoot.theme.dark.orange]

                                        Rectangle {
                                            width: 12
                                            height: 12
                                            radius: 6
                                            color: modelData
                                        }

                                    }

                                }

                                Text {
                                    text: "Aa Bb Cc"
                                    color: delegateRoot.theme.dark.fg
                                    font.family: Constants.fontFamily
                                    font.pixelSize: Constants.sizeMd
                                    font.weight: Font.Medium
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: delegateRoot.theme.dark.name
                                    color: delegateRoot.theme.dark.muted
                                    font.family: Constants.fontFamily
                                    font.pixelSize: Constants.sizeSm
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                            }

                        }

                        Item {
                            x: parent.width * 0.55
                            width: parent.width * 0.45
                            height: parent.height

                            Column {
                                anchors.centerIn: parent
                                spacing: 6

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 4

                                    Repeater {
                                        model: [delegateRoot.theme.light.cyan, delegateRoot.theme.light.purple, delegateRoot.theme.light.red, delegateRoot.theme.light.yellow, delegateRoot.theme.light.blue, delegateRoot.theme.light.green, delegateRoot.theme.light.pink, delegateRoot.theme.light.orange]

                                        Rectangle {
                                            width: 12
                                            height: 12
                                            radius: 6
                                            color: modelData
                                        }

                                    }

                                }

                                Text {
                                    text: "Aa Bb Cc"
                                    color: delegateRoot.theme.light.fg
                                    font.family: Constants.fontFamily
                                    font.pixelSize: Constants.sizeMd
                                    font.weight: Font.Medium
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: delegateRoot.theme.light.name
                                    color: delegateRoot.theme.light.muted
                                    font.family: Constants.fontFamily
                                    font.pixelSize: Constants.sizeSm
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                            }

                        }

                        Text {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: 8
                            text: "󰄬"
                            color: delegateRoot.theme.dark.purple
                            font.family: Constants.fontFamily
                            font.pixelSize: Constants.sizeMd
                            visible: delegateRoot.isDarkActive
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 8
                            text: "󰄬"
                            color: delegateRoot.theme.light.purple
                            font.family: Constants.fontFamily
                            font.pixelSize: Constants.sizeMd
                            visible: delegateRoot.isLightActive
                        }

                        layer.effect: OpacityMask {
                            maskSource: cardMask
                        }

                    }

                }

                HoverHandler {
                    id: hoverHandler

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        schemeList.currentIndex = index;
                        root.selectTheme(delegateRoot.theme);
                    }
                }

            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                active: true
            }

        }

    }

}
