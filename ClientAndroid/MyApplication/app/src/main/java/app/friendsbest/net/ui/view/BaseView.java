package app.friendsbest.net.ui.view;

import android.os.Bundle;

public interface BaseView {

    void replaceView(String oldFragmentTag, String newFragmentTag, Bundle bundle, String key);
    void replaceView(String oldFragmentTag, String newFragmentTag);
    void startView(String fragmentId);
    void displayMessage(String message);
}
