package app.friendsbest.net.presenter;

import android.content.Context;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.List;

import app.friendsbest.net.data.model.Friend;
import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.BasePresenter;
import app.friendsbest.net.ui.fragment.ProfileFragment;

public class ProfilePresenter {

    private ProfileFragment _view;
    private String _token;

    private BasePresenter<List<Friend>> _friendPresenter = new BasePresenter<List<Friend>>() {
        @Override
        public void sendToPresenter(List<Friend> responseData) {
            processFriends(responseData);
        }
    };

    private BasePresenter<List<Recommendation>> _recommendationPresenter = new BasePresenter<List<Recommendation>>() {
        @Override
        public void sendToPresenter(List<Recommendation> responseData) {
            processRecommendations(responseData);
        }
    };

    public ProfilePresenter(ProfileFragment fragment, Context context) {
        _view = fragment;
        _token = PreferencesUtility.getInstance(context).getToken();
        onStart();
    }

    private void onStart() {
        getRecommendations();
        getFriends();
    }

    private void getRecommendations() {
        BaseRepository recRepository = new BaseRepository(
                        _recommendationPresenter,
                        _token
                );
        recRepository.getRecommendations();
    }

    private void getFriends() {
        BaseRepository friendRepository = new BaseRepository(
                        _friendPresenter,
                        _token
                        );
        friendRepository.getFriends();
    }

    private void processFriends(List<Friend> friends) {
        if (friends != null && friends.size() > 0) {
            _view.setFriendsCount(friends.size());
            Type type = new TypeToken<List<Friend>>(){}.getType();
            String serializedList = new Gson().toJson(friends, type);
            _view.saveFriendsList(serializedList);
        }
    }

    private void processRecommendations(List<Recommendation> recommendations) {
        if (recommendations != null && recommendations.size() > 0) {
            _view.setRecommendationsCount(recommendations.size());
            Type type = new TypeToken<List<Recommendation>>(){}.getType();
            String serializedList = new Gson().toJson(recommendations, type);
            _view.saveRecommendationsList(serializedList);
        }
    }
}
