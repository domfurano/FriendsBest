package app.friendsbest.net.presenter;

import android.content.Context;

import com.squareup.otto.Bus;
import com.squareup.otto.Subscribe;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.model.RecommendationPost;
import app.friendsbest.net.data.utilities.BusProvider;
import app.friendsbest.net.data.utilities.Repository;
import app.friendsbest.net.data.utilities.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.RecommendPresenter;
import app.friendsbest.net.ui.view.RecommendView;

public class PostRecommendationPresenter implements RecommendPresenter {

    private final Bus _bus;
    private Repository _repository;
    private RecommendView _recommendView;

    public PostRecommendationPresenter(RecommendView view, Context context){
        _recommendView = view;
        _bus = BusProvider.getInstance();
        _repository = new Repository(PreferencesUtility.getInstance(context).getToken(), _bus);
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

    @Subscribe
    public void onSubmitRecommendation(Recommendation recommendation) {
        _recommendView.sendFragmentResult(recommendation != null);
    }

    @Override
    public void onPause() {
        _bus.unregister(this);
    }

    @Override
    public void onResume() {
        _bus.register(this);
    }
}
