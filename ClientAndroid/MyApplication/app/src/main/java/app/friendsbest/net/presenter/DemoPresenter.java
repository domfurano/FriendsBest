package app.friendsbest.net.presenter;

import android.content.Context;

import java.util.List;

import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.services.BaseRepository;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.interfaces.ListPresenter;
import app.friendsbest.net.ui.fragment.OnFragmentInteractionListener;
import app.friendsbest.net.ui.view.FragmentView;

public class DemoPresenter implements ListPresenter<List<PromptCard>> {

    private BaseRepository _repository;
    private FragmentView _view;

    public DemoPresenter(FragmentView view, Context context){
        _view = view;
        _repository = new BaseRepository(this, PreferencesUtility.getInstance(context).getToken());
        getData();
    }

    public void deletePromptCard(int id) {
        _repository.deletePrompt(id);
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
}
