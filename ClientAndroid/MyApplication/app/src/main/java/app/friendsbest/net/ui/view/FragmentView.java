package app.friendsbest.net.ui.view;

public interface FragmentView<T extends Object> extends BaseView {

    void displayContent(T content);
    void showProgressBar();
    void hideProgressBar();
}
