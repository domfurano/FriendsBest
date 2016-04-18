package app.friendsbest.net.presenter;

import android.content.Context;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.model.RecommendationPost;
import app.friendsbest.net.data.services.Repository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.RecommendPresenter;
import app.friendsbest.net.ui.view.RecommendView;

public class PostRecommendationPresenter implements RecommendPresenter {

    private Repository _repository;
    private RecommendView _recommendView;

    public PostRecommendationPresenter(RecommendView view, Context context){
        _recommendView = view;
        _repository = new Repository(this,
                PreferencesUtility.getInstance(context).getToken());
    }

    @Override
    public boolean validateDetail(String detail) {
        if (detail == null || detail.trim().isEmpty()) {
            _recommendView.setDetailValidationError("Recommendation field is required");
            return false;
        }
        _recommendView.removeDetailValidationError();
        return true;
    }

    @Override
    public boolean validateTags(String tags) {
        if (tags == null || tags.trim().isEmpty()) {
            _recommendView.setTagValidationError("Keyword field is required");
            return false;
        }
        _recommendView.removeTagValidationError();
        return true;
    }

    @Override
    public void submitRecommendation(String detail, String tags, String comment, String type) {
        if (validateDetail(detail) && validateTags(tags)){
            String[] tagsArray = tags.split("\\s|,");
            List<String> tagsList = new ArrayList<>();
            for(String tag : tagsArray)
                tagsList.add(tag.trim());

            RecommendationPost post = new RecommendationPost();
            post.setDetail(detail);
            post.setTags(tagsList);
            post.setType(type);
            post.setComments(comment);


            _repository.postRecommendation(post);
        }
    }

    @Override
    public void sendToPresenter(Recommendation recommendation) {
        _recommendView.sendFragmentResult(recommendation != null);
    }
}
