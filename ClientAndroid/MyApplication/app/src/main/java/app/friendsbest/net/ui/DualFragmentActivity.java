package app.friendsbest.net.ui;

import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.places.Places;

import app.friendsbest.net.R;
import app.friendsbest.net.data.services.FontManager;
import app.friendsbest.net.presenter.DualFragmentPresenter;
import app.friendsbest.net.ui.fragment.NavigationFragment;
import app.friendsbest.net.ui.fragment.ProfileFragment;
import app.friendsbest.net.ui.fragment.RecommendationFragment;
import app.friendsbest.net.ui.fragment.SearchHistoryFragment;
import app.friendsbest.net.ui.fragment.SolutionFragment;
import app.friendsbest.net.ui.fragment.RecommendationItemFragment;
import app.friendsbest.net.ui.view.DualFragmentView;

public class DualFragmentActivity extends AppCompatActivity implements
        DualFragmentView,
        GoogleApiClient.OnConnectionFailedListener {

        public static final String ADD_RECOMMENDATION_ID = "addRecommendation";
        public static final String SEARCH_HISTORY_ID = "queryHistory";
        public static final String VIEW_RECOMMENDATION_ID = "viewRecommendation";
        public static final String VIEW_SOLUTION_ID = "viewSolution";
        public static final String VIEW_SOLUTION_ITEM_ID = "viewSolutionItem";
        public static final String PROFILE_ID = "profile";
        public static final String PROMPT_CARD_ID = "promptCard";
        public static final String NAVIGATION_ID = "navigationBar";
        public static Typeface _typeFace;

        private DualFragmentPresenter _fragmentPresenter;

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);

            Intent intent = getIntent();
            String className = intent.getStringExtra(MainActivity.CLASS_TAG);
            String payload = null;
            if (intent.hasExtra(MainActivity.CONTENT_TAG))
                payload = intent.getStringExtra(MainActivity.CONTENT_TAG);

            setContentView(R.layout.activity_dual_fragment);

            Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
            setSupportActionBar(toolbar);
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
            _typeFace = FontManager
                    .getTypeface(getApplicationContext(), FontManager.FONT_AWESOME);
        }

    private Fragment getFragmentTypeByTag(String fragmentTag){
        if (fragmentTag.equals(ADD_RECOMMENDATION_ID))
            return new RecommendationFragment();
        else if (fragmentTag.equals(SEARCH_HISTORY_ID))
            return new SearchHistoryFragment();
        else if (fragmentTag.equals(VIEW_RECOMMENDATION_ID))
            return new RecommendationItemFragment();
        else if (fragmentTag.equals(VIEW_SOLUTION_ID))
            return new SolutionFragment();
        else if (fragmentTag.equals(PROFILE_ID))
            return new ProfileFragment();
        else if (fragmentTag.equals(NAVIGATION_ID))
            return new NavigationFragment();
        return null;
    }

    @Override
    public void setContentFragment(String fragmentId) {
        Fragment fragment = getFragmentTypeByTag(fragmentId);
        changeFragment(fragment);
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
    public void onFragmentChange(String fragmentTag) {
        Fragment fragment = getFragmentTypeByTag(fragmentTag);
        changeFragment(fragment);
    }

    @Override
    public void onFragmentChange(String fragmentTag, Bundle bundle) {
        Fragment fragment = getFragmentTypeByTag(fragmentTag);
        fragment.setArguments(bundle);
        changeFragment(fragment);
    }

    @Override
    public void onFragmentChangeResult(Bundle bundle) {
        Intent intent = new Intent(DualFragmentActivity.this, MainActivity.class);
        intent.putExtra(MainActivity.CONTENT_TAG, bundle);
        startActivity(intent);
    }

    private void changeFragment(Fragment fragment) {
        FragmentTransaction fragmentTransaction = getFragmentManager().beginTransaction();
        fragmentTransaction.replace(R.id.dual_fragment_content_frame, fragment);
        fragmentTransaction.addToBackStack(null);
        fragmentTransaction.commit();
    }
}
