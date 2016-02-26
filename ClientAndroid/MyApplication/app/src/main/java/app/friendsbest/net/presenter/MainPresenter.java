package app.friendsbest.net.presenter;

import android.content.Context;

import app.friendsbest.net.presenter.interfaces.Presenter;
import app.friendsbest.net.ui.DualActivity;
import app.friendsbest.net.ui.view.MainView;


public class MainPresenter implements Presenter {

    private MainView _mainView;


    public MainPresenter(MainView baseView, Context context){
        _mainView = baseView;
        onStart();
    }

    @Override
    public void onStart() {
        _mainView.setContentFragment(DualActivity.PROMPT_CARD_ID);
        _mainView.setNavigationFragment(DualActivity.NAVIGATION_ID);
    }

    @Override
    public void onHistoryClicked() {
        _mainView.replaceView(DualActivity.PROMPT_CARD_ID, DualActivity.SEARCH_HISTORY_ID);
    }

    @Override
    public void onProfileClicked() {
        _mainView.replaceView(DualActivity.PROMPT_CARD_ID, DualActivity.PROFILE_ID);
    }

    @Override
    public void onRecommendationClicked() {
        _mainView.replaceView(DualActivity.PROMPT_CARD_ID, DualActivity.ADD_RECOMMENDATION_ID);
    }

    @Override
    public void onQueryClicked(String query) {
        if (query.length() > 0) {
            String[] tags = query.split(" ");

            // TODO: Send this to QueryService
        }
    }
}

