import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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

    implicitWidth: 360
    preferredHeight: mainCol.implicitHeight + (root.contentPadding * 2)
    animateHeight: true

    SequentialAnimation {
        id: monthTransitionAnim

        PropertyAction {
            target: root
            property: "isAnimating"
            value: true
        }

        ParallelAnimation {
            NumberAnimation {
                target: daysContainer
                property: "opacity"
                to: 0
                duration: 120
                easing.type: Easing.OutQuint
            }

            NumberAnimation {
                target: daysTranslate
                property: "x"
                to: 15 * root.animDirection
                duration: 120
                easing.type: Easing.OutQuint
            }

            NumberAnimation {
                target: monthLabelContainer
                property: "opacity"
                to: 0
                duration: 120
                easing.type: Easing.OutQuint
            }

            NumberAnimation {
                target: monthTranslate
                property: "x"
                to: 15 * root.animDirection
                duration: 120
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
                daysTranslate.x = -15 * root.animDirection;
                monthTranslate.x = -15 * root.animDirection;
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: daysContainer
                property: "opacity"
                to: 1
                duration: 300
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: daysTranslate
                property: "x"
                to: 0
                duration: 300
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: monthLabelContainer
                property: "opacity"
                to: 1
                duration: 300
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: monthTranslate
                property: "x"
                to: 0
                duration: 300
                easing.type: Easing.OutQuad
            }

        }

        PropertyAction {
            target: root
            property: "isAnimating"
            value: false
        }

    }

    ColumnLayout {
        id: mainCol

        width: parent.width
        spacing: 15

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: Theme.colBgSecondary
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15

                Item {
                    id: monthLabelContainer

                    Layout.fillWidth: true
                    Layout.preferredHeight: monthCol.implicitHeight

                    ColumnLayout {
                        id: monthCol

                        spacing: 0

                        Text {
                            text: new Date(root.currentYear, root.currentMonth, 1).toLocaleDateString(Qt.locale(), "MMMM")
                            color: Theme.colPurple
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            font.bold: true
                            font.capitalization: Font.Capitalize
                        }

                        Text {
                            text: root.currentYear
                            color: Theme.colMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }

                    }

                    transform: Translate {
                        id: monthTranslate

                        x: 0
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 5

                    IconButton {
                        icon: "󰁍"
                        onClicked: root.prevMonth()
                    }

                    IconButton {
                        icon: "󰃭"
                        iconColor: Theme.colPurple
                        onClicked: root.jumpToToday()
                    }

                    IconButton {
                        icon: "󰁔"
                        onClicked: root.nextMonth()
                    }

                }

            }

        }

        Rectangle {
            id: calendarBg

            Layout.fillWidth: true
            Layout.preferredHeight: gridContainer.implicitHeight + 30
            color: Theme.colBgSecondary
            radius: 8

            ColumnLayout {
                id: gridContainer

                anchors.top: parent.top
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 30
                spacing: 15

                RowLayout {
                    Layout.fillWidth: true

                    Repeater {
                        model: ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            color: index === 0 || index === 6 ? Theme.colRed : Theme.colCyan
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            opacity: 0.6
                        }

                    }

                }

                Item {
                    id: daysContainer

                    Layout.fillWidth: true
                    Layout.preferredHeight: daysGrid.implicitHeight

                    GridLayout {
                        id: daysGrid

                        anchors.fill: parent
                        columns: 7
                        rowSpacing: 5
                        columnSpacing: 5

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

                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                radius: 8
                                color: isToday ? Theme.colPurple : (isCurrentMonth && dayHover.containsMouse ? Theme.colBgLighter : "transparent")

                                Text {
                                    anchors.centerIn: parent
                                    text: isCurrentMonth ? dayNum : ""
                                    color: isToday ? Theme.colBg : (isCurrentMonth ? Theme.colFg : "transparent")
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
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

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuint
                }

            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            Text {
                text: Qt.formatDateTime(new Date(), "dddd, d MMMM")
                color: Theme.colCyan
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
                font.capitalization: Font.Capitalize
                Layout.fillWidth: true
            }

            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: Theme.colGreen
            }

            Text {
                text: "Today"
                color: Theme.colMuted
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }

        }

    }

}
