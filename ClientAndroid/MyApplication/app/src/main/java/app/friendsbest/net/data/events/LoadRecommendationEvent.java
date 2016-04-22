package app.friendsbest.net.data.events;

import java.util.List;

import app.friendsbest.net.data.model.Recommendation;

public class LoadRecommendationEvent extends BaseLoadEvent<Recommendation> {

    public LoadRecommendationEvent(List<Recommendation> events) {
        super(events);
    }
}
