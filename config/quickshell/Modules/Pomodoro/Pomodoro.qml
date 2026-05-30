import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

AppWindow {
    id: root

    property int workDurationMinutes: 25
    property int shortBreakDurationMinutes: 5
    property int longBreakDurationMinutes: 15
    property int sessionsBeforeLongBreak: 4
    readonly property int workDuration: workDurationMinutes * 60
    readonly property int shortBreakDuration: shortBreakDurationMinutes * 60
    readonly property int longBreakDuration: longBreakDurationMinutes * 60
    property bool isSettingsOpen: false
    property int currentMode: 0
    property int timeRemaining: workDuration
    property int totalTime: workDuration
    property bool isRunning: false
    property int completedSessions: 0
    readonly property real progress: totalTime > 0 ? (1 - timeRemaining / totalTime) : 0
    readonly property string timeDisplay: {
        let m = Math.floor(timeRemaining / 60);
        let s = timeRemaining % 60;
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
    }
    readonly property var modeNames: ["Focus", "Short Break", "Long Break"]
    readonly property var modeIcons: ["󱎫", "󰒲", "󰒲"]
    readonly property var modeColors: [Theme.red, Theme.green, Theme.cyan]
    property int tempWorkMinutes: workDurationMinutes
    property int tempShortBreakMinutes: shortBreakDurationMinutes
    property int tempLongBreakMinutes: longBreakDurationMinutes
    property int tempSessions: sessionsBeforeLongBreak
    readonly property bool settingsChanged: (tempWorkMinutes !== workDurationMinutes || tempShortBreakMinutes !== shortBreakDurationMinutes || tempLongBreakMinutes !== longBreakDurationMinutes || tempSessions !== sessionsBeforeLongBreak)

    function updateCurrentDuration() {
        if (!isRunning) {
            switch (currentMode) {
            case 0:
                timeRemaining = workDuration;
                totalTime = workDuration;
                break;
            case 1:
                timeRemaining = shortBreakDuration;
                totalTime = shortBreakDuration;
                break;
            case 2:
                timeRemaining = longBreakDuration;
                totalTime = longBreakDuration;
                break;
            }
        }
    }

    function startPause() {
        isRunning = !isRunning;
    }

    function resetTimer() {
        isRunning = false;
        switch (currentMode) {
        case 0:
            timeRemaining = workDuration;
            totalTime = workDuration;
            break;
        case 1:
            timeRemaining = shortBreakDuration;
            totalTime = shortBreakDuration;
            break;
        case 2:
            timeRemaining = longBreakDuration;
            totalTime = longBreakDuration;
            break;
        }
    }

    function switchMode(mode) {
        currentMode = mode;
        isRunning = false;
        switch (mode) {
        case 0:
            timeRemaining = workDuration;
            totalTime = workDuration;
            break;
        case 1:
            timeRemaining = shortBreakDuration;
            totalTime = shortBreakDuration;
            break;
        case 2:
            timeRemaining = longBreakDuration;
            totalTime = longBreakDuration;
            break;
        }
    }

    function onTimerFinished() {
        isRunning = false;
        if (currentMode === 0) {
            completedSessions++;
            if (completedSessions % sessionsBeforeLongBreak === 0)
                switchMode(2);
            else
                switchMode(1);
        } else {
            switchMode(0);
        }
    }

    function applySettings() {
        workDurationMinutes = tempWorkMinutes;
        shortBreakDurationMinutes = tempShortBreakMinutes;
        longBreakDurationMinutes = tempLongBreakMinutes;
        sessionsBeforeLongBreak = tempSessions;
        resetTimer();
    }

    function openSettings() {
        isRunning = false;
        tempWorkMinutes = workDurationMinutes;
        tempShortBreakMinutes = shortBreakDurationMinutes;
        tempLongBreakMinutes = longBreakDurationMinutes;
        tempSessions = sessionsBeforeLongBreak;
        isSettingsOpen = true;
    }

    popupId: "pomodoro"
    windowTitle: "Pomodoro Timer"
    windowIcon: "󱎫"
    windowIconColor: isSettingsOpen ? Theme.purple : modeColors[currentMode]
    implicitWidth: 352
    implicitHeight: 480
    onWindowClosed: root.resetTimer()
    onWorkDurationChanged: updateCurrentDuration()
    onShortBreakDurationChanged: updateCurrentDuration()
    onLongBreakDurationChanged: updateCurrentDuration()
    headerActions: [
        IconButton {
            icon: root.isSettingsOpen ? "󰁍" : "󰒓"
            iconColor: Theme.muted
            hoverColor: Theme.purple
            bgColor: "transparent"
            onClicked: {
                if (root.isSettingsOpen)
                    root.isSettingsOpen = false;
                else
                    root.openSettings();
            }
        }
    ]

    Timer {
        interval: 1000
        running: root.isRunning
        repeat: true
        onTriggered: {
            if (root.timeRemaining > 0)
                root.timeRemaining--;
            else
                root.onTimerFinished();
        }
    }

    Item {
        id: mainLayout

        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            anchors.fill: parent
            opacity: root.isSettingsOpen ? 0 : 1
            visible: opacity > 0
            spacing: Constants.sizeLg

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: ringContainer.height + Constants.sizeLg * 2
                color: Theme.bgSecondary
                radius: Constants.sizeXs

                Item {
                    id: ringContainer

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: 200
                    height: 200

                    Canvas {
                        id: bgRing

                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var cx = width / 2;
                            var cy = height / 2;
                            var r = Math.min(cx, cy) - 12;
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                            ctx.lineWidth = 6;
                            ctx.strokeStyle = Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.2);
                            ctx.stroke();
                        }
                        Component.onCompleted: requestPaint()

                        Connections {
                            function onMutedChanged() {
                                bgRing.requestPaint();
                            }

                            target: Theme
                        }

                    }

                    Canvas {
                        id: progressRing

                        property real animProgress: root.progress
                        property color ringColor: root.modeColors[root.currentMode]

                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var cx = width / 2;
                            var cy = height / 2;
                            var r = Math.min(cx, cy) - 12;
                            var startAngle = -Math.PI / 2;
                            var endAngle = startAngle + (2 * Math.PI * animProgress);
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, startAngle, endAngle);
                            ctx.lineWidth = 6;
                            ctx.lineCap = "round";
                            ctx.strokeStyle = ringColor;
                            ctx.stroke();
                        }
                        onAnimProgressChanged: requestPaint()
                        onRingColorChanged: requestPaint()
                        Component.onCompleted: requestPaint()

                        Behavior on animProgress {
                            NumberAnimation {
                                duration: 800
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        ThemedText {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.modeIcons[root.currentMode]
                            font.pixelSize: Constants.sizeXl
                            color: root.modeColors[root.currentMode]

                            Behavior on color {
                                ColorAnimation {
                                    duration: Constants.animNormal
                                }

                            }

                        }

                        ThemedText {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.timeDisplay
                            font.pixelSize: 36
                            font.bold: true
                            color: Theme.fg
                            opacity: root.isRunning ? pulseAnim.opacity : 1

                            SequentialAnimation on opacity {
                                id: pulseAnim

                                running: root.isRunning
                                loops: Animation.Infinite

                                NumberAnimation {
                                    to: 0.6
                                    duration: 1000
                                    easing.type: Easing.InOutSine
                                }

                                NumberAnimation {
                                    to: 1
                                    duration: 1000
                                    easing.type: Easing.InOutSine
                                }

                            }

                        }

                        ThemedText {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.modeNames[root.currentMode]
                            font.pixelSize: Constants.sizeSm
                            color: Theme.muted
                        }

                    }

                }

            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: Constants.sizeLg

                IconButton {
                    icon: "󰑐"
                    iconColor: Theme.muted
                    hoverColor: Theme.yellow
                    bgColor: Theme.bgSecondary
                    onClicked: root.resetTimer()
                }

                Rectangle {
                    width: 56
                    height: 56
                    radius: 28
                    color: {
                        if (playTap.pressed)
                            return Qt.rgba(root.modeColors[root.currentMode].r, root.modeColors[root.currentMode].g, root.modeColors[root.currentMode].b, 0.3);

                        if (playHover.hovered)
                            return Qt.rgba(root.modeColors[root.currentMode].r, root.modeColors[root.currentMode].g, root.modeColors[root.currentMode].b, 0.2);

                        return Theme.bgSecondary;
                    }
                    scale: playTap.pressed ? 0.92 : 1

                    ThemedText {
                        anchors.centerIn: parent
                        text: root.isRunning ? "󰏤" : "󰐊"
                        font.pixelSize: Constants.sizeXl + 4
                        color: root.modeColors[root.currentMode]
                        scale: playHover.hovered ? 1.15 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: Constants.animFast
                                easing.type: Easing.OutQuint
                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Constants.animNormal
                            }

                        }

                    }

                    HoverHandler {
                        id: playHover

                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        id: playTap

                        onTapped: root.startPause()
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Constants.animNormal
                        }

                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: Constants.animFast
                            easing.type: Easing.OutBack
                        }

                    }

                }

                IconButton {
                    icon: "󰒭"
                    iconColor: Theme.muted
                    hoverColor: Theme.cyan
                    bgColor: Theme.bgSecondary
                    onClicked: root.onTimerFinished()
                }

            }

            Rectangle {
                Layout.fillWidth: true
                implicitWidth: sessionRow.implicitWidth + Constants.sizeLg * 2
                Layout.preferredHeight: sessionRow.implicitHeight + Constants.sizeLg * 2
                color: Theme.bgSecondary
                radius: Constants.sizeXs

                RowLayout {
                    id: sessionRow

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Constants.sizeLg
                    spacing: Constants.sizeLg

                    ThemedText {
                        text: "󰝥"
                        font.pixelSize: Constants.sizeMd
                        color: Theme.purple
                    }

                    ThemedText {
                        text: "Sessions"
                        font.pixelSize: Constants.sizeSm
                        color: Theme.muted
                    }

                    RowLayout {
                        spacing: 6

                        Repeater {
                            model: root.sessionsBeforeLongBreak

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
                                color: index < (root.completedSessions % root.sessionsBeforeLongBreak) ? Theme.purple : Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.3)
                                border.width: index < (root.completedSessions % root.sessionsBeforeLongBreak) ? 0 : 1
                                border.color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.4)
                                scale: index < (root.completedSessions % root.sessionsBeforeLongBreak) ? 1 : 0.8

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Constants.animNormal
                                    }

                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Constants.animFast
                                        easing.type: Easing.OutBack
                                    }

                                }

                            }

                        }

                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ThemedText {
                        text: root.completedSessions + " total"
                        font.pixelSize: Constants.sizeSm
                        color: Theme.muted
                    }

                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Constants.animNormal
                    easing.type: Easing.InOutQuad
                }

            }

        }

        ColumnLayout {
            anchors.fill: parent
            opacity: root.isSettingsOpen ? 1 : 0
            visible: opacity > 0
            spacing: Constants.sizeLg

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: settingsContent.implicitHeight + Constants.sizeLg * 2
                color: Theme.bgSecondary
                radius: Constants.sizeXs

                ColumnLayout {
                    id: settingsContent

                    anchors.fill: parent
                    anchors.margins: Constants.sizeLg
                    spacing: Constants.sizeLg

                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            ThemedText {
                                text: "Focus Time"
                                color: Theme.fg
                                font.pixelSize: Constants.sizeSm
                            }

                            ThemedText {
                                text: "Duration of each work session"
                                color: Theme.muted
                                font.pixelSize: Constants.sizeSm - 1
                            }

                        }

                        RowLayout {
                            spacing: Constants.sizeXs

                            IconButton {
                                icon: "󰍴"
                                iconSize: Constants.sizeSm
                                onClicked: {
                                    if (root.tempWorkMinutes > 1)
                                        root.tempWorkMinutes--;

                                }
                            }

                            ThemedText {
                                text: root.tempWorkMinutes + " min"
                                color: Theme.fg
                                font.bold: true
                                font.pixelSize: Constants.sizeSm
                                Layout.preferredWidth: 60
                                horizontalAlignment: Text.AlignHCenter
                            }

                            IconButton {
                                icon: "󰐕"
                                iconSize: Constants.sizeSm
                                onClicked: {
                                    root.tempWorkMinutes++;
                                }
                            }

                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            ThemedText {
                                text: "Short Break"
                                color: Theme.fg
                                font.pixelSize: Constants.sizeSm
                            }

                            ThemedText {
                                text: "Rest between sessions"
                                color: Theme.muted
                                font.pixelSize: Constants.sizeSm - 1
                            }

                        }

                        RowLayout {
                            spacing: Constants.sizeXs

                            IconButton {
                                icon: "󰍴"
                                iconSize: Constants.sizeSm
                                onClicked: {
                                    if (root.tempShortBreakMinutes > 1)
                                        root.tempShortBreakMinutes--;

                                }
                            }

                            ThemedText {
                                text: root.tempShortBreakMinutes + " min"
                                color: Theme.fg
                                font.bold: true
                                font.pixelSize: Constants.sizeSm
                                Layout.preferredWidth: 60
                                horizontalAlignment: Text.AlignHCenter
                            }

                            IconButton {
                                icon: "󰐕"
                                iconSize: Constants.sizeSm
                                onClicked: {
                                    root.tempShortBreakMinutes++;
                                }
                            }

                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            ThemedText {
                                text: "Long Break"
                                color: Theme.fg
                                font.pixelSize: Constants.sizeSm
                            }

                            ThemedText {
                                text: "Rest after completing a cycle"
                                color: Theme.muted
                                font.pixelSize: Constants.sizeSm - 1
                            }

                        }

                        RowLayout {
                            spacing: Constants.sizeXs

                            IconButton {
                                icon: "󰍴"
                                iconSize: Constants.sizeSm
                                onClicked: {
                                    if (root.tempLongBreakMinutes > 1)
                                        root.tempLongBreakMinutes--;

                                }
                            }

                            ThemedText {
                                text: root.tempLongBreakMinutes + " min"
                                color: Theme.fg
                                font.bold: true
                                font.pixelSize: Constants.sizeSm
                                Layout.preferredWidth: 60
                                horizontalAlignment: Text.AlignHCenter
                            }

                            IconButton {
                                icon: "󰐕"
                                iconSize: Constants.sizeSm
                                onClicked: {
                                    root.tempLongBreakMinutes++;
                                }
                            }

                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            ThemedText {
                                text: "Cycle Length"
                                color: Theme.fg
                                font.pixelSize: Constants.sizeSm
                            }

                            ThemedText {
                                text: "Sessions before long break"
                                color: Theme.muted
                                font.pixelSize: Constants.sizeSm - 1
                            }

                        }

                        RowLayout {
                            spacing: Constants.sizeXs

                            IconButton {
                                icon: "󰍴"
                                iconSize: Constants.sizeSm
                                onClicked: {
                                    if (root.tempSessions > 1)
                                        root.tempSessions--;

                                }
                            }

                            ThemedText {
                                text: root.tempSessions
                                color: Theme.fg
                                font.bold: true
                                font.pixelSize: Constants.sizeSm
                                Layout.preferredWidth: 60
                                horizontalAlignment: Text.AlignHCenter
                            }

                            IconButton {
                                icon: "󰐕"
                                iconSize: Constants.sizeSm
                                onClicked: {
                                    root.tempSessions++;
                                }
                            }

                        }

                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Constants.sizeXs
                color: {
                    if (!root.settingsChanged)
                        return Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.15);

                    if (applyTap.pressed)
                        return Qt.rgba(Theme.purple.r, Theme.purple.g, Theme.purple.b, 0.35);

                    if (applyHover.hovered)
                        return Qt.rgba(Theme.purple.r, Theme.purple.g, Theme.purple.b, 0.25);

                    return Qt.rgba(Theme.purple.r, Theme.purple.g, Theme.purple.b, 0.15);
                }
                border.width: 1
                border.color: root.settingsChanged ? Qt.rgba(Theme.purple.r, Theme.purple.g, Theme.purple.b, 0.4) : "transparent"
                scale: applyTap.pressed && root.settingsChanged ? 0.97 : 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Constants.sizeXs

                    ThemedText {
                        text: "󰄬"
                        font.pixelSize: Constants.sizeMd
                        color: root.settingsChanged ? Theme.purple : Theme.muted
                    }

                    ThemedText {
                        text: "Apply & Reset"
                        font.pixelSize: Constants.sizeSm
                        font.bold: true
                        color: root.settingsChanged ? Theme.purple : Theme.muted
                    }

                }

                HoverHandler {
                    id: applyHover

                    cursorShape: root.settingsChanged ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                TapHandler {
                    id: applyTap

                    onTapped: {
                        if (root.settingsChanged) {
                            root.applySettings();
                            root.isSettingsOpen = false;
                        }
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Constants.animNormal
                    }

                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Constants.animFast
                        easing.type: Easing.OutBack
                    }

                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: Constants.animNormal
                    }

                }

            }

            Item {
                Layout.fillHeight: true
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Constants.animNormal
                    easing.type: Easing.InOutQuad
                }

            }

        }

    }

}
