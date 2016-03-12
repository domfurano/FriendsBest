package app.friendsbest.net.presenter;

import android.content.Context;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.model.RecommendationPost;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.RecommendPresenter;
import app.friendsbest.net.ui.view.RecommendView;

public class PostRecommendationPresenter implements RecommendPresenter {

    private BaseRepository _repository;
    private RecommendView _recommendView;

    public PostRecommendationPresenter(RecommendView view, Context context){
        _recommendView = view;
        _repository = new BaseRepository(this,
                PreferencesUtility.getInstance(context).getToken());
    }

    @Override
    public void submitRecommendation(String title, String tags, String comment, String type) {
        if (isValidInput(title, tags)){
            String[] tagsArray = tags.split("\\s|,");
            List<String> tagsList = new ArrayList<>();
            for(String tag : tagsArray)
                tagsList.add(tag.trim());

            RecommendationPost post = new RecommendationPost();
            post.setDetail(title);
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

    private boolean isValidInput(String title, String tags) {
        boolean valid = true;
        if (title == null || title.trim().length() == 0) {
            _recommendView.displayDetailValidation("Recommendation cannot be blank");
            valid = false;
        }
        if (tags == null || tags.trim().length() == 0) {
            _recommendView.displayTagsValidation("Keywords cannot be blank");
            valid = false;
        }
        return valid;
    }
}
