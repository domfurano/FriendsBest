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
import android.widget.Toast;

import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;

import app.friendsbest.net.R;
import app.friendsbest.net.data.services.ImageService;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.presenter.ProfilePresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.LoginActivity;

public class ProfileFragment extends Fragment implements View.OnClickListener {

    private OnFragmentInteractionListener _listener;
    private Button _logoutButton;
    private Button _deleteButton;
    private ImageView _profilePicture;
    private CardView _recommendationCard;
    private CardView _friendsCard;
    private TextView _recommendationsCount;
    private TextView _friendsCount;
    private TextView _profileGreeting;
    private PreferencesUtility _preferencesUtility;
    private String _storedFriendsList;
    private String _storedRecommendationList;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_profile, container, false);
        _profilePicture = (ImageView) rootView.findViewById(R.id.profile_picture);
        _logoutButton = (Button) rootView.findViewById(R.id.logout_button);
        _deleteButton = (Button) rootView.findViewById(R.id.delete_profile_button);
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
        _listener.showSupportActionBar();
        _listener.onFragmentTitleChange("Profile");
        _listener.onFragmentToolbarChange(R.color.blue_gray200);
        new ProfilePresenter(this, getActivity().getApplicationContext());
        _preferencesUtility = PreferencesUtility.getInstance(getActivity().getApplicationContext());
        _profileGreeting.setText(_preferencesUtility.getUserName());
        _friendsCard.setOnClickListener(this);
        _deleteButton.setOnClickListener(this);
        _recommendationCard.setOnClickListener(this);
        String uri = _preferencesUtility.getProfilePictureUri();
        ImageService.getInstance(getActivity().getApplicationContext())
                .retrieveImage(_profilePicture, uri, 100, 100);
    }

    public void setRecommendationsCount(int count) {
        _recommendationsCount.setText(Integer.toString(count));
    }

    public void setFriendsCount(int count) {
        _friendsCount.setText(Integer.toString(count));
    }

    public void saveFriendsList(String friend) {
        _storedFriendsList = friend;
    }

    public void saveRecommendationsList(String recommendations) {
        _storedRecommendationList = recommendations;
    }

    @Override
    public void onClick(View v) {
        if (v == _logoutButton) {
            LoginManager.getInstance().logOut();
            _preferencesUtility.deleteStoredData();
            startActivity(new Intent(getActivity(), LoginActivity.class));
            getActivity().finish();
        }
        else if (v == _friendsCard) {
            if (_storedFriendsList != null) {
                Bundle bundle = new Bundle();
                bundle.putString(FriendFragment.BUNDLE_KEY, _storedFriendsList);
                _listener.onFragmentChange(DualFragmentActivity.FRIENDS_ID, bundle);
            }
        }
        else if (v == _recommendationCard) {
            if (_storedRecommendationList != null) {
                Bundle bundle = new Bundle();
                bundle.putString(RecommendationFragment.BUNDLE_KEY, _storedRecommendationList);
                _listener.onFragmentChange(DualFragmentActivity.VIEW_RECOMMENDATIONS_ID, bundle);
            }
        }
        else if (v == _deleteButton) {
            Toast.makeText(getActivity(), "I'm sorry Jim, I'm afraid I can't do that.", Toast.LENGTH_LONG).show();
        }
    }
}
