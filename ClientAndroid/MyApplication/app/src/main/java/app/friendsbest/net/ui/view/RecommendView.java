package app.friendsbest.net.ui.view;

public interface RecommendView {

    void sendFragmentResult(boolean posted);
    void displayDetailValidation(String message);
    void hideDetailValidation();
    void displayTagsValidation(String message);
    void hideTagsValidation();
}
