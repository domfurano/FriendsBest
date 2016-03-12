package app.friendsbest.net.presenter;

import android.content.Context;
import android.os.Bundle;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.model.QueryResult;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.BasePresenter;
import app.friendsbest.net.presenter.interfaces.ListPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.fragment.PromptFragment;
import app.friendsbest.net.ui.fragment.SolutionFragment;

public class DemoPresenter implements ListPresenter<List<PromptCard>> {

    private BaseRepository _repository;
    private PromptFragment _view;
    private final String _token;

    private BasePresenter<QueryResult> _queryPresenter = new BasePresenter<QueryResult>() {
        @Override
        public void sendToPresenter(QueryResult responseData) {
            if (responseData != null) {
                processQueryResult(responseData);
            }
        }
    };

    public DemoPresenter(PromptFragment view, Context context){
        _view = view;
        _token = PreferencesUtility.getInstance(context).getToken();
        _repository = new BaseRepository(this, _token);
        getData();
    }

    public void deletePromptCard(int id) {
        _repository.deletePrompt(id);
    }

    private void processQueryResult(QueryResult result) {
        Bundle bundle = new Bundle();
        bundle.putInt(SolutionFragment.SOLUTION_ID_TAG, result.getId());
        bundle.putString(SolutionFragment.SOLUTION_TAGS, result.getTagString());
        _view.changeFragment(DualFragmentActivity.VIEW_SOLUTION_ID, bundle);
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
            BaseRepository repository = new BaseRepository(_queryPresenter, _token);
            repository.postQuery(tagsMap);
        }
    }

    @Override
    public void sendToPresenter(List<PromptCard> responseData) {
        _view.hideProgressBar();
        if (responseData != null) {
            _view.displayContent(responseData);
        }
    }

    @Override
    public void getData() {
        _view.showProgressBar();
       _repository.getPrompts();
    }

    @Override
    public void getData(List<PromptCard> content) {
        getData();
    }

    private boolean isValidQuery(String query) {
        if (query != null) {
            String trimmedText = query.trim();
            return trimmedText.length() > 0;
        }
        return false;
    }
}
