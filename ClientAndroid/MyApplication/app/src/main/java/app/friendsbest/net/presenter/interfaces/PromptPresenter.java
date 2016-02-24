package app.friendsbest.net.presenter.interfaces;

import android.view.MotionEvent;
import android.view.View;

import java.util.List;

import app.friendsbest.net.data.model.PromptCard;

public interface PromptPresenter extends BasePresenter<List<PromptCard>> {
    void onStart();
    void getPrompts();
    void deletePromptCard(int id);
    boolean onCardSwipe(View v, MotionEvent event);
}
