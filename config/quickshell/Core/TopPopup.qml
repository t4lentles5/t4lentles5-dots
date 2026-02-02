import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Widgets
import qs.Core

PopupWindow {
    id: root

    property bool isOpen: false
    property int cornerRadius: 25
    property int contentPadding: 16
    default property alias content: innerLayout.data
    property int preferredHeight
    property int animationDuration: 250

    color: "transparent"
    visible: container.y !== -root.implicitHeight
    implicitHeight: (preferredHeight > 0 ? preferredHeight : (innerLayout.implicitHeight + root.contentPadding * 2)) + 40

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
        height: root.implicitHeight - 40
        y: -root.implicitHeight
        states: [
            State {
                name: "open"
                when: root.isOpen

                PropertyChanges {
                    target: container
                    y: 0
                }

            },
            State {
                name: "closed"
                when: !root.isOpen

                PropertyChanges {
                    target: container
                    y: -root.implicitHeight
                }

            }
        ]
        transitions: [
            Transition {
                from: "closed"
                to: "open"

                NumberAnimation {
                    properties: "y"
                    duration: root.animationDuration
                    easing.type: Easing.OutQuad
                }

            },
            Transition {
                from: "open"
                to: "closed"

                NumberAnimation {
                    properties: "y"
                    duration: root.animationDuration
                    easing.type: Easing.InQuad
                }

            }
        ]

        Rectangle {
            color: Theme.colBg
            anchors.bottom: bg.top
            anchors.left: bg.left
            anchors.right: bg.right
            height: 100
        }

        Shape {
            id: bg

            property color color: Theme.colBg
            readonly property real r: root.cornerRadius
            readonly property real w: width
            readonly property real h: height

            anchors.fill: parent

            ShapePath {
                strokeWidth: 0
                strokeColor: "transparent"
                fillColor: bg.color
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

            Rectangle {
                visible: false
                color: parent.color
                height: root.cornerRadius
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                z: 1
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
                states: [
                    State {
                        name: "open"
                        when: root.isOpen

                        PropertyChanges {
                            target: contentTranslate
                            y: 0
                        }

                    },
                    State {
                        name: "closed"
                        when: !root.isOpen

                        PropertyChanges {
                            target: contentTranslate
                            y: -root.implicitHeight
                        }

                    }
                ]
                transitions: [
                    Transition {
                        from: "closed"
                        to: "open"

                        NumberAnimation {
                            target: contentTranslate
                            property: "y"
                            duration: 350
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
                        }

                    },
                    Transition {
                        from: "open"
                        to: "closed"

                        NumberAnimation {
                            target: contentTranslate
                            property: "y"
                            duration: root.animationDuration
                            easing.type: Easing.InQuad
                        }

                    }
                ]

                transform: Translate {
                    id: contentTranslate

                    y: 0
                }

            }

        }

    }

}
