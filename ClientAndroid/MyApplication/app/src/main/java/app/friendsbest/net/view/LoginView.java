package app.friendsbest.net.view;

import com.facebook.login.widget.LoginButton;

public interface LoginView {
    void goToMainView();
    LoginButton registerFacebookCallback();
    void displayMessage(String message);
}
