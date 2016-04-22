package app.friendsbest.net.presenter;

import android.content.Context;

import com.facebook.Profile;
import com.squareup.otto.Bus;
import com.squareup.otto.Subscribe;

import java.util.Map;

import app.friendsbest.net.data.events.LoginEvent;
import app.friendsbest.net.data.utilities.BusProvider;
import app.friendsbest.net.data.utilities.Repository;
import app.friendsbest.net.data.utilities.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.LoginPresenter;
import app.friendsbest.net.ui.view.LoginView;

public class AppLoginPresenter implements LoginPresenter {

    private LoginView _loginView;
    private PreferencesUtility _preferencesUtility;
    private Repository _repository;
    private Bus _bus;

    public AppLoginPresenter(LoginView loginView, Context context){
        _loginView = loginView;
        _bus = BusProvider.getInstance();
        _preferencesUtility = PreferencesUtility.getInstance(context);
    }

    @Override
    public void onStart() {
        _loginView.hideLoginButton();
        checkLoginStatus();
    }

    @Override
    public void onUserLogin() {
        _loginView.startMainView();
    }

    @Override
    public void onLoginFail() {
        _loginView.displayMessage("Error, unable to log in.");
        _loginView.showLoginButton();
        _preferencesUtility.deleteStoredData();
        _loginView.forceLogout();
    }

    @Override
    public void checkLoginStatus() {
        String token = _preferencesUtility.getToken();
        if (token != null) {
            _repository = new Repository(token, _bus);
            _repository.checkLoginStatus();
        }
        else {
            _loginView.showLoginButton();
            _repository = new Repository(_bus);
            _loginView.registerFacebookCallback();
        }
    }

    @Override
    public void getAuthToken(Map<String, String> facebookToken) {
        _repository.getAuthToken(facebookToken);
    }

    public void saveFacebookProfile(Profile profile) {
        _preferencesUtility.saveProfilePicture(profile.getProfilePictureUri(300, 300).toString());
        _preferencesUtility.saveUserName(profile.getName());
    }

    @Subscribe
    public void onLoadLoginEvent(LoginEvent event) {
        if (event != null) {
            if (event.isAccessTokenKey()) {
                _preferencesUtility.saveToken(event.getKeyValue());
                _loginView.getUserProfile();
                onUserLogin();
            } else if (event.isFacebookToken()) {
                _repository.getAuthToken(event.getLoginEvent());
            } else if (event.isLoginValidityKey()) {
                if (event.getKeyValue().equals(PreferencesUtility.VALID)) {
                    _loginView.startMainView();
                } else {
                    onLoginFail();
                }
            }
        }
        else {
            onLoginFail();
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
