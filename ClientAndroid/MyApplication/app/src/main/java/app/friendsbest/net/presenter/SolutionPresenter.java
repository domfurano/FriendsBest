package app.friendsbest.net.presenter;

import android.content.Context;

import app.friendsbest.net.data.model.QueryResult;
import app.friendsbest.net.data.services.Repository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.ListPresenter;
import app.friendsbest.net.ui.view.FragmentView;

public class SolutionPresenter implements ListPresenter<QueryResult> {

    private Repository _repository;
    private FragmentView _solutionView;

    public SolutionPresenter(FragmentView view, Context context) {
        _solutionView = view;
        _repository = new Repository(this, PreferencesUtility.getInstance(context).getToken());
    }

    @Override
    public void sendToPresenter(QueryResult solution) {
        _solutionView.hideProgressBar();
        if (solution != null)
            _solutionView.displayContent(solution);
    }

    @Override
    public void getData() {
        getData(null);
    }

    @Override
    public void getData(QueryResult content) {
        _solutionView.showProgressBar();
        if (content != null)
            _repository.getQuery(content.getId());
    }

    public void deleteSearch(int id) {
        _repository.deleteQuery(id);
    }
}
