package app.friendsbest.net.view;

import app.friendsbest.net.data.model.PromptCard;

public interface CardView {
    void displayCards(PromptCard cards);
    void onSwipeLeft(float distance);
    void onSwipeRight(float distance);
}
