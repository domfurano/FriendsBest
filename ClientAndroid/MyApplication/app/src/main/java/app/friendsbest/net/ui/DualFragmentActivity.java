package app.friendsbest.net.ui;

import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.transition.Explode;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.ImageView;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.places.Places;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.OnListItemClickListener;
import app.friendsbest.net.data.services.FontManager;
import app.friendsbest.net.data.services.ImageService;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.DualFragmentPresenter;
import app.friendsbest.net.ui.fragment.FriendFragment;
import app.friendsbest.net.ui.fragment.NavigationFragment;
import app.friendsbest.net.ui.fragment.PostRecommendationFragment;
import app.friendsbest.net.ui.fragment.ProfileFragment;
import app.friendsbest.net.ui.fragment.PromptFragment;
import app.friendsbest.net.ui.fragment.RecommendationFragment;
import app.friendsbest.net.ui.fragment.RecommendationItemFragment;
import app.friendsbest.net.ui.fragment.RecommendationOptionFragment;
import app.friendsbest.net.ui.fragment.SearchHistoryFragment;
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
    public static final String REMOVE_FRAGMENT = "remove";
    public static Typeface TYPEFACE;

    private DualFragmentPresenter _fragmentPresenter;
    private ImageView _recommendationButton;
    private ImageView _profileButton;
    private ImageView _homeButton;
    private Toolbar _toolbar;
    private String _activeButton;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_dual_fragment);

        _toolbar = (Toolbar) findViewById(R.id.toolbar);
        _homeButton = (ImageView) findViewById(R.id.bottom_navigation_home_icon);
        _profileButton = (ImageView) findViewById(R.id.bottom_navigation_profile_icon);
        _recommendationButton = (ImageView) findViewById(R.id.bottom_navigation_create_icon);

        _toolbar.setOnClickListener(this);
        _homeButton.setOnClickListener(this);
        _recommendationButton.setOnClickListener(this);
        _profileButton.setOnClickListener(this);

        String pictureUri = PreferencesUtility.getInstance(getApplicationContext()).getProfilePictureUri();
        ImageService.getInstance(this).retrieveImage(_profileButton, pictureUri, 36, 36);

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
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            FragmentManager fragmentManager = getFragmentManager();
            if (fragmentManager.getBackStackEntryCount() > 0) {
                fragmentManager.popBackStack();
            }
            else {
                //onBackPressed();
            }
            return true;
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
    public void onFragmentToolbarChange(int id) {
        _toolbar.setBackgroundColor(ContextCompat.getColor(this, id));
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
                return new SearchHistoryFragment();
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
                fragmentTransaction.setCustomAnimations(android.R.animator.fade_in, android.R.animator.fade_out);
                fragmentTransaction.commit();
            }
        }
    }

    @Override
    public void onListItemClick(String item) {
        Log.i("Drawer Click: ", item);
    }

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
}
