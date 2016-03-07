package app.friendsbest.net.presenter;

import android.content.Context;

import java.util.List;

import app.friendsbest.net.data.model.Friend;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.ListFragmentPresenter;

public class FriendPresenter implements ListFragmentPresenter<List<Friend>> {

    BaseRepository _repository;

    public FriendPresenter(Context context) {
        _repository = new BaseRepository(this, PreferencesUtility.getInstance(context).getToken());
    }

    @Override
    public void getData() {
        _repository.getFriends();
    }

    @Override
    public void getData(List<Friend> content) {
        getData();
    }

    @Override
    public void sendToPresenter(List<Friend> responseData) {

    }
}
