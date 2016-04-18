package app.friendsbest.net.ui;

import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.places.Places;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.OnListItemClickListener;
import app.friendsbest.net.data.services.FontManager;
import app.friendsbest.net.data.services.ImageService;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.data.services.RegistrationIntentService;
import app.friendsbest.net.presenter.DualFragmentPresenter;
import app.friendsbest.net.ui.fragment.FriendFragment;
import app.friendsbest.net.ui.fragment.NavigationFragment;
import app.friendsbest.net.ui.fragment.PostRecommendationFragment;
import app.friendsbest.net.ui.fragment.ProfileFragment;
import app.friendsbest.net.ui.fragment.PromptFragment;
import app.friendsbest.net.ui.fragment.QueryHistoryFragment;
import app.friendsbest.net.ui.fragment.RecommendationFragment;
import app.friendsbest.net.ui.fragment.RecommendationItemFragment;
import app.friendsbest.net.ui.fragment.RecommendationOptionFragment;
import app.friendsbest.net.ui.fragment.SolutionFragment;
import app.friendsbest.net.ui.fragment.WebFragment;
import app.friendsbest.net.ui.view.DualFragmentView;

public class DualFragmentActivity extends AppCompatActivity implements
        DualFragmentView,
        GoogleApiClient.OnConnectionFailedListener,
        View.OnClickListener,
        OnListItemClickListener<String> {

    public static final String CREATE_RECOMMENDATION_ID = "createRecommendation";
    public static final String ADD_RECOMMENDATION_ID = "addRecommendation";
    public static final String SEARCH_HISTORY_ID = "queryHistory";
    public static final String VIEW_SOLUTION_ID = "viewSolution";
    public static final String VIEW_SOLUTION_ITEM_ID = "viewSolutionItem";
    public static final String VIEW_RECOMMENDATIONS_ID = "viewRecommendations";
    public static final String PROMPT_QUERY_ID = "promptQuery";
    public static final String PROFILE_ID = "profile";
    public static final String NAVIGATION_ID = "navigationBar";
    public static final String FRIENDS_ID = "friends";
    public static final String WEB_VIEW_ID ="webView";
    public static Typeface TYPEFACE;
    public static boolean _isActivityRunning;
    private static final String TAG ="DualFragActivity";
    private static final int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;

    private DualFragmentPresenter _fragmentPresenter;
    private BroadcastReceiver _broadcastReceiver;
    private LinearLayout _bottomNavigationBar;
    private ImageButton _recommendationButton;
    private boolean _isReceiverRegistered;
    private ImageView _profileButton;
    private ImageView _homeButton;
    private Toolbar _toolbar;
    private String _activeButton;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_dual_fragment);

        _toolbar = (Toolbar) findViewById(R.id.toolbar);
        _bottomNavigationBar = (LinearLayout) findViewById(R.id.dual_fragment_nav_frame);
        _homeButton = (ImageView) findViewById(R.id.bottom_navigation_home_icon);
        _profileButton = (ImageView) findViewById(R.id.bottom_navigation_profile_icon);
        _recommendationButton = (ImageButton) findViewById(R.id.bottom_navigation_create_icon);

        _toolbar.setOnClickListener(this);
        _homeButton.setOnClickListener(this);
        _recommendationButton.setOnClickListener(this);
        _profileButton.setOnClickListener(this);

        _broadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
                boolean sentToken = sharedPreferences
                        .getBoolean(RegistrationIntentService.SENT_TOKEN_TO_SERVER, false);
                if (sentToken) {
                    Log.i(TAG, getString(R.string.gcm_send_message));
                }
                else {
                    Log.i(TAG, getString(R.string.token_error_message));
                }
            }
        };
        registerReceiver();
        String pictureUri = PreferencesUtility.getInstance(getApplicationContext()).getProfilePictureUri();
        ImageService.getInstance(getApplicationContext()).retrieveImage(_profileButton, pictureUri, 36, 36);

        setSupportActionBar(_toolbar);
        new GoogleApiClient
                .Builder(this)
                .addApi(Places.GEO_DATA_API)
                .addApi(Places.PLACE_DETECTION_API)
                .enableAutoManage(this, this)
                .build();

        _fragmentPresenter = new DualFragmentPresenter(this, getApplicationContext());
        _fragmentPresenter.setContentClass(PROMPT_QUERY_ID);
        hideSupportActionBar();
        TYPEFACE = FontManager
                .getTypeface(getApplicationContext(), FontManager.FONT_AWESOME);

        if(checkPlayServices()) {
            Intent intent = new Intent(this, RegistrationIntentService.class);
            startService(intent);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        registerReceiver();
        _isActivityRunning = true;
    }

    @Override
    public void onPause() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(_broadcastReceiver);
        _isReceiverRegistered = false;
        super.onPause();
        _isActivityRunning = false;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            FragmentManager fragmentManager = getFragmentManager();
            if (fragmentManager.getBackStackEntryCount() > 0) {
                fragmentManager.popBackStack();
                return true;
            }
        }
        return false;
    }

    @Override
    public void setContentFragment(String fragmentId) {
        Fragment fragment = getFragmentTypeByTag(fragmentId);
        startFragment(fragment, fragmentId);
    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
        int errorCode = connectionResult.getErrorCode();
        GoogleApiAvailability.getInstance().getErrorDialog(this, errorCode, 1);
    }

    @Override
    public void onFragmentTitleChange(String title) {
        getSupportActionBar().setTitle(title);
    }

    @Override
    public void onFragmentToolbarColorChange(int id) {
        _toolbar.setBackgroundColor(ContextCompat.getColor(this, id));
    }

    @Override
    public void onFragmentStatusBarChange(int id) {
        Window window = getWindow();
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        window.setStatusBarColor(getResources().getColor(id));
    }

    @Override
    public void onFragmentChange(String fragmentTag) {
        Fragment fragment = getFragmentTypeByTag(fragmentTag);
        startFragment(fragment, fragmentTag);
    }

    @Override
    public void onFragmentChange(String fragmentTag, Bundle bundle) {
        Fragment fragment = getFragmentTypeByTag(fragmentTag);
        fragment.setArguments(bundle);
        startFragment(fragment, fragmentTag);
    }

    @Override
    public void hideSupportActionBar() {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null && actionBar.isShowing())
            actionBar.hide();
    }

    @Override
    public void showBottomNavigationBar() {
        int visibility = _bottomNavigationBar.getVisibility();
        if (visibility == View.GONE){
            _bottomNavigationBar.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void hideBottomNavigationBar() {
        int visibility = _bottomNavigationBar.getVisibility();
        if (visibility == View.VISIBLE) {
            _bottomNavigationBar.setVisibility(View.GONE);
        }
    }

    @Override
    public void showSupportActionBar() {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null && !actionBar.isShowing()) {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setDisplayShowHomeEnabled(true);
            actionBar.show();
        }
    }

    private Fragment getFragmentTypeByTag(String fragmentTag){
        switch (fragmentTag) {
            case ADD_RECOMMENDATION_ID:
                return new RecommendationOptionFragment();
            case CREATE_RECOMMENDATION_ID:
                return new PostRecommendationFragment();
            case SEARCH_HISTORY_ID:
                return new QueryHistoryFragment();
            case VIEW_SOLUTION_ID:
                return new SolutionFragment();
            case VIEW_SOLUTION_ITEM_ID:
                return new RecommendationItemFragment();
            case PROFILE_ID:
                return new ProfileFragment();
            case NAVIGATION_ID:
                return new NavigationFragment();
            case FRIENDS_ID:
                return new FriendFragment();
            case VIEW_RECOMMENDATIONS_ID:
                return new RecommendationFragment();
            case PROMPT_QUERY_ID:
                return new PromptFragment();
            case WEB_VIEW_ID:
                return new WebFragment();
            default:
                return null;
        }
    }

    private void startFragment(Fragment fragment, String fragmentTag) {
        FragmentManager manager = getFragmentManager();
        if (fragment == null) {
            manager.popBackStack();
        }
        else {
            Fragment backStackFragment = manager.findFragmentByTag(fragmentTag);
            _activeButton = fragmentTag;
            if (backStackFragment == null || !backStackFragment.isVisible()) {
                FragmentTransaction fragmentTransaction = manager.beginTransaction();
                fragmentTransaction.replace(R.id.dual_fragment_content_frame, fragment, fragmentTag);
                fragmentTransaction.addToBackStack(null);
                fragmentTransaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);
                fragmentTransaction.commit();
            }
        }
    }

    @Override
    public void onListItemClick(String item) {
        Log.i("Drawer Click: ", item);
    }

    /**
     * Handle clicks for bottom navigation bar. Change fragment as long as the button clicked
     * does not refer to the currently displayed fragment.
     */
    @Override
    public void onClick(View v) {
        if (v == _homeButton && !_activeButton.equals(PROMPT_QUERY_ID)) {
            onFragmentChange(PROMPT_QUERY_ID);
        }
        else if (v == _profileButton && !_activeButton.equals(PROFILE_ID)) {
            onFragmentChange(PROFILE_ID);
        }
        else if (v == _recommendationButton && !_recommendationButton.equals(ADD_RECOMMENDATION_ID)) {
            onFragmentChange(ADD_RECOMMENDATION_ID);
        }
    }

    private boolean checkPlayServices(){
        GoogleApiAvailability apiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = apiAvailability.isGooglePlayServicesAvailable(this);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (apiAvailability.isUserResolvableError(resultCode)) {
                apiAvailability.getErrorDialog(this, resultCode, PLAY_SERVICES_RESOLUTION_REQUEST)
                        .show();
            } else {
                Log.i(TAG, "This device is not supported.");
                finish();
            }
            return false;
        }
        return true;
    }

    private void registerReceiver() {
        if (!_isReceiverRegistered) {
            LocalBroadcastManager.getInstance(this).registerReceiver(_broadcastReceiver,
                    new IntentFilter(RegistrationIntentService.REGISTRATION_COMPLETE));
            _isReceiverRegistered = true;
        }
    }
}
