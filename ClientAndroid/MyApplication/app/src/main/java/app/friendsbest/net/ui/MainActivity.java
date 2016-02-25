package app.friendsbest.net.ui;

import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v7.app.AppCompatActivity;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.places.Places;

import app.friendsbest.net.R;
import app.friendsbest.net.presenter.MainPresenter;
import app.friendsbest.net.ui.fragment.CardFragment;
import app.friendsbest.net.ui.fragment.NavigationFragment;
import app.friendsbest.net.ui.fragment.ProfileFragment;
import app.friendsbest.net.ui.fragment.RecommendationFragment;
import app.friendsbest.net.ui.fragment.SearchHistoryFragment;
import app.friendsbest.net.ui.fragment.SolutionFragment;
import app.friendsbest.net.ui.fragment.SolutionItemFragment;
import app.friendsbest.net.ui.view.MainView;

public class MainActivity extends FragmentActivity implements
        MainView,
        GoogleApiClient.OnConnectionFailedListener {

    public static final String ADD_RECOMMENDATION_ID = "addRecommendation";
    public static final String SEARCH_HISTORY_ID = "queryHistory";
    public static final String VIEW_RECOMMENDATION_ID = "viewRecommendation";
    public static final String VIEW_SOLUTION_ID = "viewSolution";
    public static final String PROFILE_ID = "profile";
    public static final String PROMPT_CARD_ID = "promptCard";
    public static final String NAVIGATION_ID = "navigationBar";

    private MainPresenter _mainPresenter;
    private GoogleApiClient _googleApiClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        _googleApiClient = new GoogleApiClient
                .Builder(this)
                .addApi(Places.GEO_DATA_API)
                .addApi(Places.PLACE_DETECTION_API)
                .enableAutoManage(this, this)
                .build();
        _mainPresenter = new MainPresenter(this, getApplicationContext());
    }

    private Fragment getFragmentTypeByTag(String fragmentTag){
        if (fragmentTag.equals(ADD_RECOMMENDATION_ID))
            return new RecommendationFragment();
        else if (fragmentTag.equals(SEARCH_HISTORY_ID))
            return new SearchHistoryFragment();
        else if (fragmentTag.equals(VIEW_RECOMMENDATION_ID))
            return new SolutionItemFragment();
        else if (fragmentTag.equals(VIEW_SOLUTION_ID))
            return new SolutionFragment();
        else if (fragmentTag.equals(PROFILE_ID))
            return new ProfileFragment();
        else if (fragmentTag.equals(NAVIGATION_ID))
            return new NavigationFragment();
        else
            return new CardFragment();
    }

    @Override
    public void replaceView(String oldFragmentTag, String newFragmentTag, Bundle bundle, String key) {
    }

    @Override
    public void replaceView(String oldFragmentTag, String newFragmentTag) {
        FragmentManager fragmentManager = getFragmentManager();
        Fragment oldFragment = fragmentManager.findFragmentByTag(oldFragmentTag);

        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        if (oldFragment != null){
            fragmentTransaction.remove(oldFragment);
        }
        Fragment newFragment = getFragmentTypeByTag(newFragmentTag);
        fragmentTransaction.add(R.id.demo_content_frame, newFragment, newFragmentTag);
        fragmentTransaction.commit();
    }

    @Override
    public void startView(String fragmentId) {
        FragmentManager fragmentManager = getFragmentManager();

        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.add(R.id.demo_content_frame, getFragmentTypeByTag(fragmentId), fragmentId);
        fragmentTransaction.commit();
    }

    @Override
    public void displayMessage(String message){
        // TODO: Add snack bar
        Toast.makeText(MainActivity.this, message, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void setContentFragment(String fragmentId) {
        startView(fragmentId);
    }

    @Override
    public void setNavigationFragment(String fragmentId) {
        Fragment fragment = getFragmentTypeByTag(fragmentId);
        FragmentManager fragmentManager = getFragmentManager();

        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.add(R.id.demo_nav_frame, fragment, fragmentId);
        fragmentTransaction.commit();
    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
        int errorCode = connectionResult.getErrorCode();
        GoogleApiAvailability.getInstance().getErrorDialog(this, errorCode, 1);
    }
}
