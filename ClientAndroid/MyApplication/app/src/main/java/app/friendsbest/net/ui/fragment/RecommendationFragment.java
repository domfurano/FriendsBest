package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.location.places.Place;
import com.google.android.gms.location.places.Places;
import com.google.android.gms.location.places.ui.PlaceAutocompleteFragment;
import com.google.android.gms.location.places.ui.PlaceSelectionListener;

import app.friendsbest.net.R;
import app.friendsbest.net.presenter.RecommendationPresenter;
import app.friendsbest.net.presenter.interfaces.RecommendPresenter;
import app.friendsbest.net.ui.MainActivity;
import app.friendsbest.net.ui.view.RecommendView;

public class RecommendationFragment extends Fragment implements RecommendView {
    private TextView _recommendTitle;
    private TextView _tagsTitle;
    private TextView _commentTitle;
    private EditText _editTags;
    private EditText _editComment;
    private Button _submitButton;
    private RecommendPresenter _presenter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View fragmentView = inflater.inflate(R.layout.activity_create_rec, container, false);
        _recommendTitle = (TextView) fragmentView.findViewById(R.id.rec_title_input_label);
        _tagsTitle = (TextView) fragmentView.findViewById(R.id.rec_tags_input_label);
        _commentTitle = (TextView) fragmentView.findViewById(R.id.rec_comments_label);

        _editTags = (EditText) fragmentView.findViewById(R.id.rec_tags_input);
        _editComment = (EditText) fragmentView.findViewById(R.id.rec_comments_input);

        _submitButton = (Button) fragmentView.findViewById(R.id.add_recommendation_button);
        return fragmentView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _presenter = new RecommendationPresenter(this, getActivity().getApplicationContext());
        _submitButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i("Add Recommendation", "Clicked submit button");
            }
        });

        PlaceAutocompleteFragment autocompleteFragment = (PlaceAutocompleteFragment)
                getChildFragmentManager().findFragmentById(R.id.place_autocomplete_fragment);
        autocompleteFragment.setOnPlaceSelectedListener(new PlaceSelectionListener() {
            @Override
            public void onPlaceSelected(Place place) {
                Log.i("GooglePlacesAPI", "Place: " + place.getName());
            }

            @Override
            public void onError(Status status) {
                Log.i("GooglePlacesAPI", "An error occured: " + status);
            }
        });
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void startMainActivity(boolean posted) {
    }
}
