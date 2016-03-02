package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.facebook.FacebookSdk;
import com.facebook.login.widget.LoginButton;

import app.friendsbest.net.R;

public class ProfileFragment extends Fragment {

    private OnFragmentInteractionListener _listener;
    private LoginButton _logoutButton;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_profile, container, false);
        _logoutButton = (LoginButton) rootView.findViewById(R.id.logout_button);
        return rootView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        FacebookSdk.sdkInitialize(getActivity().getApplicationContext());
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.onFragmentTitleChange("Profile");
    }
}
