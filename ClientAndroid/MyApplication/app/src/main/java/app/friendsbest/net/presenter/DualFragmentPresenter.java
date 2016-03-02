package app.friendsbest.net.presenter;

import android.content.Context;
import android.os.Bundle;

import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import app.friendsbest.net.data.model.QueryResult;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.Presenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.fragment.SolutionFragment;
import app.friendsbest.net.ui.view.DualFragmentView;


public class DualFragmentPresenter implements Presenter {

    private DualFragmentView _dualFragmentView;
    private BaseRepository _repository;


    public DualFragmentPresenter(DualFragmentView baseView, Context context){
        _dualFragmentView = baseView;
        _repository = new BaseRepository(this, PreferencesUtility.getInstance(context).getToken());
    }

    public void setContentClass(String startingClass, String payload) {
        onStart(startingClass, payload);
    }

    @Override
    public void onStart(String startingClass, String payload) {
        if (payload != null) {
            if (startingClass.equals(DualFragmentActivity.SEARCH_HISTORY_ID)) {
                submitQuery(payload);
            }
            else if (startingClass.equals(DualFragmentActivity.ADD_RECOMMENDATION_ID)) {

            }
        }
        _dualFragmentView.setContentFragment(startingClass);
        _dualFragmentView.setNavigationFragment(DualFragmentActivity.NAVIGATION_ID);
    }

    private void submitQuery(String payload) {
        String[] tags = payload.split("\\s|,");
        List<String> tagsList = new ArrayList<>();
        HashMap<String, List<String>> tagsMap = new HashMap<>();
        for(String tag : tags) {
            tagsList.add(tag.trim());
        }

        tagsMap.put("tags", tagsList);
        _repository.postQuery(tagsMap);
    }

    @Override
    public void sendToPresenter(QueryResult solution) {
        String solutionJson = new Gson().toJson(solution, QueryResult.class);
        String key = SolutionFragment.SOLUTION_TAGS;
        Bundle bundle = new Bundle();
        bundle.putString(key, solutionJson);
        _dualFragmentView.onFragmentChange(DualFragmentActivity.VIEW_SOLUTION_ID, bundle);
    }
}

