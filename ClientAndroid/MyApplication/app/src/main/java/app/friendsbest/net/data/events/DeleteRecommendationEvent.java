package app.friendsbest.net.data.events;

public class DeleteRecommendationEvent {

    private final int _recommendationId;

    public DeleteRecommendationEvent(int id) {
        _recommendationId = id;
    }

    public int getRecommendationId() {
        return _recommendationId;
    }
}
