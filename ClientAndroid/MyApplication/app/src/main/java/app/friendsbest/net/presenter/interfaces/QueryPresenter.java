package app.friendsbest.net.presenter.interfaces;

import java.util.List;

import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.data.model.QueryResult;

public interface QueryPresenter extends BasePresenter<QueryResult> {

    void onStart();
    void postQuery(Query query);
}
