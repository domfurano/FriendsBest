package app.friendsbest.net.presenter;

import android.content.Context;

import com.squareup.otto.Bus;
import com.squareup.otto.Subscribe;

import app.friendsbest.net.data.model.QueryResult;
import app.friendsbest.net.data.utilities.BusProvider;
import app.friendsbest.net.data.utilities.Repository;
import app.friendsbest.net.data.utilities.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.ListPresenter;
import app.friendsbest.net.ui.view.FragmentView;

public class SolutionPresenter implements ListPresenter<QueryResult> {

    private Repository _repository;
    private FragmentView _solutionView;
    private Bus _bus;

    public SolutionPresenter(FragmentView view, Context context) {
        _solutionView = view;
        _bus = BusProvider.getInstance();
        _repository = new Repository(PreferencesUtility.getInstance(context).getToken(), _bus);
    }

    @Subscribe
    public void onLoadQueryResult(QueryResult solution) {
        _solutionView.hideProgressBar();
        if (solution != null)
            _solutionView.displayContent(solution);
    }

    @Override
    public void getData() {
        getData(null);
    }

    public void getData(QueryResult content) {
        _solutionView.showProgressBar();
        if (content != null)
            _repository.getQuery(content.getId());
    }

    @Override
    public void onPause() {
        _bus.unregister(this);
    }

    @Override
    public void onResume() {
        _solutionView.showProgressBar();
        _bus.register(this);

    }

    public void deleteSearch(int id) {
        _repository.deleteQuery(id);
    }
}
