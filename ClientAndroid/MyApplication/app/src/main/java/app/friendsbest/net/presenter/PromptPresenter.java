package app.friendsbest.net.presenter;

import android.content.Context;
import android.os.Bundle;

import com.squareup.otto.Bus;
import com.squareup.otto.Subscribe;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import app.friendsbest.net.data.events.LoadNotificationEvent;
import app.friendsbest.net.data.events.LoadPromptEvent;
import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.model.QueryResult;
import app.friendsbest.net.data.utilities.BusProvider;
import app.friendsbest.net.data.utilities.PreferencesUtility;
import app.friendsbest.net.data.utilities.Repository;
import app.friendsbest.net.presenter.interfaces.ListPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.fragment.PromptFragment;
import app.friendsbest.net.ui.fragment.SolutionFragment;

public class PromptPresenter implements ListPresenter<List<PromptCard>> {

    private Repository _repository;
    private PromptFragment _view;
    private final String _token;
    private Bus _bus;

    public PromptPresenter(PromptFragment view, Context context) {
        _bus = BusProvider.getInstance();
        _view = view;
        _token = PreferencesUtility.getInstance(context).getToken();
        _repository = new Repository(_token, _bus);
        getData();
    }

    public void deletePromptCard(int id) {
        _repository.deletePrompt(id);
    }

    @Subscribe
    public void processQueryResult(QueryResult result) {
        Bundle bundle = new Bundle();
        bundle.putInt(SolutionFragment.SOLUTION_ID_TAG, result.getId());
        bundle.putString(SolutionFragment.SOLUTION_TAGS, result.getTagString());
        _view.changeFragment(DualFragmentActivity.VIEW_SOLUTION_ID, bundle);
    }

    @Subscribe
    public void checkForNewNotifications(LoadNotificationEvent event) {
        boolean hasNewRecommendations = event.hasNewNotification();
        _view.hasNewRecommendations(hasNewRecommendations);
    }

    public void getNotificationUpdate() {
        _repository.getNotificationCount();
    }

    public void submitQuery(String query) {
        if (isValidQuery(query)) {
            String[] tags = query.split("\\s|,");
            List<String> tagsList = new ArrayList<>();
            HashMap<String, List<String>> tagsMap = new HashMap<>();
            for (String tag : tags) {
                tagsList.add(tag.trim());
            }

            tagsMap.put("tags", tagsList);
            _repository.postQuery(tagsMap);
        }
    }

    @Subscribe
    public void loadPromptCards(LoadPromptEvent event) {
        _view.hideProgressBar();
        List<PromptCard> promptCards = event.getEventList();
        if (promptCards != null) {
            _view.displayContent(promptCards);
        }
    }

    @Override
    public void getData() {
        _view.showProgressBar();
        _repository.getPrompts();
    }

    @Override
    public void onPause() {
        _bus.unregister(this);
    }

    @Override
    public void onResume() {
        _bus.register(this);
        getNotificationUpdate();
    }

    private boolean isValidQuery(String query) {
        if (query != null) {
            String trimmedText = query.trim();
            return trimmedText.length() > 0;
        }
        return false;
    }
}
