import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core

IconButton {
    id: root

    property color activeColor: Theme.colYellow
    property bool active: false

    iconColor: Theme.colCyan
    hoverColor: Theme.colBgLighter
    Layout.preferredWidth: 40
    Layout.preferredHeight: 40
    iconSize: 20
    useText: false
    isActive: root.active
    baseColor: isActive ? activeColor : Theme.colBg

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.isActive ? Theme.colBg : (root.hovered ? Theme.colFg : root.iconColor)
        font.family: Theme.fontFamily
        font.pixelSize: root.iconSize

        Behavior on color {
            ColorAnimation {
                duration: 300
            }

        }

    }

}
