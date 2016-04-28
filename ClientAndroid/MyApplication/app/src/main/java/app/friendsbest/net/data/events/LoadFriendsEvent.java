package app.friendsbest.net.data.events;

import java.util.List;

import app.friendsbest.net.data.model.Friend;

public class LoadFriendsEvent extends BaseLoadEvent<Friend> {

    public LoadFriendsEvent(List<Friend> events) {
        super(events);
    }
}
