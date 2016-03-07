package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.CardView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;

import app.friendsbest.net.R;
import app.friendsbest.net.data.services.CircleTransform;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.ProfilePresenter;
import app.friendsbest.net.presenter.interfaces.LoginPresenter;
import app.friendsbest.net.ui.LoginActivity;

public class ProfileFragment extends Fragment implements View.OnClickListener {

    private OnFragmentInteractionListener _listener;
    private ProfilePresenter _presenter;
    private Button _logoutButton;
    private ImageView _profilePicture;
    private CardView _recommendationCard;
    private CardView _friendsCard;
    private TextView _recommendationsCount;
    private TextView _friendsCount;
    private TextView _profileGreeting;
    private PreferencesUtility _preferencesUtility;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_profile, container, false);
        _profilePicture = (ImageView) rootView.findViewById(R.id.profile_picture);
        _logoutButton = (Button) rootView.findViewById(R.id.logout_button);
        _recommendationCard = (CardView) rootView.findViewById(R.id.profile_recommendations_button);
        _friendsCard = (CardView) rootView.findViewById(R.id.profile_friends_button);
        _recommendationsCount = (TextView) rootView.findViewById(R.id.profile_recommendation_count);
        _friendsCount = (TextView) rootView.findViewById(R.id.profile_friends_count);
        _profileGreeting = (TextView) rootView.findViewById(R.id.profile_greeting);
        return rootView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        FacebookSdk.sdkInitialize(getActivity().getApplicationContext());
        _logoutButton.setOnClickListener(this);
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.onFragmentTitleChange("Profile");
        _listener.onFragmentToolbarChange(R.color.blue_gray200);
        _presenter = new ProfilePresenter(this, getActivity().getApplicationContext());
        _preferencesUtility = PreferencesUtility.getInstance(getActivity().getApplicationContext());
        _profileGreeting.setText(_preferencesUtility.getUserName());
        Glide.with(getActivity())
                .load(_preferencesUtility.getProfilePictureUri())
                .override(150, 150)
                .transform(new CircleTransform(getActivity().getApplicationContext()))
                .into(_profilePicture);
    }

    public void setRecommendationsCount(int count) {
        _recommendationsCount.setText(Integer.toString(count));
    }

    public void setFriendsCount(int count) {
        _friendsCount.setText(Integer.toString(count));
    }

    @Override
    public void onClick(View v) {
        if (v == _logoutButton) {
            LoginManager.getInstance().logOut();
            _preferencesUtility.deleteStoredData();
            startActivity(new Intent(getActivity(), LoginActivity.class));
            getActivity().finish();
        }
    }
}
