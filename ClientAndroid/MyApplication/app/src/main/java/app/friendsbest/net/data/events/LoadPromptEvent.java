package app.friendsbest.net.data.events;

import java.util.List;

import app.friendsbest.net.data.model.PromptCard;

public class LoadPromptEvent extends BaseLoadEvent<PromptCard> {

    public LoadPromptEvent(List<PromptCard> events) {
        super(events);
    }
}
