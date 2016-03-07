package app.friendsbest.net.ui.fragment;

import android.app.Activity;
import android.app.Fragment;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.location.places.Place;
import com.google.android.gms.location.places.ui.PlacePicker;

import app.friendsbest.net.R;
import app.friendsbest.net.data.services.FontManager;
import app.friendsbest.net.presenter.PostRecommendationPresenter;
import app.friendsbest.net.presenter.interfaces.RecommendPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.MainActivity;
import app.friendsbest.net.ui.view.RecommendView;

public class PostRecommendationFragment extends Fragment implements
        RecommendView,
        View.OnClickListener,
        TextView.OnEditorActionListener,
        View.OnFocusChangeListener {

    public static final String BUNDLE_KEY = "addRecommendationKey";
    private final int PLACE_PICKER_REQUEST = 47;
    private OnFragmentInteractionListener _listener;
    private RecommendPresenter _presenter;
    private EditText _editDetail;
    private EditText _editTags;
    private EditText _editComment;
    private TextView _placePicker;
    private TextView _invalidDetail;
    private TextView _invalidTags;
    private Button _submitButton;
    private String _type;
    private boolean _fromRightSwipe;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View fragmentView = inflater.inflate(R.layout.fragment_recommend, container, false);
        FontManager.markAsIconContainer(fragmentView.findViewById(R.id.place_picker_button_layout), DualFragmentActivity.TYPEFACE);
        init(fragmentView, getArguments());
        return fragmentView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.onFragmentTitleChange("Add Recommendation");
        _listener.onFragmentToolbarChange(R.color.appGreen);
        _presenter = new PostRecommendationPresenter(this, getActivity().getApplicationContext());
        _placePicker.setOnClickListener(this);
        _submitButton.setOnClickListener(this);
        _editComment.setOnEditorActionListener(this);
        _editDetail.setOnFocusChangeListener(this);
        _editTags.setOnFocusChangeListener(this);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void sendFragmentResult(boolean posted) {
        if (_fromRightSwipe) {
            Bundle bundle = new Bundle();
            bundle.putBoolean(BUNDLE_KEY, new Boolean(posted));
            _listener.onFragmentResult(bundle);
        }
        else {
            _listener.onFragmentChange(DualFragmentActivity.REMOVE_FRAGMENT);
        }
    }

    @Override
    public void displayDetailValidation(String message) {
        _invalidDetail.setText(message);
    }

    @Override
    public void hideDetailValidation() {
        _invalidDetail.setVisibility(View.INVISIBLE);
    }

    @Override
    public void displayTagsValidation(String message) {
        _invalidTags.setText(message);
    }

    @Override
    public void hideTagsValidation() {
        _invalidTags.setVisibility(View.INVISIBLE);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == PLACE_PICKER_REQUEST) {
            if (resultCode == Activity.RESULT_OK) {
                Place place = PlacePicker.getPlace(getActivity(), data);
                _editDetail.setText(place.getName());
                _editComment.setText(place.getAddress());
                _type = place.getId();
                String toastMsg = String.format("Place: %s", place.getName());
                Toast.makeText(getActivity(), toastMsg, Toast.LENGTH_LONG).show();
            }
        }
    }

    @Override
    public void onClick(View v) {
        if (v == _placePicker) {
            PlacePicker.IntentBuilder builder = new PlacePicker.IntentBuilder();
            try {
                startActivityForResult(builder.build(getActivity()), PLACE_PICKER_REQUEST);
            }
            catch (Exception e) {
                Log.e("Place picker", e.getMessage(), e);
            }
        }
        else if (v == _submitButton) {
            String editTitle = _editDetail.getText().toString();
            String editTags = _editTags.getText().toString();
            String comment = _editComment.getText().toString();
            _presenter.submitRecommendation(editTitle, editTags, comment, _type);
        }
    }

    @Override
    public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
        if (actionId == EditorInfo.IME_ACTION_SEND) {
            String title = _editDetail.getText().toString();
            String tags = _editTags.getText().toString();
            String comment = _editComment.getText().toString();
            _presenter.submitRecommendation(title, tags, comment, _type);
            return true;
        }
        return false;
    }

    private void init(View view, Bundle bundle) {
        _editDetail = (EditText) view.findViewById(R.id.rec_tags_title_input);
        _editTags = (EditText) view.findViewById(R.id.rec_tags_input);
        _editComment = (EditText) view.findViewById(R.id.rec_comments_input);
        _placePicker = (TextView) view.findViewById(R.id.place_picker_button);
        _invalidDetail = (TextView) view.findViewById(R.id.rec_title_invalid_label);
        _invalidTags = (TextView) view.findViewById(R.id.rec_tags_invalid_label);
        _submitButton = (Button) view.findViewById(R.id.recommendation_submit);

        _fromRightSwipe = false;
        if (bundle != null) {
            if (bundle.getString(MainActivity.CONTENT_TAG, null) != null) {
                String tags = bundle.getString(MainActivity.CONTENT_TAG);
                _editTags.setText(tags);
                _fromRightSwipe = true;
            }
        }
    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {
    }
}
