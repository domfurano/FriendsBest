package app.friendsbest.net.presenter;

import android.content.Context;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.model.RecommendationItem;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.RecommendPresenter;
import app.friendsbest.net.ui.view.RecommendView;

public class RecommendationPresenter implements RecommendPresenter {

    private BaseRepository _repository;
    private RecommendView _recommendView;

    public RecommendationPresenter(RecommendView view, Context context){
        _recommendView = view;
        _repository = new BaseRepository(this, PreferencesUtility.getInstance(context).getToken());
    }

    @Override
    public void submitRecommendation(String title, String tags, String comment) {
        if (title != null && tags != null && comment != null){
            String[] tagsArray = tags.split("\\s|,");
            List<String> tagsList = new ArrayList<>();
            for(String tag : tagsArray)
                tagsList.add(tag.trim());

            Recommendation recommendation = new Recommendation();
            recommendation.setComment(comment);
            recommendation.setTags(tagsList);
            recommendation.setType("TEXT");
            recommendation.setDetail(title);

            _repository.postRecommendation(recommendation);
        }
    }

    @Override
    public void sendToPresenter(Recommendation recommendation) {
        _recommendView.startMainActivity(recommendation != null);
    }
}
