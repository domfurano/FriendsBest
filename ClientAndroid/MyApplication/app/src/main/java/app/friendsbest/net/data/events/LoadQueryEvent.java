package app.friendsbest.net.data.events;

import java.util.List;

import app.friendsbest.net.data.model.Query;

public class LoadQueryEvent extends BaseLoadEvent<Query> {

    public LoadQueryEvent(List<Query> events) {
        super(events);
    }
}
