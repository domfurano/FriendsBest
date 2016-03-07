package app.friendsbest.net.presenter.interfaces;

import java.util.List;

import app.friendsbest.net.data.model.Recommendation;

public interface RecommendPresenter extends BasePresenter<List<Recommendation>> {
    void submitRecommendation(String title, String tags, String comment, String type);
}
