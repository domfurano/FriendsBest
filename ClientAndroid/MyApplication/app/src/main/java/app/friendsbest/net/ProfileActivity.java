package app.friendsbest.net;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.CoordinatorLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.widget.TextView;

import com.facebook.CallbackManager;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.facebook.login.widget.LoginButton;

import app.friendsbest.net.model.UserProfile;

public class ProfileActivity extends AppCompatActivity {

    private CoordinatorLayout _coordinatorLayout;
    private CallbackManager _callbackManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(getApplicationContext());
        setContentView(R.layout.activity_profile);

        Toolbar toolbar = (Toolbar) findViewById(R.id.profile_toolbar);
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);

        Intent intent = getIntent();
        String name = intent.getStringExtra(UserProfile.ProfileKey.FULL_NAME.getKey());
        TextView greeting = (TextView) findViewById(R.id.profile_greeting);
        greeting.setText("Hi, " + name);

        _coordinatorLayout = (CoordinatorLayout) findViewById(R.id.profile_coordinator_layout);

        LoginButton logoutButton = (LoginButton) findViewById(R.id.logout_button);
        LoginManager.getInstance().logOut();
    }

    /**
     * Make toolbar back button function the same as Android back button
     */
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                onBackPressed();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }
}
