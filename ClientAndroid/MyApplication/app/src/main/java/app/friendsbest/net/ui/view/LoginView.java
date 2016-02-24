package app.friendsbest.net.ui.view;

import com.facebook.login.widget.LoginButton;

public interface LoginView {
    void goToMainView();
    void registerFacebookCallback();
    void displayMessage(String message);
}
