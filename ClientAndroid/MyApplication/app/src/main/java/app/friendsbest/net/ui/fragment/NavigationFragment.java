package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;

import app.friendsbest.net.R;
import app.friendsbest.net.ui.MainActivity;

public class NavigationFragment extends Fragment implements View.OnClickListener {

    private ImageButton _profileButton;
    private ImageButton _recommendButton;
    private ImageButton _homeButton;


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
        _profileButton = (ImageButton) contentView.findViewById(R.id.nav_profile_button);
        _homeButton = (ImageButton) contentView.findViewById(R.id.nav_home_button);
        _recommendButton = (ImageButton) contentView.findViewById(R.id.nav_recommend_button);
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
            MainActivity activity = (MainActivity) getActivity();
            activity.replaceView(MainActivity.SEARCH_HISTORY_ID, MainActivity.ADD_RECOMMENDATION_ID);
        }
        else if (v == _homeButton) {
            Log.i("OnClick", "clicked home button");
        }
    }
}
