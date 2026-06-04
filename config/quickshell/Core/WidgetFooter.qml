import QtQuick
import QtQuick.Layouts

RowLayout {
    property string leftText: ""
    property var keyHints: []

    Layout.fillWidth: true
    Layout.preferredHeight: 18
    spacing: Constants.sizeXs

    ThemedText {
        text: leftText
        font.pixelSize: Constants.sizeSm
        color: Theme.muted
    }

    Item {
        Layout.fillWidth: true
    }

    RowLayout {
        spacing: Constants.sizeXs
        Layout.alignment: Qt.AlignVCenter

        Repeater {
            model: keyHints

            RowLayout {
                spacing: Constants.sizeXs

                KeyHint {
                    key: modelData.key
                    description: modelData.description
                }

                ThemedText {
                    text: "•"
                    font.pixelSize: Constants.sizeSm
                    color: Theme.muted
                    opacity: 0.5
                    visible: index < keyHints.length - 1
                }

            }

        }

    }

    component KeyHint: RowLayout {
        property string key
        property string description

        RowLayout {
            spacing: 4

            Rectangle {
                width: keyText.implicitWidth + Constants.sizeSm
                height: 16
                radius: 3
                color: Theme.bgSecondary
                border.color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.15)
                border.width: 1

                ThemedText {
                    id: keyText

                    anchors.centerIn: parent
                    text: key
                    font.pixelSize: 10
                    font.bold: true
                }

            }

            ThemedText {
                text: description
                font.pixelSize: Constants.sizeSm
                color: Theme.muted
            }

        }

    }

}
