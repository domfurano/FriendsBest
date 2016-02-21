package app.friendsbest.net;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.Arrays;
import java.util.HashMap;

import app.friendsbest.net.model.Response;
import app.friendsbest.net.model.UserProfile;

public class LoginActivity extends AppCompatActivity {

    // TODO: What happens if login fails? Handle user logging out.

    public static final String DEFAULT = "empty";
    private CoordinatorLayout _coordinatorLayout;
    private SharedPreferences _storedSessionData;
    private CallbackManager _callbackManager;
    private AccessToken _accessToken;
    private UserProfile _userProfile;
    private String _facebookToken;
    private String _djangoToken;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(getApplicationContext());
        setContentView(R.layout.activity_login);

        _storedSessionData = PreferenceManager.getDefaultSharedPreferences(this);
        String session = _storedSessionData.
                getString(UserProfile.ProfileKey.ACCESS_TOKEN.getKey(), DEFAULT);

        Log.i("Login Activity", session);

        // For stored session, redirect to main page.
        if (!session.equals(DEFAULT))  {
            Intent intent = new Intent(LoginActivity.this, MainActivity.class);
            intent.putExtra(UserProfile.ProfileKey.ACCESS_TOKEN.getKey(), session);
            startActivity(intent);
        }

        _coordinatorLayout = (CoordinatorLayout) findViewById(R.id.login_coordinator_layout);

        // If no stored data, retrieve and save session data
        _callbackManager = CallbackManager.Factory.create();
        LoginButton loginButton = (LoginButton) findViewById(R.id.login_button);
        loginButton.setReadPermissions(Arrays.asList("public_profile", "email", "user_friends"));

        loginButton.registerCallback(_callbackManager, new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(LoginResult loginResult) {
                _accessToken = loginResult.getAccessToken();
                _facebookToken = _accessToken.getToken();

                new GraphRequest(
                        _accessToken,
                        "/" + _accessToken.getUserId(),
                        null,
                        HttpMethod.GET,
                        new GraphRequest.Callback() {
                            @Override
                            public void onCompleted(GraphResponse response) {
                                _userProfile = new Gson().
                                        fromJson(response.
                                                        getJSONObject().
                                                        toString(),
                                                UserProfile.class);
                            }
                        }
                ).executeAsync();
                new TokenExchange().execute();
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
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        _callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    class TokenExchange extends AsyncTask<Void, Void, Response> {

        @Override
        protected Response doInBackground(Void... params) {
            Gson gson = new Gson();
            HashMap<String, String> exchangeTokenMap = new HashMap<>();
            exchangeTokenMap.put(UserProfile.ProfileKey.ACCESS_TOKEN.getKey(), _facebookToken);
            String serializedData = gson.toJson(exchangeTokenMap, new TypeToken<HashMap<String, String>>(){}.getType());
            return APIUtility.postRequest("facebook/", serializedData, null);
        }

        @Override
        protected void onPostExecute(Response response) {
            if (response != null && response.wasPosted()) {
                SharedPreferences.Editor editor = _storedSessionData.edit();
                Type type = new TypeToken<HashMap<String, String>>(){}.getType();
                HashMap<String, String> accessTokenMap =
                        new Gson().fromJson(response.getData(), type);
                _djangoToken = accessTokenMap.get("key");

                _userProfile.setFacebookToken(_facebookToken);
                _userProfile.setDjangoToken(_djangoToken);

                // Store facebook and django tokens
                editor.putString(UserProfile.ProfileKey.FACEBOOK_TOKEN.getKey(), _facebookToken);
                editor.putString(UserProfile.ProfileKey.ACCESS_TOKEN.getKey(), _djangoToken);
                editor.putString(UserProfile.ProfileKey.FULL_NAME.getKey(), _userProfile.getFullName());

                // Save data to local storage and redirect to main page
                editor.commit();
                Intent intent = new Intent(LoginActivity.this, MainActivity.class);
                intent.putExtra(UserProfile.ProfileKey.ACCESS_TOKEN.getKey(), _djangoToken);
                intent.putExtra("fullName", _userProfile.getFullName());
                startActivity(intent);
            }
            else {
                Snackbar snackbar = Snackbar.make(_coordinatorLayout,
                        "Error with logging you in to FriendsBest.", Snackbar.LENGTH_LONG);
                snackbar.show();
            }
        }
    }
}
