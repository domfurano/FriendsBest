package app.friendsbest.net.presenter;

import android.content.Context;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.data.model.UserRecommendation;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.presenter.interfaces.RecommendPresenter;
import app.friendsbest.net.ui.view.RecommendView;

public class RecommendationPresenter implements RecommendPresenter {

    private BaseRepository _repository;

    public RecommendationPresenter(RecommendView view, Context context){

    }

    @Override
    public void submitRecommendation(String title, String tags, String comment) {
        if (title != null && tags != null && comment != null){
            String[] tagsArray = tags.split(" ");
            List<String> tagsList = new ArrayList<>();
            for(String tag : tagsArray)
                tagsList.add(tag.trim());

            UserRecommendation recommendation = new UserRecommendation();
            recommendation.setComment(comment);
            recommendation.setName(title);
            recommendation.setTags(tagsList);

        }
    }

    @Override
    public void sendToPresenter(List<UserRecommendation> responseData) {

    }
}
