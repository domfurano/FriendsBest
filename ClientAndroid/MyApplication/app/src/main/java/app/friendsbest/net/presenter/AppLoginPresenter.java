package app.friendsbest.net.presenter;

import android.content.Context;

import com.facebook.Profile;

import java.util.Map;

import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.LoginPresenter;
import app.friendsbest.net.ui.view.LoginView;

public class AppLoginPresenter implements LoginPresenter {

    private LoginView _loginView;
    private PreferencesUtility _preferencesUtility;
    private BaseRepository _repository;

    public AppLoginPresenter(LoginView loginView, Context context){
        _loginView = loginView;
        _preferencesUtility = PreferencesUtility.getInstance(context);
        onStart();
    }

    @Override
    public void onStart() {
        checkLoginStatus();
    }

    @Override
    public void onUserLogin() {
        _loginView.startMainView();
    }

    @Override
    public void onLoginFail() {
        _loginView.displayMessage("Error, unable to log in.");
    }

    @Override
    public void checkLoginStatus() {
        String token = _preferencesUtility.getToken();
        if (token != null) {
            _repository = new BaseRepository(this, token);
            _repository.getFriends();
        }
        else {
            _repository = new BaseRepository(this, null);
            _loginView.registerFacebookCallback();
        }
    }

    @Override
    public void sendToPresenter(Map<String, String> responseData) {
        if (responseData != null) {
            String value;
            if ((value = responseData.get(PreferencesUtility.ACCESS_TOKEN_KEY)) != null){
                _preferencesUtility.saveToken(value);
                _loginView.getUserProfile();
                onUserLogin();
            }
            else if (responseData.containsKey(PreferencesUtility.FACEBOOK_TOKEN_KEY)) {
                _repository.getAuthToken(responseData);
            }
            else if ((value = responseData.get(PreferencesUtility.LOGIN_VALIDITY_KEY)) != null) {
                if (value.equals(PreferencesUtility.VALID)) {
                    _loginView.startMainView();
                }
                else {
                    _preferencesUtility.deleteStoredData();
                    _repository = null;
                    onStart();
                }
            }
        }
        else {
            onLoginFail();
        }
    }

    public void saveFacebookProfile(Profile profile) {
        _preferencesUtility.saveProfilePicture(profile.getProfilePictureUri(50, 80).toString());
        _preferencesUtility.saveUserName(profile.getName());
    }
}
