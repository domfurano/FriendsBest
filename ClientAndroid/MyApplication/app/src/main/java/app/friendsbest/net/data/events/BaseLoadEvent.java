package app.friendsbest.net.data.events;

import java.util.List;

public abstract class BaseLoadEvent<T> {

    private final List<T> _eventList;

    public BaseLoadEvent(List<T> events) {
        _eventList = events;
    }

    public List<T> getEventList() {
        return _eventList;
    }
}
