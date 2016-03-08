package app.friendsbest.net.presenter.interfaces;

import java.util.Map;

public interface LoginPresenter extends BasePresenter<Map<String, String>> {
    void onStart();
    void onUserLogin();
    void onLoginFail();
    void checkLoginStatus();
    void getAuthToken(Map<String, String> facebookToken);
}
