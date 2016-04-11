package app.friendsbest.net.ui.fragment;

import android.app.Activity;
import android.app.Fragment;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.RelativeLayout;

import com.google.android.gms.location.places.Place;
import com.google.android.gms.location.places.ui.PlacePicker;

import app.friendsbest.net.R;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.view.DualFragmentView;

public class RecommendationOptionFragment extends Fragment implements View.OnClickListener {

    public static final String PLACE_PICKER_NAME = "googlePlacePickerName";
    public static final String PLACE_PICKER_ADDRESS = "googlePlacePickerAddress";
    public static final String PLACE_PICKER_ID = "googlePlacePickerNameID";
    private static final String PLACE_PICKER_PHONE = "googlePlacePickerPhone";
    private final int PLACE_PICKER_REQUEST = 47;
    private Bundle _bundle;
    private Button _mapButton;
    private Button _webButton;
    private Button _customButton;
    private OnFragmentInteractionListener _listener;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_recommendation_option, container, false);
        initialize(view, getArguments());
        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _mapButton.setOnClickListener(this);
        _webButton.setOnClickListener(this);
        _customButton.setOnClickListener(this);
        _listener = (DualFragmentView) getActivity();
        _listener.showSupportActionBar();
        _listener.onFragmentTitleChange("");
        _listener.hideBottomNavigationBar();
        _listener.onFragmentToolbarColorChange(R.color.appGreen);
        _listener.onFragmentStatusBarChange(R.color.appGreenDark);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == PLACE_PICKER_REQUEST) {
            if (resultCode == Activity.RESULT_OK) {
                Place place = PlacePicker.getPlace(getActivity(), data);
                if (_bundle == null)
                    _bundle = new Bundle();
                _bundle.putString(PLACE_PICKER_NAME, place.getName().toString());
                _bundle.putString(PLACE_PICKER_ADDRESS, place.getAddress().toString());
                _bundle.putString(PLACE_PICKER_ID, place.getId());
                _bundle.putString(PLACE_PICKER_PHONE, place.getPhoneNumber().toString());
                _listener.onFragmentChange(DualFragmentActivity.CREATE_RECOMMENDATION_ID, _bundle);
            }
        }
    }

    @Override
    public void onClick(View v) {
        if (v == _mapButton) {
            PlacePicker.IntentBuilder builder = new PlacePicker.IntentBuilder();
            try {
                startActivityForResult(builder.build(getActivity()), PLACE_PICKER_REQUEST);
            }
            catch (Exception e) {
                Log.e("Place picker", e.getMessage(), e);
            }
        } else if (v == _customButton) {
            if (_bundle != null) {
                _listener.onFragmentChange(DualFragmentActivity.CREATE_RECOMMENDATION_ID, _bundle);
            }
            else {
                _listener.onFragmentChange(DualFragmentActivity.CREATE_RECOMMENDATION_ID);
            }
        } else if (v == _webButton) {
            if (_bundle != null) {
                _listener.onFragmentChange(DualFragmentActivity.WEB_VIEW_ID, _bundle);
            }
            else {
                _listener.onFragmentChange(DualFragmentActivity.WEB_VIEW_ID);
            }
        }
    }

    private void initialize(View view, Bundle bundle) {
        _mapButton = (Button) view.findViewById(R.id.recommend_options_map_button);
        _webButton = (Button) view.findViewById(R.id.recommend_options_web_button);
        _customButton = (Button) view.findViewById(R.id.recommend_options_custom_button);
        if (bundle != null) {
            if (bundle.getString(PromptFragment.BUNDLE_TAG, null) != null) {
                _bundle = bundle;
            }
        }
    }
}
