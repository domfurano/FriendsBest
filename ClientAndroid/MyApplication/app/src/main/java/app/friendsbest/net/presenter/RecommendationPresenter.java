package app.friendsbest.net.presenter;

import android.content.Context;

import com.squareup.otto.Bus;
import com.squareup.otto.Subscribe;

import app.friendsbest.net.data.events.DeleteRecommendationEvent;
import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.utilities.BusProvider;
import app.friendsbest.net.data.utilities.PreferencesUtility;
import app.friendsbest.net.data.utilities.Repository;
import app.friendsbest.net.presenter.interfaces.BasePresenter;
import app.friendsbest.net.ui.fragment.RecommendationFragment;

public class RecommendationPresenter implements BasePresenter<Integer> {

    private RecommendationFragment _view;
    private Repository _repository;
    private Bus _bus;


    public RecommendationPresenter(Context context, RecommendationFragment view) {
        _view = view;
        _bus = BusProvider.getInstance();
        _repository = new Repository(PreferencesUtility.getInstance(context).getToken(), _bus);
    }

    public void deleteRecommendation(Recommendation recommendation) {
        _repository.deleteRecommendation(recommendation.getId());
    }

    @Subscribe
    public void onDeleteRecommendation(DeleteRecommendationEvent event) {
        _view.removeRecommendationItem(event.getRecommendationId());
    }

    @Override
    public void onPause() {
        _bus.unregister(this);
    }

    @Override
    public void onResume() {
        _bus.register(this);
    }
}
