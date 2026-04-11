import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Widgets
import qs.Core

PopupWindow {
    id: root

    property string popupId: ""
    property bool isOpen: false
    property int cornerRadius: Constants.sizeLg
    property int contentPadding: Constants.sizeLg
    default property alias content: innerLayout.data
    property int preferredHeight
    property int animationDuration: Constants.animNormal
    property color backgroundColor: Colors.bg
    property bool animateHeight: false
    property bool _windowVisible: false
    readonly property int verticalOffset: Constants.sizeLg
    property int xPos: 0
    property int yPos: 0
    readonly property int slideDistance: (preferredHeight > 0 ? preferredHeight : implicitHeight) + verticalOffset

    signal popupClosed()

    implicitWidth: innerLayout.implicitWidth + (contentPadding + cornerRadius) * 2
    implicitHeight: innerLayout.implicitHeight + contentPadding * 2
    onIsOpenChanged: {
        if (popupId === "")
            return ;

        if (isOpen) {
            if (AppState.activePopup !== popupId)
                AppState.activePopup = popupId;

            closeDelayTimer.stop();
            _windowVisible = true;
        } else {
            if (AppState.activePopup === popupId)
                AppState.activePopup = "";

            closeDelayTimer.start();
            root.popupClosed();
        }
    }
    color: "transparent"
    visible: _windowVisible

    Connections {
        function onActivePopupChanged() {
            if (popupId !== "" && AppState.activePopup !== popupId)
                root.isOpen = false;

        }

        target: AppState
    }

    Timer {
        id: closeDelayTimer

        interval: root.animationDuration
        repeat: false
        onTriggered: root._windowVisible = false
    }

    Timer {
        id: autoCloseTimer

        interval: 500
        repeat: false
        onTriggered: root.isOpen = false
    }

    MouseArea {
        anchors.fill: parent
        onPressed: root.isOpen = false
    }

    Item {
        id: popupContainer

        width: root.implicitWidth
        height: root.isOpen ? root.slideDistance : 0
        clip: true

        HoverHandler {
            onHoveredChanged: {
                if (hovered)
                    autoCloseTimer.stop();
                else if (root.isOpen)
                    autoCloseTimer.start();
            }
        }

        Item {
            id: animContainer

            anchors.left: parent.left
            anchors.right: parent.right
            height: root.implicitHeight
            x: 0
            y: root.isOpen ? 0 : -height

            MouseArea {
                anchors.fill: parent
            }

            Rectangle {
                color: root.backgroundColor
                height: 1000
                anchors.bottom: bg.top
                anchors.left: bg.left
                anchors.right: bg.right
            }

            Shape {
                id: bg

                property color shapeColor: root.backgroundColor
                readonly property real r: root.cornerRadius
                readonly property real w: width
                readonly property real h: height

                anchors.fill: parent

                ShapePath {
                    strokeWidth: 0
                    strokeColor: "transparent"
                    fillColor: bg.shapeColor
                    startX: 0
                    startY: 0

                    PathArc {
                        relativeX: bg.r
                        relativeY: bg.r
                        radiusX: bg.r
                        radiusY: bg.r
                    }

                    PathLine {
                        relativeX: 0
                        relativeY: bg.h - (2 * bg.r)
                    }

                    PathQuad {
                        relativeX: bg.r
                        relativeY: bg.r
                        relativeControlX: 0
                        relativeControlY: bg.r
                    }

                    PathLine {
                        relativeX: bg.w - (4 * bg.r)
                        relativeY: 0
                    }

                    PathQuad {
                        relativeX: bg.r
                        relativeY: -bg.r
                        relativeControlX: bg.r
                        relativeControlY: 0
                    }

                    PathLine {
                        relativeX: 0
                        relativeY: -(bg.h - (2 * bg.r))
                    }

                    PathArc {
                        relativeX: bg.r
                        relativeY: -bg.r
                        radiusX: bg.r
                        radiusY: bg.r
                    }

                    PathLine {
                        relativeX: -bg.w
                        relativeY: 0
                    }

                }

                ColumnLayout {
                    id: innerLayout

                    x: root.contentPadding + root.cornerRadius
                    y: root.contentPadding
                    width: root.implicitWidth - (root.contentPadding + root.cornerRadius) * 2

                    transform: Translate {
                        id: contentTranslate

                        x: 0
                        y: root.isOpen ? 0 : -root.verticalOffset

                        Behavior on x {
                            NumberAnimation {
                                duration: root.animationDuration
                                easing.type: root.isOpen ? Easing.OutCubic : Easing.InCubic
                            }

                        }

                        Behavior on y {
                            NumberAnimation {
                                duration: root.animationDuration
                                easing.type: root.isOpen ? Easing.OutCubic : Easing.InCubic
                            }

                        }

                    }

                }

            }

            Behavior on x {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: root.isOpen ? Easing.OutCubic : Easing.InCubic
                }

            }

            Behavior on y {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: root.isOpen ? Easing.OutCubic : Easing.InCubic
                }

            }

        }

        Behavior on height {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: root.isOpen ? Easing.OutCubic : Easing.InCubic
            }

        }

    }

    Behavior on preferredHeight {
        enabled: root.animateHeight

        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutQuint
        }

    }

}
