package app.friendsbest.net.presenter;

import android.content.Context;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.BasePresenter;
import app.friendsbest.net.ui.MainActivity;

public class CardPresenter implements BasePresenter<List<PromptCard>> {

    private List<PromptCard> _promptCards = new ArrayList<>();
    private PreferencesUtility _preferencesUtility;
    private BaseRepository _repository;
    private MainActivity _cardView;

    public CardPresenter(MainActivity view, Context context) {
        _cardView = view;
        _preferencesUtility = PreferencesUtility.getInstance(context);
        _repository = new BaseRepository(this, _preferencesUtility.getToken());
    }

    public void getPrompts() {
        _repository.getPrompts();
    }

    public void deletePromptCard(int id) {
        _repository.deletePrompt(id);
    }

    public boolean isValidQuery(String text) {
        if (text != null) {
            String trimmedText = text.trim();

            return trimmedText.length() > 0;
        }
        return false;
    }

    @Override
    public void sendToPresenter(List<PromptCard> prompts) {
        if (prompts != null) {
            _promptCards = prompts;
        }

        _cardView.displayCards(_promptCards);
    }
}
