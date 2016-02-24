package app.friendsbest.net.presenter;

import android.content.Context;
import android.view.MotionEvent;
import android.view.View;

import java.util.ArrayDeque;
import java.util.List;
import java.util.Queue;

import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.Presenter;
import app.friendsbest.net.presenter.interfaces.PromptPresenter;
import app.friendsbest.net.ui.MainActivity;
import app.friendsbest.net.ui.view.BaseView;
import app.friendsbest.net.ui.view.CardView;


public class MainPresenter implements Presenter {

    private BaseView _baseView;


    public MainPresenter(BaseView baseView, Context context){
        _baseView = baseView;
    }

    @Override
    public void onHistoryClicked() {
        _baseView.replaceView(MainActivity.PROMPT_CARD_ID, MainActivity.SEARCH_HISTORY_ID);
    }

    @Override
    public void onProfileClicked() {
        _baseView.replaceView(MainActivity.PROMPT_CARD_ID, MainActivity.PROFILE_ID);
    }

    @Override
    public void onRecommendationClicked() {
        _baseView.replaceView(MainActivity.PROMPT_CARD_ID, MainActivity.ADD_RECOMMENDATION_ID);
    }

    @Override
    public void onQueryClicked(String query) {
        if (query.length() > 0) {
            String[] tags = query.split(" ");

            // TODO: Send this to QueryService
        }
    }
}

