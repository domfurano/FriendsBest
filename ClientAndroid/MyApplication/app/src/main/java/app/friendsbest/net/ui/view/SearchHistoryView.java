package app.friendsbest.net.ui.view;

import java.util.List;

import app.friendsbest.net.data.model.Query;

public interface SearchHistoryView {
    void displaySearchHistory(List<Query> queries);
    void showProgress();
    void hideProgress();
}
