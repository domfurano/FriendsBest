package app.friendsbest.net.presenter.interfaces;

import app.friendsbest.net.data.model.QueryResult;

public interface Presenter extends BasePresenter<QueryResult> {
    void onStart(String startingClass);
}
