import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

TopPopup {
    id: root

    property date currentDate: new Date()
    property int currentMonth: currentDate.getMonth()
    property int currentYear: currentDate.getFullYear()
    property int animDirection: 1
    property bool isAnimating: false
    property bool isJumpingToToday: false

    function daysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstDayOffset(month, year) {
        return new Date(year, month, 1).getDay();
    }

    function doPrevMonth() {
        if (currentMonth === 0) {
            currentMonth = 11;
            currentYear--;
        } else {
            currentMonth--;
        }
    }

    function doNextMonth() {
        if (currentMonth === 11) {
            currentMonth = 0;
            currentYear++;
        } else {
            currentMonth++;
        }
    }

    function prevMonth() {
        if (isAnimating)
            return ;

        animDirection = 1;
        monthTransitionAnim.start();
    }

    function nextMonth() {
        if (isAnimating)
            return ;

        animDirection = -1;
        monthTransitionAnim.start();
    }

    function jumpToToday() {
        if (isAnimating)
            return ;

        var now = new Date();
        if (root.currentMonth === now.getMonth() && root.currentYear === now.getFullYear())
            return ;

        animDirection = now.getFullYear() < root.currentYear || (now.getFullYear() === root.currentYear && now.getMonth() < root.currentMonth) ? 1 : -1;
        isJumpingToToday = true;
        monthTransitionAnim.start();
    }

    preferredHeight: implicitHeight
    animateHeight: true

    Process {
        id: gnomeCalendarProc

        command: ["gnome-calendar"]
    }

    SequentialAnimation {
        id: monthTransitionAnim

        PropertyAction {
            target: root
            property: "isAnimating"
            value: true
        }

        ParallelAnimation {
            NumberAnimation {
                target: daysGrid
                property: "opacity"
                to: 0
                duration: Constants.animFast
                easing.type: Easing.OutQuint
            }

            NumberAnimation {
                target: daysTranslate
                property: "x"
                to: Constants.sizeLg * root.animDirection
                duration: Constants.animFast
                easing.type: Easing.OutQuint
            }

            NumberAnimation {
                target: monthLabelContainer
                property: "opacity"
                to: 0
                duration: Constants.animFast
                easing.type: Easing.OutQuint
            }

            NumberAnimation {
                target: monthTranslate
                property: "x"
                to: Constants.sizeLg * root.animDirection
                duration: Constants.animFast
                easing.type: Easing.OutQuint
            }

        }

        ScriptAction {
            script: {
                if (root.isJumpingToToday) {
                    var now = new Date();
                    root.currentMonth = now.getMonth();
                    root.currentYear = now.getFullYear();
                    root.isJumpingToToday = false;
                } else if (root.animDirection === 1) {
                    root.doPrevMonth();
                } else {
                    root.doNextMonth();
                }
                daysTranslate.x = -Constants.sizeLg * root.animDirection;
                monthTranslate.x = -Constants.sizeLg * root.animDirection;
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: daysGrid
                property: "opacity"
                to: 1
                duration: Constants.animFast
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: daysTranslate
                property: "x"
                to: 0
                duration: Constants.animFast
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: monthLabelContainer
                property: "opacity"
                to: 1
                duration: Constants.animFast
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: monthTranslate
                property: "x"
                to: 0
                duration: Constants.animFast
                easing.type: Easing.OutQuad
            }

        }

        PropertyAction {
            target: root
            property: "isAnimating"
            value: false
        }

    }

    Rectangle {
        id: mainCard

        implicitWidth: gridContainer.implicitWidth + (Constants.sizeMd * 2)
        implicitHeight: mainCol.implicitHeight + (Constants.sizeMd * 2)
        color: Theme.bgSecondary
        radius: Constants.sizeMd
        border.color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.05)
        border.width: 1

        ColumnLayout {
            id: mainCol

            anchors.fill: parent
            anchors.margins: Constants.sizeMd
            spacing: Constants.sizeMd

            RowLayout {
                Layout.fillWidth: true
                spacing: Constants.sizeMd

                Item {
                    id: monthLabelContainer

                    Layout.fillWidth: true
                    Layout.preferredHeight: monthText.implicitHeight

                    ThemedText {
                        id: monthText

                        text: new Date(root.currentYear, root.currentMonth, 1).toLocaleDateString(Qt.locale(), "MMMM yyyy")
                        color: Theme.purple
                        font.pixelSize: Constants.sizeSm + 1
                        font.bold: true
                        font.capitalization: Font.Capitalize
                    }

                    transform: Translate {
                        id: monthTranslate

                        x: 0
                    }

                }

                RowLayout {
                    spacing: 4

                    IconButton {
                        icon: "󰁍"
                        iconSize: Constants.sizeSm
                        onClicked: root.prevMonth()
                    }

                    IconButton {
                        icon: "󱨰"
                        iconSize: Constants.sizeSm
                        iconColor: Theme.purple
                        onClicked: root.jumpToToday()
                    }

                    IconButton {
                        icon: "󰁔"
                        iconSize: Constants.sizeSm
                        onClicked: root.nextMonth()
                    }

                    IconButton {
                        icon: "󰸗"
                        iconSize: Constants.sizeSm
                        iconColor: Theme.cyan
                        onClicked: {
                            gnomeCalendarProc.running = false;
                            gnomeCalendarProc.running = true;
                            root.isOpen = false;
                        }
                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.05)
            }

            ColumnLayout {
                id: gridContainer

                spacing: Constants.sizeXs

                RowLayout {
                    Layout.fillWidth: true

                    Repeater {
                        model: ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

                        ThemedText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            color: index === 0 || index === 6 ? Theme.red : Theme.muted
                            font.pixelSize: Constants.sizeSm - 1
                            font.bold: true
                        }

                    }

                }

                GridLayout {
                    id: daysGrid

                    columns: 7
                    rowSpacing: Constants.sizeXs
                    columnSpacing: Constants.sizeXs

                    Repeater {
                        model: {
                            let offset = root.firstDayOffset(root.currentMonth, root.currentYear);
                            let days = root.daysInMonth(root.currentMonth, root.currentYear);
                            return Math.ceil((offset + days) / 7) * 7;
                        }

                        delegate: Rectangle {
                            property int dayOffset: root.firstDayOffset(root.currentMonth, root.currentYear)
                            property int daysInThisMonth: root.daysInMonth(root.currentMonth, root.currentYear)
                            property int prevMonthDays: root.daysInMonth(root.currentMonth - 1, root.currentYear)
                            property int dayNum: {
                                if (index < dayOffset)
                                    return prevMonthDays - dayOffset + index + 1;

                                if (index < dayOffset + daysInThisMonth)
                                    return index - dayOffset + 1;

                                return index - (dayOffset + daysInThisMonth) + 1;
                            }
                            property bool isCurrentMonth: index >= dayOffset && index < dayOffset + daysInThisMonth
                            property bool isToday: {
                                let today = new Date();
                                return isCurrentMonth && dayNum === today.getDate() && root.currentMonth === today.getMonth() && root.currentYear === today.getFullYear();
                            }

                            Layout.preferredWidth: Constants.sizeSm * 2
                            Layout.preferredHeight: Constants.sizeSm * 2
                            radius: Constants.sizeSm
                            color: isToday ? Theme.purple : "transparent"

                            Rectangle {
                                anchors.fill: parent
                                radius: Constants.sizeSm
                                color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.05)
                                visible: !isToday && isCurrentMonth && dayHover.containsMouse
                            }

                            ThemedText {
                                anchors.centerIn: parent
                                text: isCurrentMonth ? dayNum : ""
                                color: isToday ? Theme.bg : (isCurrentMonth ? Theme.fg : "transparent")
                                font.pixelSize: Constants.sizeSm
                                font.bold: isToday
                            }

                            MouseArea {
                                id: dayHover

                                anchors.fill: parent
                                hoverEnabled: isCurrentMonth
                                enabled: isCurrentMonth
                            }

                        }

                    }

                }

                transform: Translate {
                    id: daysTranslate

                    x: 0
                }

            }

        }

    }

}
