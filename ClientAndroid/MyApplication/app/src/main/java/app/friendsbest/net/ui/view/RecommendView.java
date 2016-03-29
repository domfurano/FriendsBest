package app.friendsbest.net.ui.view;

public interface RecommendView {

    void sendFragmentResult(boolean posted);
    void setDetailValidationError(String message);
    void removeDetailValidationError();
    void setTagValidationError(String message);
    void removeTagValidationError();
}
