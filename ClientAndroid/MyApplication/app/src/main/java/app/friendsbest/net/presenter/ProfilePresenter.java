package app.friendsbest.net.presenter;

import android.content.Context;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.squareup.otto.Bus;
import com.squareup.otto.Subscribe;

import java.lang.reflect.Type;
import java.util.List;

import app.friendsbest.net.data.events.LoadFriendsEvent;
import app.friendsbest.net.data.events.LoadRecommendationEvent;
import app.friendsbest.net.data.model.Friend;
import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.utilities.BusProvider;
import app.friendsbest.net.data.utilities.PreferencesUtility;
import app.friendsbest.net.data.utilities.Repository;
import app.friendsbest.net.presenter.interfaces.BasePresenter;
import app.friendsbest.net.ui.fragment.ProfileFragment;

public class ProfilePresenter implements BasePresenter {

    private ProfileFragment _view;
    private Repository _repository;
    private Bus _bus;

    public ProfilePresenter(ProfileFragment fragment, Context context) {
        _bus = BusProvider.getInstance();
        _view = fragment;
        String token = PreferencesUtility.getInstance(context).getToken();
        _repository = new Repository(token, _bus);
    }

    private void onStart() {
        getRecommendations();
        getFriends();
    }

    private void getRecommendations() {
        _repository.getRecommendations();
    }

    private void getFriends() {
        _repository.getFriends();
    }

    @Subscribe
    public void processFriends(LoadFriendsEvent event) {
        List<Friend> friends = event.getEventList();
        if (friends.size() > 0) {
            _view.setFriendsCount(friends.size());
            Type type = new TypeToken<List<Friend>>() {
            }.getType();
            String serializedList = new Gson().toJson(friends, type);
            _view.saveFriendsList(serializedList);
        }
    }

    @Subscribe
    public void processRecommendations(LoadRecommendationEvent event) {
        List<Recommendation> recommendations = event.getEventList();
        if (recommendations.size() > 0) {
            _view.setRecommendationsCount(recommendations.size());
            Type type = new TypeToken<List<Recommendation>>() {
            }.getType();
            String serializedList = new Gson().toJson(recommendations, type);
            _view.saveRecommendationsList(serializedList);
        }
    }

    @Override
    public void onPause() {
        _bus.unregister(this);
    }

    @Override
    public void onResume() {
        _bus.register(this);
        onStart();
    }
}
