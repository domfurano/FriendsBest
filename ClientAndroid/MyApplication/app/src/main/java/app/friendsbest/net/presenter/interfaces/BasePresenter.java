package app.friendsbest.net.presenter.interfaces;

public interface BasePresenter<T extends Object> {
    void sendToPresenter(T responseData);
}
