package app.friendsbest.net.presenter;

import android.content.Context;

import app.friendsbest.net.data.model.Friend;
import app.friendsbest.net.data.services.Repository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.BasePresenter;
import app.friendsbest.net.ui.fragment.FriendFragment;

public class FriendPresenter implements BasePresenter<Boolean> {

    Repository _repository;
    FriendFragment _view;

    public FriendPresenter(Context context, FriendFragment view) {
        _repository = new Repository(this, PreferencesUtility.getInstance(context).getToken());
        _view = view;
    }

    public void changeMuteState(Friend friend) {
        _repository.changeMuteState(friend);
    }

    @Override
    public void sendToPresenter(Boolean responseData) {

    }
}
