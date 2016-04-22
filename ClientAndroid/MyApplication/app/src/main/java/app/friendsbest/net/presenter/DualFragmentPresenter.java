package app.friendsbest.net.presenter;

import android.app.Fragment;
import android.support.annotation.VisibleForTesting;
import android.transition.Explode;
import android.transition.Fade;
import android.transition.Slide;
import android.view.Gravity;

import app.friendsbest.net.ui.DualFragmentActivity;
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


public class DualFragmentPresenter {

    private DualFragmentView _dualFragmentView;


    public DualFragmentPresenter(DualFragmentView baseView){
        _dualFragmentView = baseView;
    }

    public void setContentClass(String startingClass) {
        onStart(startingClass);
    }

    public void onStart(String startingClass) {
        _dualFragmentView.setContentFragment(startingClass);
    }

    public Fragment getFragmentByTag(String fragmentTag) {
        Fragment fragment;
        switch (fragmentTag) {
            case DualFragmentActivity.ADD_RECOMMENDATION_ID:
                fragment = new RecommendationOptionFragment();
                fragment.setEnterTransition(new Slide(Gravity.RIGHT).setDuration(800));
                fragment.setExitTransition(new Slide(Gravity.LEFT).setDuration(800));
                return fragment;
            case DualFragmentActivity.CREATE_RECOMMENDATION_ID:
                return new PostRecommendationFragment();
            case DualFragmentActivity.SEARCH_HISTORY_ID:
                fragment = new QueryHistoryFragment();
                fragment.setEnterTransition(new Slide(Gravity.RIGHT).setDuration(1000));
                fragment.setExitTransition(new Slide(Gravity.LEFT).setDuration(400));
                return fragment;
            case DualFragmentActivity.VIEW_SOLUTION_ID:
                fragment = new SolutionFragment();
                fragment.setEnterTransition(new Slide(Gravity.RIGHT).setDuration(1000));
                fragment.setReenterTransition(new Slide(Gravity.RIGHT).setDuration(1000));
                fragment.setExitTransition(new Slide(Gravity.LEFT).setDuration(400));
                return fragment;
            case DualFragmentActivity.VIEW_SOLUTION_ITEM_ID:
                fragment = new RecommendationItemFragment();
                fragment.setEnterTransition(new Slide(Gravity.RIGHT).setDuration(1000));
                fragment.setExitTransition(new Slide(Gravity.LEFT).setDuration(400));
                return fragment;
            case DualFragmentActivity.PROFILE_ID:
                fragment = new ProfileFragment();
                fragment.setEnterTransition(new Slide(Gravity.RIGHT).setDuration(800));
                fragment.setExitTransition(new Slide(Gravity.LEFT).setDuration(800));
                return fragment;
            case DualFragmentActivity.NAVIGATION_ID:
                return new NavigationFragment();
            case DualFragmentActivity.FRIENDS_ID:
                fragment = new FriendFragment();
                fragment.setEnterTransition(new Slide(Gravity.RIGHT).setDuration(800));
                fragment.setExitTransition(new Slide(Gravity.LEFT).setDuration(800));
                return fragment;
            case DualFragmentActivity.VIEW_RECOMMENDATIONS_ID:
                fragment = new RecommendationFragment();
                fragment.setEnterTransition(new Slide(Gravity.RIGHT).setDuration(800));
                fragment.setExitTransition(new Slide(Gravity.LEFT).setDuration(800));
                return fragment;
            case DualFragmentActivity.PROMPT_QUERY_ID:
                fragment = new PromptFragment();
                fragment.setEnterTransition(new Explode().setDuration(1000));
                return fragment;
            case DualFragmentActivity.WEB_VIEW_ID:
                fragment = new WebFragment();
                fragment.setEnterTransition(new Slide(Gravity.RIGHT).setDuration(800));
                fragment.setExitTransition(new Slide(Gravity.LEFT).setDuration(800));
                return fragment;
            default:
                return null;
        }
    }
}

