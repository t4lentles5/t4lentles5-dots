import QtQuick
pragma Singleton

QtObject {
    property string iconTheme: "file:///usr/share/icons/Tela-circle-dracula-dark/"
    property string deviceIconPath: iconTheme + "22/devices/"
    property string iconPath: iconTheme + "22/panel/"
    property string iconActionsPath: iconTheme + "22/actions/"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int sizeXs: 8
    property int sizeSm: 12
    property int sizeMd: 14
    property int sizeLg: 16
    property int sizeXl: 20
    property int animFast: 150
    property int animNormal: 250
    property int animSlow: 350
    property int wallpaperTransitionDelay: 1500
    property string fallbackIcon: iconActionsPath + "notifications.svg"
}
