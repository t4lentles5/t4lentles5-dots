import QtQuick
pragma Singleton

QtObject {
    property string activePopup: ""
    property string packageManagerMode: "install"
    property bool isSystemUpdating: false

    signal togglePopup(string popupId)
    signal openPopup(string popupId)
}
