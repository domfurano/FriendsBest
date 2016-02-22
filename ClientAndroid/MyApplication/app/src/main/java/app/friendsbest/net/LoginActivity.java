package app.friendsbest.net;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;

import com.facebook.FacebookSdk;
import com.facebook.login.widget.LoginButton;

import java.util.Arrays;

import app.friendsbest.net.presenter.AppLoginPresenter;
import app.friendsbest.net.view.LoginView;
import app.friendsbest.net.view.MainActivity;

public class LoginActivity extends AppCompatActivity implements LoginView {

    // TODO: What happens if login fails? Handle user logging out.
    private CoordinatorLayout _coordinatorLayout;
    private LoginButton _loginButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(getApplicationContext());
        setContentView(R.layout.activity_login);
        _loginButton = (LoginButton) findViewById(R.id.login_button);
        _loginButton.setReadPermissions(Arrays.asList("public_profile", "email", "user_friends"));
        _coordinatorLayout = (CoordinatorLayout) findViewById(R.id.login_coordinator_layout);
        new AppLoginPresenter(this, getApplicationContext());
    }

    @Override
    public void goToMainView() {
        startActivity(new Intent(this, MainActivity.class));
    }

    @Override
    public LoginButton registerFacebookCallback() {
        return _loginButton;
    }

    @Override
    public void displayMessage(String message) {
        Snackbar snackbar = Snackbar.make(_coordinatorLayout,
                message, Snackbar.LENGTH_LONG);
        snackbar.show();
    }
}
