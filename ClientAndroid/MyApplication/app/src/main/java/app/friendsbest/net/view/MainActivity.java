package app.friendsbest.net.view;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import app.friendsbest.net.HistoryActivity;
import app.friendsbest.net.ProfileActivity;
import app.friendsbest.net.R;
import app.friendsbest.net.RecommendActivity;
import app.friendsbest.net.SettingsActivity;
import app.friendsbest.net.data.services.NetworkUtility;
import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.model.UserProfile;
import app.friendsbest.net.presenter.MainPresenter;

public class MainActivity extends AppCompatActivity implements CardView, MainView, View.OnClickListener, View.OnTouchListener {
    MainPresenter _mainPresenter;

    private CoordinatorLayout _layout;
    private RelativeLayout _promptCardLayout;
    private EditText _searchField;
    private ImageButton _profileBtn;
    private ImageButton _settingsBtn;
    private ImageButton _recommendationBtn;
    private ImageButton _historyBtn;
    private ImageButton _searchBtn;
    private String _fullName;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        SharedPreferences savedData = PreferenceManager.getDefaultSharedPreferences(this);
        _fullName = savedData.getString(UserProfile.ProfileKey.FULL_NAME.getKey(), null);
        _mainPresenter = new MainPresenter(this, getApplicationContext());

        inflateViews();

        // Set focus listener for search field
        _searchField.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (!hasFocus) {
                    InputMethodManager methodManager = (InputMethodManager) getApplicationContext()
                            .getSystemService(Context.INPUT_METHOD_SERVICE);
                    methodManager.hideSoftInputFromWindow(_searchField.getWindowToken(), 0);
                }
            }
        });

        // Set listeners for buttons
        _historyBtn.setOnClickListener(this);
        _searchBtn.setOnClickListener(this);
        _profileBtn.setOnClickListener(this);
        _settingsBtn.setOnClickListener(this);
        _recommendationBtn.setOnClickListener(this);

        _mainPresenter.getPrompts();

        _promptCardLayout.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return _mainPresenter.onCardSwipe(v, event);
            }
        });
    }

    @Override
    public void onClick(View v) {
        if (v == _searchBtn)
            _mainPresenter.onQueryClicked(_searchField.getText().toString().trim());
        else if (v == _recommendationBtn)
            _mainPresenter.onRecommendationClicked();
        else if (v == _historyBtn)
            _mainPresenter.onHistoryClicked();
        else if (v == _profileBtn)
            _mainPresenter.onProfileClicked();
        else
            _mainPresenter.onSettingsClicked();
    }

    private void inflateViews(){
        // Get buttons related to query history and search
        _historyBtn = (ImageButton) findViewById(R.id.historyButton);
        _searchBtn = (ImageButton) findViewById(R.id.submit_query_button);
        _searchField = (EditText) findViewById(R.id.query_field);

        // Get buttons for settings, profile, add recommendation
        _profileBtn = (ImageButton) findViewById(R.id.profile_button);
        _settingsBtn = (ImageButton) findViewById(R.id.settings_button);
        _recommendationBtn = (ImageButton) findViewById(R.id.recommendation_button);

        _promptCardLayout = (RelativeLayout) findViewById(R.id.prompt_layout);
        _layout = (CoordinatorLayout) findViewById(R.id.home_coordinator_layout);
    }

    /**
     * Check if the device is connected to the internet and start activity.
     * Display error message otherwise.
     */
    private void startActivityForConnectedDevice(Intent intent){
        if (NetworkUtility.getInstance(this).isDeviceConnected()) {
            startActivity(intent);
        }
        else {
            int messageIdStatus = R.string.no_internet;
            Snackbar snackbar = Snackbar.make(_layout, messageIdStatus, Snackbar.LENGTH_LONG);
            snackbar.show();
        }
    }


    @Override
    public void displayCards(PromptCard cards) {
        Log.i("Prompt card size", cards.getArticle());
        CardViewGroup cardViewGroup = new CardViewGroup(this);
        addContentView(cardViewGroup, _layout.getLayoutParams());

        for (int i = 0; i < 3; i++){
            TextView textView = new TextView(this);
            if (i == 0)
                textView.setText("Do you have a recommendation for");
            else if (i == 1)
                textView.setText(cards.getTagstring());
            else
                textView.setText(cards.getFriend());
            cardViewGroup.addView(textView);
        }
    }

    @Override
    public void onSwipeLeft(float swipeDistance) {

    }

    @Override
    public void onSwipeRight(float swipeDistance) {

    }

    @Override
    public void goToUserProfile() {
        Intent intent = new Intent(MainActivity.this, ProfileActivity.class);
        intent.putExtra(UserProfile.ProfileKey.FULL_NAME.getKey(), _fullName);
        startActivityForConnectedDevice(intent);
    }

    @Override
    public void goToSettings() {
        Intent intent = new Intent(MainActivity.this, SettingsActivity.class);
        startActivityForConnectedDevice(intent);
    }

    @Override
    public void goToHistory() {
        Intent intent = new Intent(MainActivity.this, HistoryActivity.class);
        startActivityForConnectedDevice(intent);
    }

    @Override
    public void goToRecommendation() {
        Intent intent = new Intent(MainActivity.this, RecommendActivity.class);
        startActivityForConnectedDevice(intent);
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        return false;
    }

    @Override
    public void displayMessage(String message){
        Toast.makeText(MainActivity.this, message, Toast.LENGTH_SHORT).show();
    }
}
