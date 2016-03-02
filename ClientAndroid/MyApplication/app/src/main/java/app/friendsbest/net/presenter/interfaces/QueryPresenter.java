package app.friendsbest.net.presenter.interfaces;

import java.util.List;

import app.friendsbest.net.data.model.Query;

public interface QueryPresenter extends BasePresenter<List<Query>> {

    void onStart();
    void getQueryHistory();
}
