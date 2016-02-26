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

public class CardPresenter implements PromptPresenter {

    private MainActivity _cardView;
    private BaseRepository _repository;
    private Queue<PromptCard> _promptCards;
    private PreferencesUtility _preferencesUtility;

    public CardPresenter(MainActivity view, Context context) {
        _cardView = view;
        _preferencesUtility = PreferencesUtility.getInstance(context);
        _repository = new BaseRepository(this, _preferencesUtility.getToken());
        onStart();
    }

    @Override
    public void onStart() {
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
        return false;
    }

    @Override
    public void sendToPresenter(List<PromptCard> prompts) {
        _promptCards = new ArrayDeque<>();
        if (prompts != null && prompts.size() > 0){
            for (PromptCard card : prompts)
                _promptCards.add(card);
            _cardView.displayCards(_promptCards.peek());
        }
    }
}
