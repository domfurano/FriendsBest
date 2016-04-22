package app.friendsbest.net.data.events;

public class LoadNotificationEvent {
    private int _notificationCount;

    public LoadNotificationEvent(int count) {
        _notificationCount = count;
    }

    public boolean hasNewNotification() {
        return _notificationCount > 0;
    }

    public int getNotificationCount() {
        return _notificationCount;
    }
}
