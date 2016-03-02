package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.location.places.Place;
import com.google.android.gms.location.places.ui.PlaceAutocompleteFragment;
import com.google.android.gms.location.places.ui.PlaceSelectionListener;

import app.friendsbest.net.R;
import app.friendsbest.net.data.services.FontManager;
import app.friendsbest.net.presenter.RecommendationPresenter;
import app.friendsbest.net.presenter.interfaces.RecommendPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.MainActivity;
import app.friendsbest.net.ui.view.RecommendView;

public class RecommendationFragment extends Fragment implements
        RecommendView,
        View.OnClickListener {

    public static final String BUNDLE_KEY = "addRecommendationKey";
    private RecommendPresenter _presenter;
    private EditText _editTags;
    private EditText _editComment;
//    private TextView _submitButton;
    private Button _submitButton;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View fragmentView = inflater.inflate(R.layout.fragment_recommend, container, false);
        FontManager.markAsIconContainer(fragmentView.findViewById(R.id.add_recommendation_toolbar), DualFragmentActivity._typeFace);

        _editTags = (EditText) fragmentView.findViewById(R.id.rec_tags_input);
        _editComment = (EditText) fragmentView.findViewById(R.id.rec_comments_input);

        _submitButton = (Button) fragmentView.findViewById(R.id.add_recommendation_button);
        _submitButton.setOnClickListener(this);

        Toolbar toolbar = (Toolbar) fragmentView.findViewById(R.id.add_recommendation_toolbar);
        toolbar.setTitle(R.string.add_recommendation);
        AppCompatActivity activity = (AppCompatActivity) getActivity();
        activity.setSupportActionBar(toolbar);
        activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true);

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
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            startMainActivity(false);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void startMainActivity(boolean posted) {
        Intent intent = new Intent(getActivity(), MainActivity.class);
        intent.putExtra(BUNDLE_KEY, posted);
        startActivity(intent);
        getActivity().finish();
    }

    @Override
    public void onClick(View v) {
        if (v == _submitButton) {
            String hello = "hello";
        }
    }
}
