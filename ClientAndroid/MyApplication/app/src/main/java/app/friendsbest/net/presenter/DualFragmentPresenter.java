package app.friendsbest.net.presenter;

import android.content.Context;
import android.os.Bundle;

import com.google.gson.Gson;

import app.friendsbest.net.data.model.QueryResult;
import app.friendsbest.net.data.services.Repository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.Presenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.fragment.SolutionFragment;
import app.friendsbest.net.ui.view.DualFragmentView;


public class DualFragmentPresenter implements Presenter {

    private DualFragmentView _dualFragmentView;
    private Repository _repository;


    public DualFragmentPresenter(DualFragmentView baseView, Context context){
        _dualFragmentView = baseView;
        _repository = new Repository(this, PreferencesUtility.getInstance(context).getToken());
    }

    public void setContentClass(String startingClass) {
        onStart(startingClass);
    }

    @Override
    public void onStart(String startingClass) {
        _dualFragmentView.setContentFragment(startingClass);
    }

    @Override
    public void sendToPresenter(QueryResult solution) {
        if (solution != null) {
            String solutionJson = new Gson().toJson(solution, QueryResult.class);
            String key = SolutionFragment.SOLUTION_TAGS;
            Bundle bundle = new Bundle();
            bundle.putInt(SolutionFragment.SOLUTION_ID_TAG, solution.getId());
            bundle.putString(key, solutionJson);
            _dualFragmentView.onFragmentChange(DualFragmentActivity.VIEW_SOLUTION_ID, bundle);
        }
    }
}

