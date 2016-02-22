package app.friendsbest.net.presenter.interfaces;

public interface Presenter {
    void onHistoryClicked();
    void onProfileClicked();
    void onSettingsClicked();
    void onRecommendationClicked();
    void onQueryClicked(String query);
}
