import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    property alias server: notificationServer
    property alias activeList: activeListModel
    property alias historyList: historyListModel
    property bool dndEnabled: false
    property int unreadCount: historyListModel.count
    property var notificationObjects: ({
    })

    function notify(summary, body, icon = "", appName = "System") {
        let timestamp = new Date().getTime();
        let data = {
            "id": timestamp,
            "summary": summary,
            "body": body,
            "appName": appName,
            "icon": icon,
            "image": "",
            "progress": 1,
            "timestamp": timestamp
        };
        historyListModel.insert(0, data);
        if (!dndEnabled)
            activeListModel.insert(0, data);

    }

    function dismissNotification(id) {
        let notification = notificationObjects[id];
        if (notification)
            notification.dismiss();

        removeNotification(id);
    }

    function removeNotification(id) {
        delete notificationObjects[id];
        for (var i = 0; i < activeListModel.count; i++) {
            if (activeListModel.get(i).id === id) {
                activeListModel.remove(i);
                break;
            }
        }
    }

    function clearHistory() {
        historyListModel.clear();
    }

    function removeHistoryItem(index) {
        if (index >= 0 && index < historyListModel.count)
            historyListModel.remove(index);

    }

    function updateNotificationData(notification) {
        let data = {
            "id": notification.id,
            "summary": notification.summary ? notification.summary : "",
            "body": notification.body ? notification.body : "",
            "appName": notification.appName ? notification.appName : "Unknown APP",
            "icon": notification.appIcon ? notification.appIcon : "",
            "image": notification.image ? notification.image : "",
            "progress": 1,
            "timestamp": new Date().getTime()
        };
        let historyUpdated = false;
        for (let i = 0; i < historyListModel.count; i++) {
            if (historyListModel.get(i).id === notification.id) {
                historyListModel.set(i, data);
                historyUpdated = true;
                break;
            }
        }
        if (!historyUpdated)
            historyListModel.insert(0, data);

        if (!dndEnabled) {
            let activeUpdated = false;
            for (let i = 0; i < activeListModel.count; i++) {
                if (activeListModel.get(i).id === notification.id) {
                    activeListModel.set(i, data);
                    activeUpdated = true;
                    break;
                }
            }
            if (!activeUpdated)
                activeListModel.insert(0, data);

        }
    }

    onDndEnabledChanged: {
        let timestamp = new Date().getTime();
        let data = {
            "id": timestamp,
            "summary": dndEnabled ? "󰂛 Do Not Disturb Enabled" : "󰂚 Do Not Disturb Disabled",
            "body": dndEnabled ? "Notifications are now silenced." : "Notifications will now be shown.",
            "appName": "System",
            "icon": "",
            "image": "",
            "progress": 1,
            "timestamp": timestamp
        };
        historyListModel.insert(0, data);
        activeListModel.insert(0, data);
    }

    ListModel {
        id: activeListModel
    }

    ListModel {
        id: historyListModel
    }

    NotificationServer {
        id: notificationServer

        keepOnReload: false
        imageSupported: true
        actionsSupported: true
        onNotification: (notification) => {
            notificationObjects[notification.id] = notification;
            notification.tracked = true;
            notification.closed.connect((reason) => {
                root.removeNotification(notification.id);
            });
            notification.summaryChanged.connect(() => {
                root.updateNotificationData(notification);
            });
            notification.bodyChanged.connect(() => {
                root.updateNotificationData(notification);
            });
            root.updateNotificationData(notification);
        }
    }

}
