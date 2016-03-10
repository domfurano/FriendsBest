package app.friendsbest.net.ui;

import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.places.Places;

import app.friendsbest.net.R;
import app.friendsbest.net.data.services.FontManager;
import app.friendsbest.net.presenter.DualFragmentPresenter;
import app.friendsbest.net.ui.fragment.FriendFragment;
import app.friendsbest.net.ui.fragment.NavigationFragment;
import app.friendsbest.net.ui.fragment.PostRecommendationFragment;
import app.friendsbest.net.ui.fragment.ProfileFragment;
import app.friendsbest.net.ui.fragment.PromptFragment;
import app.friendsbest.net.ui.fragment.RecommendationFragment;
import app.friendsbest.net.ui.fragment.RecommendationItemFragment;
import app.friendsbest.net.ui.fragment.SearchHistoryFragment;
import app.friendsbest.net.ui.fragment.SolutionFragment;
import app.friendsbest.net.ui.view.DualFragmentView;

public class DualFragmentActivity extends AppCompatActivity implements
        DualFragmentView,
        GoogleApiClient.OnConnectionFailedListener {

    public static final String ADD_RECOMMENDATION_ID = "addRecommendation";
    public static final String SEARCH_HISTORY_ID = "queryHistory";
    public static final String VIEW_SOLUTION_ID = "viewSolution";
    public static final String VIEW_SOLUTION_ITEM_ID = "viewSolutionItem";
    public static final String VIEW_RECOMMENDATIONS_ID = "viewRecommendations";
    public static final String PROFILE_ID = "profile";
    public static final String NAVIGATION_ID = "navigationBar";
    public static final String FRIENDS_ID = "friends";
    public static final String REMOVE_FRAGMENT = "remove";
    public static Typeface TYPEFACE;

    private DualFragmentPresenter _fragmentPresenter;
    private Toolbar _toolbar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent intent = getIntent();
        String className = intent.getStringExtra(MainActivity.CLASS_TAG);
        String payload = null;
        if (intent.hasExtra(MainActivity.CONTENT_TAG))
            payload = intent.getStringExtra(MainActivity.CONTENT_TAG);

        setContentView(R.layout.activity_dual_fragment);

        _toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(_toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);

        new GoogleApiClient
                .Builder(this)
                .addApi(Places.GEO_DATA_API)
                .addApi(Places.PLACE_DETECTION_API)
                .enableAutoManage(this, this)
                .build();

        _fragmentPresenter = new DualFragmentPresenter(this, getApplicationContext());
        _fragmentPresenter.setContentClass(className, payload);
        TYPEFACE = FontManager
                .getTypeface(getApplicationContext(), FontManager.FONT_AWESOME);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            FragmentManager fragmentManager = getFragmentManager();
            if (fragmentManager.getBackStackEntryCount() > 1) {
                fragmentManager.popBackStack();
            }
            else {
                onBackPressed();
            }
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void setContentFragment(String fragmentId) {
        Fragment fragment = getFragmentTypeByTag(fragmentId);
        startFragment(fragment, fragmentId);
    }

    @Override
    public void setNavigationFragment(String fragmentId) {
        Fragment fragment = getFragmentTypeByTag(fragmentId);
        FragmentManager fragmentManager = getFragmentManager();

        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.add(R.id.dual_fragment_nav_frame, fragment, fragmentId);
        fragmentTransaction.commit();
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
    public void onFragmentResult(Bundle bundle) {
        Intent intent = new Intent(DualFragmentActivity.this, MainActivity.class);
        if (bundle != null) {
            if (bundle.containsKey(PostRecommendationFragment.BUNDLE_KEY)) {
                Intent resultIntent = new Intent();
                boolean posted = bundle.getBoolean(PostRecommendationFragment.BUNDLE_KEY);
                resultIntent.putExtra("Result", posted);
                setResult(MainActivity.RESULT_PASS, resultIntent);
                finish();
            }
            intent.putExtra(MainActivity.CONTENT_TAG, bundle);
        }
        startActivity(intent);
        finish();
    }

    private Fragment getFragmentTypeByTag(String fragmentTag){
        switch (fragmentTag) {
            case ADD_RECOMMENDATION_ID:
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
                return new PromptFragment();
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

            if (backStackFragment == null || !backStackFragment.isVisible()) {
                FragmentTransaction fragmentTransaction = manager.beginTransaction();
                fragmentTransaction.replace(R.id.dual_fragment_content_frame, fragment, fragmentTag);
                fragmentTransaction.addToBackStack(null);
                fragmentTransaction.commit();
            }
        }
    }
}
