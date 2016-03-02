package app.friendsbest.net.presenter;

import android.content.Context;

import java.util.List;

import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.ListFragmentPresenter;
import app.friendsbest.net.ui.view.FragmentView;

public class QueryHistoryPresenter implements ListFragmentPresenter<List<Query>> {

    private FragmentView _view;
    private BaseRepository _repository;

    public QueryHistoryPresenter(FragmentView view, Context context){
        _view = view;
        _repository = new BaseRepository(this, PreferencesUtility.getInstance(context).getToken());
        onStart();
    }

    private void onStart() {
        _view.showProgressBar();
        getData();
    }


    @Override
    public void getData() {
        _repository.getQueries();
    }

    @Override
    public void getData(List<Query> content) {
        getData();
    }

    @Override
    public void sendToPresenter(List<Query> responseData) {
        _view.hideProgressBar();
        if (responseData != null)
            _view.displayContent(responseData);
    }

}
