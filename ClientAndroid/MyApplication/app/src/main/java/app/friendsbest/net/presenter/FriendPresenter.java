package app.friendsbest.net.presenter;

import android.content.Context;

import com.squareup.otto.Bus;

import app.friendsbest.net.data.model.Friend;
import app.friendsbest.net.data.utilities.BusProvider;
import app.friendsbest.net.data.utilities.Repository;
import app.friendsbest.net.data.utilities.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.BasePresenter;
import app.friendsbest.net.ui.fragment.FriendFragment;

public class FriendPresenter implements BasePresenter<Boolean> {

    Repository _repository;
    FriendFragment _view;
    Bus _bus;

    public FriendPresenter(Context context, FriendFragment view) {
        _bus = BusProvider.getInstance();
        _repository = new Repository(PreferencesUtility.getInstance(context).getToken(), _bus);
        _view = view;
    }

    public void changeMuteState(Friend friend) {
        _repository.changeMuteState(friend);
    }

    @Override
    public void onPause() {
    }

    @Override
    public void onResume() {

    }
}
