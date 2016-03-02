package app.friendsbest.net.ui.view;

import app.friendsbest.net.ui.fragment.OnFragmentChangeListener;

public interface DualFragmentView extends OnFragmentChangeListener {
    void setContentFragment(String fragmentId);
    void setNavigationFragment(String fragmentId);
}
