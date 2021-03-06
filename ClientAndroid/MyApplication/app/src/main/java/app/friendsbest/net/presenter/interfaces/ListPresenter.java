package app.friendsbest.net.presenter.interfaces;

public interface ListPresenter<T extends Object> extends BasePresenter<T> {
    void getData();
    void onPause();
    void onResume();
}
