import QtQuick
import qs.Core

Rectangle {
    id: root

    property bool outlined: false

    color: Theme.colBgSecondary
    radius: Theme.radiusSm
    border.color: outlined ? Theme.colBgSecondary : "transparent"
    border.width: outlined ? 2 : 0
    Component.onCompleted: {
        if (outlined)
            color = "transparent";

    }
}
