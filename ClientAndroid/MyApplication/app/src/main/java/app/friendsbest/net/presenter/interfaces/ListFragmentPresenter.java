package app.friendsbest.net.presenter.interfaces;

public interface ListFragmentPresenter<T extends Object> extends BasePresenter<T> {
    void getData();
    void getData(T content);
}
