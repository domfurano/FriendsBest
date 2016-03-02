package app.friendsbest.net.ui.view;

import app.friendsbest.net.ui.fragment.OnFragmentInteractionListener;

public interface DualFragmentView extends OnFragmentInteractionListener {
    void setContentFragment(String fragmentId);
    void setNavigationFragment(String fragmentId);
}
