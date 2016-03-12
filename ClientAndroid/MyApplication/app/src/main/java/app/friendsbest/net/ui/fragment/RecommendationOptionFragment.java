package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import app.friendsbest.net.R;
import app.friendsbest.net.ui.DualFragmentActivity;

public class RecommendationOptionFragment extends Fragment implements View.OnClickListener {

    private RelativeLayout _mapButton;
    private RelativeLayout _customButton;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_recommendation_option, container, false);
        _mapButton = (RelativeLayout) view.findViewById(R.id.recommend_options_map_button);
        _customButton = (RelativeLayout) view.findViewById(R.id.recommend_options_custom_button);
        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _mapButton.setOnClickListener(this);
        _customButton.setOnClickListener(this);
        DualFragmentActivity activity = (DualFragmentActivity) getActivity();
        activity.showSupportActionBar();
        activity.onFragmentTitleChange("Recommendation Type");
        activity.onFragmentToolbarChange(R.color.appGreen);
    }

    @Override
    public void onClick(View v) {
        if (v == _mapButton) {

        } else if (v == _customButton) {

        }
    }
}
