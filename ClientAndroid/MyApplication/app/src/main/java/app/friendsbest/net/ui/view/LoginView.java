package app.friendsbest.net.ui.view;

public interface LoginView extends BaseView {
    void startMainView();
    void registerFacebookCallback();
    void getUserProfile();
    void forceLogout();
}
