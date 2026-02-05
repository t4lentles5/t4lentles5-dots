import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core

TopPopup {
    id: root

    property date currentDate: new Date()
    property int currentMonth: currentDate.getMonth()
    property int currentYear: currentDate.getFullYear()

    function daysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstDayOffset(month, year) {
        return new Date(year, month, 1).getDay();
    }

    function prevMonth() {
        if (currentMonth === 0) {
            currentMonth = 11;
            currentYear--;
        } else {
            currentMonth--;
        }
    }

    function nextMonth() {
        if (currentMonth === 11) {
            currentMonth = 0;
            currentYear++;
        } else {
            currentMonth++;
        }
    }

    implicitWidth: 360
    preferredHeight: mainCol.implicitHeight + (root.contentPadding * 2)
    backgroundColor: Theme.colBg

    ColumnLayout {
        id: mainCol
        width: parent.width
        spacing: 15

        // Tarjeta Superior: Mes y Navegación
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: Theme.colBgSecondary
            radius: 15

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15

                ColumnLayout {
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

                // Espaciador para empujar los botones a la derecha
                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 5
                    
                    Rectangle {
                        width: 30; height: 30; radius: 8
                        color: btnPrev.containsMouse ? Theme.colBgLighter : "transparent"
                        Text { anchors.centerIn: parent; text: "󰁍"; color: Theme.colFg; font.pixelSize: 16 }
                        MouseArea { id: btnPrev; anchors.fill: parent; hoverEnabled: true; onClicked: root.prevMonth() }
                    }

                    Rectangle {
                        width: 30; height: 30; radius: 8
                        color: btnToday.containsMouse ? Theme.colBgLighter : "transparent"
                        Text { anchors.centerIn: parent; text: "󰃭"; color: Theme.colPurple; font.pixelSize: 16 }
                        MouseArea { id: btnToday; anchors.fill: parent; hoverEnabled: true; onClicked: {
                            var now = new Date(); root.currentMonth = now.getMonth(); root.currentYear = now.getFullYear();
                        }}
                    }

                    Rectangle {
                        width: 30; height: 30; radius: 8
                        color: btnNext.containsMouse ? Theme.colBgLighter : "transparent"
                        Text { anchors.centerIn: parent; text: "󰁔"; color: Theme.colFg; font.pixelSize: 16 }
                        MouseArea { id: btnNext; anchors.fill: parent; hoverEnabled: true; onClicked: root.nextMonth() }
                    }
                }
            }
        }

        // Tarjeta Principal: Cuadrícula de días
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: gridContainer.implicitHeight + 30
            color: Theme.colBgSecondary
            radius: 20

            ColumnLayout {
                id: gridContainer
                anchors.centerIn: parent
                width: parent.width - 30
                spacing: 15

                // Días de la semana
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

                // Grid
                GridLayout {
                    columns: 7
                    rowSpacing: 5
                    columnSpacing: 5
                    Layout.fillWidth: true

                    Repeater {
                        // Calculamos los slots necesarios (múltiplos de 7)
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
                                if (index < dayOffset) return prevMonthDays - dayOffset + index + 1;
                                if (index < dayOffset + daysInThisMonth) return index - dayOffset + 1;
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
                                id: dayHover; 
                                anchors.fill: parent; 
                                hoverEnabled: isCurrentMonth; 
                                enabled: isCurrentMonth 
                            }
                        }
                    }
                }
            }
        }

        // Footer
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
                width: 6; height: 6; radius: 3; color: Theme.colGreen
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
