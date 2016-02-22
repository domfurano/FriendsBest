package app.friendsbest.net.presenter;

import android.content.Context;
import android.view.MotionEvent;
import android.view.View;

import java.util.List;
import java.util.PriorityQueue;
import java.util.Queue;

import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.presenter.interfaces.Presenter;
import app.friendsbest.net.presenter.interfaces.PromptPresenter;
import app.friendsbest.net.view.CardView;
import app.friendsbest.net.view.MainView;


public class MainPresenter implements Presenter, PromptPresenter {

    private BaseRepository _repository;
    private MainView _mainView;
    private CardView _cardView;
    private Queue<PromptCard> _promptCards;
    private PreferencesUtility _preferencesUtility;


    public MainPresenter(MainView mainView, Context context){
        _mainView = mainView;
        _cardView = (CardView) mainView;
        _preferencesUtility = PreferencesUtility.getInstance(context);
        _repository = new BaseRepository(this, _preferencesUtility.getToken());
        getPrompts();
    }

    @Override
    public void getPrompts() {
        _repository.getPrompts();
    }

    @Override
    public void deletePromptCard(int id) {

    }

    @Override
    public boolean onCardSwipe(View v, MotionEvent event) {
        if (_promptCards != null) {
            float x1 = 0, x2;
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    x1 = event.getX();
                    break;
                case MotionEvent.ACTION_UP:
                    x2 = event.getX();
                    float deltaX = x2 - x1;
                    // Swipe right
                    if (deltaX > 50) {
                        _mainView.goToRecommendation();
                    }
                    // Swipe left
                    else if (deltaX < -50) {
                        _promptCards.remove();
                        _cardView.displayCards(_promptCards.peek());
                    }
                    break;
            }
            return true;
        }
        return false;
    }

    @Override
    public void onHistoryClicked() {
        _mainView.goToHistory();
    }

    @Override
    public void onProfileClicked() {
        _mainView.goToUserProfile();

    }

    @Override
    public void onSettingsClicked() {
        _mainView.goToSettings();
    }

    @Override
    public void onRecommendationClicked() {
        _mainView.goToRecommendation();
    }

    @Override
    public void onQueryClicked(String query) {
        if (query.length() > 0) {
            String[] tags = query.split(" ");

            // TODO: Send this to QueryService
        }
    }

    @Override
    public void sendToPresenter(List<PromptCard> prompts) {
        _promptCards = new PriorityQueue<>();
        if (prompts != null){
            for (PromptCard card : prompts)
                _promptCards.add(card);
            _cardView.displayCards(_promptCards.peek());
        }
    }
}

