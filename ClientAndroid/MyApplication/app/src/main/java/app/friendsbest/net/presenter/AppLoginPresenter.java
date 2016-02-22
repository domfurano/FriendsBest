package app.friendsbest.net.presenter;

import android.content.Context;

import com.facebook.CallbackManager;
import com.facebook.login.widget.LoginButton;
import com.google.gson.Gson;

import java.util.Map;

import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.data.model.UserProfile;
import app.friendsbest.net.presenter.interfaces.LoginPresenter;
import app.friendsbest.net.view.LoginView;

public class AppLoginPresenter implements LoginPresenter {

    private LoginView _loginView;
    private PreferencesUtility _preferencesUtility;
    private CallbackManager _callbackManager;
    private BaseRepository _repository;

    public AppLoginPresenter(LoginView loginView, Context context){
        _loginView = loginView;
        _preferencesUtility = PreferencesUtility.getInstance(context);
        onStart();
    }

    @Override
    public void onStart() {
        _callbackManager = CallbackManager.Factory.create();
        if (getLoginStatus())
            _loginView.goToMainView();
        else {
            _repository = new BaseRepository(this, null);
            LoginButton loginButton = _loginView.registerFacebookCallback();
            loginButton.registerCallback(_callbackManager, _repository);
        }
    }

    @Override
    public void onUserLogin() {
        _loginView.goToMainView();
    }

    @Override
    public void onLoginFail() {
        _loginView.displayMessage("Error, unable to log in.");
    }

    @Override
    public boolean getLoginStatus() {
        String token = _preferencesUtility.getToken();
        return token != null;
    }

    @Override
    public void sendToPresenter(Map<String, String> responseData) {
        if (responseData != null) {
            String value;
            if ((value = responseData.get(PreferencesUtility.ACCESS_TOKEN_KEY)) != null){
                _preferencesUtility.saveToken(value);
            }
            else if ((value = responseData.get(PreferencesUtility.USER_PROFILE_KEY)) != null) {
                UserProfile profile = new Gson().fromJson(value, UserProfile.class);
                _preferencesUtility.saveUserName(profile.getFullName());
            }
            else if (responseData.containsKey(PreferencesUtility.FACEBOOK_TOKEN_KEY)) {
                _repository.getAuthToken(responseData);
            }
        }
    }
}
