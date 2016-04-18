package app.friendsbest.net.ui;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;
import com.facebook.Profile;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import app.friendsbest.net.R;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.AppLoginPresenter;
import app.friendsbest.net.ui.view.LoginView;

public class LoginActivity extends AppCompatActivity implements LoginView {

    private CoordinatorLayout _coordinatorLayout;
    private AppLoginPresenter _presenter;
    private CallbackManager _callbackManager;
    private LoginButton _loginButton;
    private Map<String, String> _facebookTokenMap;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(R.style.AppLoginTheme);
        FacebookSdk.sdkInitialize(getApplicationContext());
        setContentView(R.layout.activity_login);

        _callbackManager = CallbackManager.Factory.create();
        _loginButton = (LoginButton) findViewById(R.id.login_button);
        _loginButton.setReadPermissions(Arrays.asList("public_profile", "email", "user_friends"));

        _coordinatorLayout = (CoordinatorLayout) findViewById(R.id.login_coordinator_layout);
        _facebookTokenMap = new HashMap<>();
        _presenter = new AppLoginPresenter(this, getApplicationContext());
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        _callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void startMainView() {
        startActivity(new Intent(LoginActivity.this, DualFragmentActivity.class));
        finish();
    }

    @Override
    public void registerFacebookCallback() {
        _loginButton.registerCallback(_callbackManager, new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(LoginResult loginResult) {
                AccessToken accessToken = loginResult.getAccessToken();
                _facebookTokenMap.put(PreferencesUtility.FACEBOOK_TOKEN_KEY, accessToken.getToken());
                _presenter.getAuthToken(_facebookTokenMap);
            }

            @Override
            public void onCancel() {
                Log.i("Facebook Login", "user canceled");
            }

            @Override
            public void onError(FacebookException error) {
                Log.e("Login Error", error.toString(), error);
            }
        });
    }

    @Override
    public void hideLoginButton() {
        _loginButton.setVisibility(View.INVISIBLE);
    }

    @Override
    public void showLoginButton() {
        _loginButton.setVisibility(View.VISIBLE);
    }

    @Override
    public void getUserProfile() {
        _presenter.saveFacebookProfile(Profile.getCurrentProfile());
    }

    @Override
    public void forceLogout() {
        AccessToken currentToken = AccessToken.getCurrentAccessToken();
        if (currentToken != null) {
            new GraphRequest(
                    currentToken,
                    "/me/permissions/",
                    null,
                    HttpMethod.DELETE,
                    new GraphRequest.Callback() {
                        @Override
                        public void onCompleted(GraphResponse response) {
                            LoginManager.getInstance().logOut();
                        }
                    }).executeAsync();
        }
    }

    @Override
    public void displayMessage(String message) {
        Snackbar snackbar = Snackbar.make(_coordinatorLayout,
                message, Snackbar.LENGTH_LONG);
        snackbar.show();
    }
}
