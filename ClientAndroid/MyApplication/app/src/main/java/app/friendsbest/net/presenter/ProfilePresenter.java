package app.friendsbest.net.presenter;

import android.content.Context;

import java.util.List;

import app.friendsbest.net.data.model.Friend;
import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.BasePresenter;
import app.friendsbest.net.ui.fragment.ProfileFragment;

public class ProfilePresenter implements BasePresenter<List<Object>> {

    private ProfileFragment _view;
    private BaseRepository _repository;

    public ProfilePresenter(ProfileFragment fragment, Context context) {
        _view = fragment;
        _repository = new BaseRepository(this, PreferencesUtility.getInstance(context).getToken());
        getCounts();
    }

    private void getCounts() {
        _repository.getFriends();
        _repository.getRecommendations();
    }

    @Override
    public void sendToPresenter(List<Object> responseData) {
        if (responseData != null && responseData.size() > 0) {
            Object obj = responseData.get(0);
            int size = responseData.size();
            if (obj instanceof Recommendation)
                _view.setRecommendationsCount(size);
            else if (obj instanceof Friend)
                _view.setFriendsCount(size);
        }
    }
}
