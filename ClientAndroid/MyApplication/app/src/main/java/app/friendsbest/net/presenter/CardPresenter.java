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
import app.friendsbest.net.presenter.interfaces.PromptPresenter;
import app.friendsbest.net.ui.MainActivity;
import app.friendsbest.net.ui.view.CardView;

public class CardPresenter implements PromptPresenter {

    private CardView _cardView;
    private BaseRepository _repository;
    private Queue<PromptCard> _promptCards;
    private PreferencesUtility _preferencesUtility;

    public CardPresenter(CardView view, Context context) {
        _cardView = view;
        _preferencesUtility = PreferencesUtility.getInstance(context);
        _repository = new BaseRepository(this, _preferencesUtility.getToken());
        onStart();
    }

    @Override
    public void onStart() {
        getPrompts();
        _cardView.startView(MainActivity.PROMPT_CARD_ID);
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
                        _cardView.replaceView(MainActivity.PROMPT_CARD_ID, MainActivity.ADD_RECOMMENDATION_ID);
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
        return false;    }

    @Override
    public void sendToPresenter(List<PromptCard> prompts) {
        _promptCards = new ArrayDeque<>();
        if (prompts != null){
            for (PromptCard card : prompts)
                _promptCards.add(card);
            _cardView.displayCards(_promptCards.peek());
        }
    }
}
