package app.friendsbest.net.presenter;

import android.content.Context;

import java.util.List;

import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.QueryPresenter;
import app.friendsbest.net.ui.view.SearchHistoryView;

public class QueryHistoryPresenter implements QueryPresenter {

    private SearchHistoryView _view;
    private BaseRepository _repository;

    public QueryHistoryPresenter(SearchHistoryView view, Context context){
        _view = view;
        _repository = new BaseRepository(this, PreferencesUtility.getInstance(context).getToken());
        onStart();
    }

    @Override
    public void onStart() {
        _view.showProgress();
        getQueryHistory();
    }

    @Override
    public void getQueryHistory() {
        _repository.getQueries();
    }

    @Override
    public void sendToPresenter(List<Query> responseData) {
        if (responseData != null){
            _view.hideProgress();
            _view.displaySearchHistory(responseData);
        }
    }
}
