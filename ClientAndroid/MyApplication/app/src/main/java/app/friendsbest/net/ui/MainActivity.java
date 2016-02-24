package app.friendsbest.net.ui;

import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.Toast;

import app.friendsbest.net.R;
import app.friendsbest.net.presenter.MainPresenter;
import app.friendsbest.net.ui.fragment.CardFragment;
import app.friendsbest.net.ui.fragment.ProfileFragment;
import app.friendsbest.net.ui.fragment.RecommendationFragment;
import app.friendsbest.net.ui.fragment.SearchHistoryFragment;
import app.friendsbest.net.ui.fragment.SolutionFragment;
import app.friendsbest.net.ui.fragment.SolutionItemFragment;
import app.friendsbest.net.ui.view.BaseView;

public class MainActivity extends AppCompatActivity implements BaseView, View.OnTouchListener {

    public static final String ADD_RECOMMENDATION_ID = "addRecommendation";
    public static final String SEARCH_HISTORY_ID = "queryHistory";
    public static final String VIEW_RECOMMENDATION_ID = "viewRecommendation";
    public static final String VIEW_SOLUTION_ID = "viewSolution";
    public static final String PROFILE_ID = "profile";
    public static final String PROMPT_CARD_ID = "promptCard";

    private MainPresenter _mainPresenter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.fragment_main);
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
        else
            return new CardFragment();
    }

    @Override
    public void replaceView(String oldFragmentTag, String newFragmentTag) {
        FragmentManager fragmentManager = getFragmentManager();
        Fragment oldFragment = fragmentManager.findFragmentByTag(oldFragmentTag);

        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        if (oldFragment != null)
            fragmentTransaction.remove(oldFragment);
        Fragment newFragment = getFragmentTypeByTag(newFragmentTag);
        fragmentTransaction.add(newFragment, newFragmentTag);
        fragmentTransaction.commit();
    }

    @Override
    public void startView(String fragmentId) {
        Fragment fragment = getFragmentTypeByTag(fragmentId);
        FragmentManager fragmentManager = getFragmentManager();

        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.add(fragment, fragmentId);
        fragmentTransaction.commit();
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        return false;
    }

    @Override
    public void displayMessage(String message){
        // TODO: Add snackbar
        Toast.makeText(MainActivity.this, message, Toast.LENGTH_SHORT).show();
    }
}
