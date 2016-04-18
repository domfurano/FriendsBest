package app.friendsbest.net.presenter.interfaces;

import app.friendsbest.net.data.model.Recommendation;

public interface RecommendPresenter extends BasePresenter<Recommendation> {
    boolean validateDetail(String detail);
    boolean validateTags(String tags);
    void submitRecommendation(String title, String tags, String comment, String type);
}
