import QtQuick
import qs.Core

Rectangle {
    property var widget
    property alias text: layoutText.text
    property alias mouseArea: mouseArea
    property color textColor: Colors.fg
    property int horizontalPadding: Constants.sizeLg
    property int fontSize: Constants.sizeSm
    property bool isButton: true

    color: Colors.bgSecondary
    radius: Constants.sizeLg
    implicitWidth: layoutText.implicitWidth + (horizontalPadding * 2)
    implicitHeight: 32

    ThemedText {
        id: layoutText

        anchors.centerIn: parent
        color: textColor
        font.pixelSize: fontSize
        font.bold: true
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: isButton ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (widget)
                widget.isOpen = !widget.isOpen;

        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Constants.animNormal
        }

    }

}
