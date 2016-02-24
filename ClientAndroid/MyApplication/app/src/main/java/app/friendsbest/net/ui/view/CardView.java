package app.friendsbest.net.ui.view;

import app.friendsbest.net.data.model.PromptCard;

public interface CardView extends BaseView {
    void displayCards(PromptCard cards);
    void onSwipeLeft(float distance);
    void onSwipeRight(float distance);
}
