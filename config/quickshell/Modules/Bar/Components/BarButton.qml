import QtQuick
import qs.Core

Rectangle {
    property var widget
    property alias text: layoutText.text
    property alias mouseArea: mouseArea
    property color textColor: Theme.fg
    property int horizontalPadding: Constants.sizeLg
    property int fontSize: Constants.sizeSm
    property bool isButton: true
    property color bgColor: Theme.bgSecondary
    property color hoverColor: textColor

    color: {
        if (!isButton || hoverColor.a === 0)
            return bgColor;

        if (mouseArea.containsPress)
            return bgColor.a === 0 ? Qt.rgba(textColor.r, textColor.g, textColor.b, 0.05) : Qt.tint(bgColor, Qt.rgba(textColor.r, textColor.g, textColor.b, 0.05));
        else if (mouseArea.containsMouse)
            return bgColor.a === 0 ? Qt.rgba(textColor.r, textColor.g, textColor.b, 0.1) : Qt.tint(bgColor, Qt.rgba(textColor.r, textColor.g, textColor.b, 0.1));
        return bgColor;
    }
    scale: isButton && mouseArea.containsPress ? 0.95 : 1
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

    Behavior on scale {
        NumberAnimation {
            duration: Constants.animFast
            easing.type: Easing.OutBack
        }

    }

}
