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
            console.log("NOTREACH: Received notification via DBus: " + notification.summary);
            notificationObjects[notification.id] = notification;
            notification.tracked = true;
            let data = {
                "id": notification.id,
                "summary": notification.summary ? notification.summary : "",
                "body": notification.body ? notification.body : "",
                "appName": notification.appName ? notification.appName : "Unknown APP",
                "icon": notification.appIcon ? notification.appIcon : "",
                "image": notification.image ? notification.image : "",
                "progress": 1
            };
            historyListModel.insert(0, data);
            if (!dndEnabled)
                activeListModel.insert(0, data);

        }
    }

}
