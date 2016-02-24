package app.friendsbest.net.ui.view;

public interface BaseView {

    void replaceView(String oldFragmentTag, String newFragmentTag);
    void startView(String fragmentId);
    void displayMessage(String message);
}
