package app.friendsbest.net.presenter;

import android.content.Context;

import com.squareup.otto.Subscribe;

import java.util.List;

import app.friendsbest.net.data.events.LoadQueryEvent;
import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.data.utilities.BusProvider;
import app.friendsbest.net.data.utilities.PreferencesUtility;
import app.friendsbest.net.data.utilities.Repository;
import app.friendsbest.net.presenter.interfaces.ListPresenter;
import app.friendsbest.net.ui.view.FragmentView;

public class QueryHistoryPresenter implements ListPresenter<List<Query>> {

    private FragmentView _view;
    private Repository _repository;

    public QueryHistoryPresenter(FragmentView view, Context context){
        _view = view;
        _repository = new Repository(PreferencesUtility.getInstance(context).getToken(), BusProvider.getInstance());
    }

    @Subscribe
    public void onQueriesLoaded(LoadQueryEvent event) {
        _view.hideProgressBar();
        _view.displayContent(event.getEventList());    }

    @Override
    public void getData() {
        _repository.getQueries();
    }

    @Override
    public void onPause() {
        BusProvider.getInstance().unregister(this);
    }

    @Override
    public void onResume() {
        _view.showProgressBar();
        BusProvider.getInstance().register(this);
        getData();
    }
}
