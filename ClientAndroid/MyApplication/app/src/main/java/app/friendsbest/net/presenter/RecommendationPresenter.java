package app.friendsbest.net.presenter;

import android.content.Context;
import android.content.SharedPreferences;

import java.util.List;

import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.model.RecommendationItem;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.data.services.Repository;
import app.friendsbest.net.presenter.interfaces.BasePresenter;
import app.friendsbest.net.ui.fragment.RecommendationFragment;
import app.friendsbest.net.ui.fragment.RecommendationItemFragment;
import app.friendsbest.net.ui.view.FragmentView;

public class RecommendationPresenter implements BasePresenter<Integer> {

    private RecommendationFragment _view;
    private Repository _repository;


    public RecommendationPresenter(Context context, RecommendationFragment view) {
        _view = view;
        _repository = new Repository(this, PreferencesUtility.getInstance(context).getToken());
    }

    public void deleteRecommendation(Recommendation recommendation) {
        _repository.deleteRecommendation(recommendation.getId());
    }

    @Override
    public void sendToPresenter(Integer deletedId) {
        _view.removeRecommendationItem(deletedId);
    }
}
