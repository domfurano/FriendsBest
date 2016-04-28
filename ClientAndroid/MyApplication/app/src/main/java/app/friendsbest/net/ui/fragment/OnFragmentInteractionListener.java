package app.friendsbest.net.ui.fragment;

import android.os.Bundle;

public interface OnFragmentInteractionListener {
    void onFragmentTitleChange(String title);
    void onFragmentSubtitleChange(String subtitle);
    void onFragmentToolbarColorChange(int id);
    void onFragmentStatusBarChange(int id);
    void onFragmentChange(String fragmentTag);
    void onFragmentChange(String fragmentTag, Bundle bundle);
    void showSupportActionBar();
    void hideSupportActionBar();
    void showBottomNavigationBar();
    void hideBottomNavigationBar();
}
