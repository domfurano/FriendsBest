package app.friendsbest.net.ui.fragment;

import android.os.Bundle;

public interface OnFragmentInteractionListener {

    void onFragmentTitleChange(String title);
    void onFragmentToolbarChange(int id);
    void onFragmentChange(String fragmentTag);
    void onFragmentChange(String fragmentTag, Bundle bundle);
    void onFragmentChangeResult(Bundle bundle);

}
