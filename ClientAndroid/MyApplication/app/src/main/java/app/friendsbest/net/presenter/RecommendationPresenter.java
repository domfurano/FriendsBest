package app.friendsbest.net.presenter;

import java.util.List;

import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.presenter.interfaces.BasePresenter;
import app.friendsbest.net.ui.view.FragmentView;

public class RecommendationPresenter implements BasePresenter<List<Recommendation>> {

    private FragmentView _view;

    @Override
    public void sendToPresenter(List<Recommendation> responseData) {

    }
}
