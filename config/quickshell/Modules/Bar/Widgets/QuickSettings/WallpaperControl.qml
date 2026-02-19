import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

QuickActionButton {
    id: root

    signal closeRequested()

    icon: ""
    iconColor: Theme.colRed
    onClicked: {
    }
}
