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
    property int cornerRadius: 16
    property int contentPadding: 16
    default property alias content: innerLayout.data
    property int preferredHeight
    property int animationDuration: 300
    property color backgroundColor: Theme.colBg
    property bool animateHeight: false
    property bool _windowVisible: false
    readonly property int verticalOffset: 40
    readonly property int overscrollOffset: 100

    signal popupClosed()

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
    implicitHeight: (preferredHeight > 0 ? preferredHeight : (innerLayout.implicitHeight + root.contentPadding * 2)) + verticalOffset

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

    HoverHandler {
        onHoveredChanged: {
            if (hovered)
                autoCloseTimer.stop();
            else if (root.isOpen)
                autoCloseTimer.start();
        }
    }

    Item {
        id: container

        width: root.implicitWidth
        height: root.implicitHeight - verticalOffset
        y: root.isOpen ? 0 : -root.implicitHeight
        clip: true

        Rectangle {
            color: root.backgroundColor
            anchors.bottom: bg.top
            anchors.left: bg.left
            anchors.right: bg.right
            height: overscrollOffset
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

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: root.contentPadding + root.cornerRadius
                anchors.rightMargin: root.contentPadding + root.cornerRadius
                anchors.top: parent.top
                anchors.topMargin: root.contentPadding
                height: root.preferredHeight > 0 ? (root.preferredHeight - root.contentPadding * 2) : implicitHeight

                transform: Translate {
                    id: contentTranslate

                    y: root.isOpen ? 0 : -root.verticalOffset

                    Behavior on y {
                        NumberAnimation {
                            duration: root.animationDuration
                            easing.type: Easing.OutExpo
                        }

                    }

                }

            }

        }

        Behavior on y {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutExpo
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
