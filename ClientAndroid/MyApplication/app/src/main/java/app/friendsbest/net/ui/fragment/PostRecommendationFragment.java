package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.TextInputLayout;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import app.friendsbest.net.R;
import app.friendsbest.net.presenter.PostRecommendationPresenter;
import app.friendsbest.net.presenter.interfaces.RecommendPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.view.RecommendView;

public class PostRecommendationFragment extends Fragment implements RecommendView {

    public static final String BUNDLE_KEY = "addRecommendationKey";
    private OnFragmentInteractionListener _listener;
    private RecommendPresenter _presenter;
    private FloatingActionButton _floatingActionButton;
    private EditText _editDetail,_editTags, _editComment;
    private TextInputLayout _detailLayout, _tagLayout;
    private ImageView _placesIcon;
    private TextView _placeAddress;
    private String _type = "TEXT";
    private String _placePickerId;
    private boolean _fromRightSwipe;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View fragmentView = inflater.inflate(R.layout.fragment_recommend, container, false);
        initialize(fragmentView, getArguments());
        return fragmentView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.showSupportActionBar();
        _listener.onFragmentTitleChange("New Recommendation");
        _listener.onFragmentToolbarColorChange(R.color.appGreen);
        _presenter = new PostRecommendationPresenter(this, getActivity().getApplicationContext());
        _editDetail.addTextChangedListener(new InputChangeWatcher(_editDetail));
        _editTags.addTextChangedListener(new InputChangeWatcher(_editTags));
    }

    @Override
    public void onResume(){
        super.onResume();
        _presenter.onResume();
    }

    @Override
    public void onPause() {
        super.onPause();
        _presenter.onPause();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.action_create) {
            submitData();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void sendFragmentResult(boolean posted) {
        if (_fromRightSwipe) {
            Bundle bundle = new Bundle();
            bundle.putBoolean(BUNDLE_KEY, posted);
            _listener.onFragmentChange(DualFragmentActivity.PROMPT_QUERY_ID, bundle);
        }
        else {
            _listener.onFragmentChange(DualFragmentActivity.PROMPT_QUERY_ID);
        }
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.menu_add_recommendation, menu);
    }

    @Override
    public void setDetailValidationError(String message) {
        _detailLayout.setError(message);
    }

    @Override
    public void removeDetailValidationError() {
        _detailLayout.setErrorEnabled(false);
    }

    @Override
    public void setTagValidationError(String message) {
        _tagLayout.setError(message);
    }

    @Override
    public void removeTagValidationError() {
        _tagLayout.setErrorEnabled(false);
    }

    private void submitData() {
        String editTitle = _editDetail.getText().toString();
        String editTags = _editTags.getText().toString();
        String comment = _editComment.getText().toString();

        // Hide keyboard
        InputMethodManager imm = (InputMethodManager) getActivity().getSystemService(getActivity().INPUT_METHOD_SERVICE);
        View v = getActivity().getCurrentFocus();
        if (v == null)
            return;
        imm.hideSoftInputFromWindow(v.getWindowToken(), 0);

        _presenter.submitRecommendation(editTitle, editTags, comment, _type);
    }

    private void initialize(View view, Bundle bundle) {
        _editDetail = (EditText) view.findViewById(R.id.recommendation_detail_input);
        _editTags = (EditText) view.findViewById(R.id.recommendation_tags_input);
        _editComment = (EditText) view.findViewById(R.id.recommendation_comments_input);
        _floatingActionButton = (FloatingActionButton) view.findViewById(R.id.recommend_create_button);
        _placeAddress = (TextView) view.findViewById(R.id.recommendation_places_address);
        _placesIcon = (ImageView) view.findViewById(R.id.recommendation_places_icon);
        _detailLayout = (TextInputLayout) view.findViewById(R.id.recommendation_detail_layout);
        _tagLayout = (TextInputLayout) view.findViewById(R.id.recommendation_tags_layout);
        _placesIcon.setVisibility(View.INVISIBLE);

        _floatingActionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                submitData();
            }
        });

        _fromRightSwipe = false;
        if (bundle != null) {
            String bundleValue;
            if ((bundleValue = bundle.getString(PromptFragment.BUNDLE_TAG, null)) != null) {
                _editTags.setText(bundleValue);
                _editTags.setEnabled(false);
                _fromRightSwipe = true;
            }
            if ((bundleValue = bundle.getString(RecommendationOptionFragment.PLACE_PICKER_ID, null)) != null) {
                _placePickerId = bundleValue;
                _editDetail.setText(bundle.getString(RecommendationOptionFragment.PLACE_PICKER_NAME));
                _placeAddress.setText(bundle.getString(RecommendationOptionFragment.PLACE_PICKER_ADDRESS));
                _placesIcon.setVisibility(View.VISIBLE);
                _editDetail.setEnabled(false);
                _type = "place";
            }
            else if ((bundleValue = bundle.getString(WebFragment.BUNDLE_TAG, null)) != null) {
                _editDetail.setText(bundleValue);
                _editDetail.setEnabled(false);
                _type = "url";
            }
        }
    }

    private class InputChangeWatcher implements TextWatcher {

        private View _view;

        private InputChangeWatcher(View view) {
            _view = view;
        }

        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {

        }

        @Override
        public void afterTextChanged(Editable s) {
            switch (_view.getId()) {
                case R.id.recommendation_detail_input:;
                    _presenter.validateDetail(_editDetail.getText().toString());
                    break;
                case R.id.recommendation_tags_input:
                    _presenter.validateTags(_editTags.getText().toString());
                    break;
            }
        }
    }
}
