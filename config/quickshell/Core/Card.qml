import QtQuick
import qs.Core

Rectangle {
    id: root

    property bool clickable: false
    property bool hoverEnabled: clickable
    property bool highlighted: clickable
    property bool scaleOnPress: clickable
    property color highlightColor: Theme.purple
    property int cursorShape: clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
    readonly property bool containsMouse: mouseArea.containsMouse
    readonly property bool containsPress: mouseArea.containsPress

    signal clicked(var mouse)

    color: Theme.bgSecondary
    radius: Constants.sizeXs
    border.width: 1
    border.color: root.highlighted && root.containsMouse ? root.highlightColor : Theme.border
    scale: root.scaleOnPress && root.containsPress ? 0.98 : 1

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: root.hoverEnabled
        cursorShape: root.cursorShape
        onClicked: (mouse) => {
            return root.clicked(mouse);
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 150
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: 100
        }

    }

}
