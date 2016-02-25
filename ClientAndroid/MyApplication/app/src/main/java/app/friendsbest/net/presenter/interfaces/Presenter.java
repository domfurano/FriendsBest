package app.friendsbest.net.presenter.interfaces;

import android.content.Context;

public interface Presenter {
    void onStart();
    void onHistoryClicked();
    void onProfileClicked();
    void onRecommendationClicked();
    void onQueryClicked(String query);
}
