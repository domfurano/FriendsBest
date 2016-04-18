package app.friendsbest.net.presenter;

import android.content.Context;

import com.facebook.Profile;

import java.util.Map;

import app.friendsbest.net.data.services.Repository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.LoginPresenter;
import app.friendsbest.net.ui.view.LoginView;

public class AppLoginPresenter implements LoginPresenter {

    private LoginView _loginView;
    private PreferencesUtility _preferencesUtility;
    private Repository _repository;

    public AppLoginPresenter(LoginView loginView, Context context){
        _loginView = loginView;
        _preferencesUtility = PreferencesUtility.getInstance(context);
        onStart();
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
            _repository = new Repository(this, token);
            _repository.checkLoginStatus();
        }
        else {
            _loginView.showLoginButton();
            _repository = new Repository(this, null);
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
                    onLoginFail();
                }
            }
        }
        else {
            onLoginFail();
        }
    }
}
