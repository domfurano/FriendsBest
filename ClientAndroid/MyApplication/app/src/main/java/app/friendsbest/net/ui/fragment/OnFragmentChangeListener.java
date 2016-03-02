package app.friendsbest.net.ui.fragment;

import android.os.Bundle;

public interface OnFragmentChangeListener {

    void onFragmentChange(String fragmentTag);
    void onFragmentChange(String fragmentTag, Bundle bundle);
    void onFragmentChangeResult(Bundle bundle);

}
