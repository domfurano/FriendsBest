package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.TextView;

import app.friendsbest.net.R;
import app.friendsbest.net.data.services.FontManager;
import app.friendsbest.net.ui.DualActivity;

public class NavigationFragment extends Fragment implements View.OnClickListener {

    private TextView _profileButton;
    private TextView _recommendButton;
    private TextView _homeButton;


    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _profileButton.setOnClickListener(this);
        _recommendButton.setOnClickListener(this);
        _homeButton.setOnClickListener(this);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View contentView = inflater.inflate(R.layout.fragment_navigation_bar, container, false);
        FontManager.markAsIconContainer(contentView.findViewById(R.id.navigation_container), DualActivity._typeFace);
        _profileButton = (TextView) contentView.findViewById(R.id.nav_profile_button);
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
        if (v == _profileButton) {
            Log.i("OnClick", "clicked profile button");
        }
        else if (v == _recommendButton) {
            DualActivity activity = (DualActivity) getActivity();
            activity.replaceView(activity.SEARCH_HISTORY_ID, activity.ADD_RECOMMENDATION_ID);
        }
        else if (v == _homeButton) {
            Log.i("OnClick", "clicked home button");
        }
    }
}
