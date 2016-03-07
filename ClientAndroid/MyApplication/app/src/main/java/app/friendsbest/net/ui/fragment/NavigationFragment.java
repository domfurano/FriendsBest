package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;

import app.friendsbest.net.R;
import app.friendsbest.net.data.services.CircleTransform;
import app.friendsbest.net.data.services.FontManager;
import app.friendsbest.net.data.services.PreferencesUtility;
import app.friendsbest.net.ui.DualFragmentActivity;

public class NavigationFragment extends Fragment implements View.OnClickListener {

    private OnFragmentInteractionListener _listener;
    private ImageView _profileButton;
    private TextView _recommendButton;
    private TextView _homeButton;


    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _profileButton.setOnClickListener(this);
        _recommendButton.setOnClickListener(this);
        _homeButton.setOnClickListener(this);
        Glide.with(getActivity())
                .load(PreferencesUtility.getInstance(getActivity().getApplicationContext()).getProfilePictureUri())
                .override(dpToPixel(30),dpToPixel(30))
                .transform(new CircleTransform(getActivity().getApplicationContext()))
                .into(_profileButton);
        _listener = (OnFragmentInteractionListener) getActivity();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View contentView = inflater.inflate(R.layout.navigation_bar, container, false);
        FontManager.markAsIconContainer(contentView.findViewById(R.id.navigation_container), DualFragmentActivity.TYPEFACE);
        _profileButton = (ImageView) contentView.findViewById(R.id.nav_profile_button);
        _homeButton = (TextView) contentView.findViewById(R.id.nav_home_button);
        _recommendButton = (TextView) contentView.findViewById(R.id.nav_recommend_button);
        return contentView;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onClick(View v) {
        if (v == _profileButton)
            _listener.onFragmentChange(DualFragmentActivity.PROFILE_ID);
        else if (v == _recommendButton)
            _listener.onFragmentChange(DualFragmentActivity.ADD_RECOMMENDATION_ID);
        else if (v == _homeButton)
            _listener.onFragmentResult(null);
    }

    private int dpToPixel(int dp) {
        DisplayMetrics metrics = getActivity().getResources().getDisplayMetrics();
        int px = Math.round(dp * (metrics.xdpi / DisplayMetrics.DENSITY_DEFAULT));
        return px;
    }
}
