package app.friendsbest.net.presenter.interfaces;

import java.util.List;

import app.friendsbest.net.data.model.UserRecommendation;

public interface RecommendPresenter extends BasePresenter<UserRecommendation> {
    void sendToPresenter(List<UserRecommendation> recommendations);
}
