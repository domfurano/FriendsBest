package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import app.friendsbest.net.R;
import app.friendsbest.net.presenter.RecommendationPresenter;
import app.friendsbest.net.presenter.interfaces.RecommendPresenter;
import app.friendsbest.net.ui.view.RecommendView;

public class RecommendationFragment extends Fragment implements RecommendView {

    private TextView _recommendTitle;
    private TextView _tagsTitle;
    private TextView _commentTitle;
    private EditText _editRecommendation;
    private EditText _editTags;
    private EditText _editComment;
    private Button _submitButton;
    private RecommendPresenter _presenter;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        _presenter = new RecommendationPresenter(this, getActivity().getApplicationContext());
        _submitButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                _presenter.submitRecommendation(
                        _editRecommendation.getText().toString(),
                        _editTags.getText().toString(),
                        _editComment.getText().toString());
            }
        });
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View fragmentView = inflater.inflate(R.layout.activity_create_rec, container, false);
        _recommendTitle = (TextView) fragmentView.findViewById(R.id.rec_title_input_label);
        _tagsTitle = (TextView) fragmentView.findViewById(R.id.rec_tags_input_label);
        _commentTitle = (TextView) fragmentView.findViewById(R.id.rec_comments_label);

        _editRecommendation = (EditText) fragmentView.findViewById(R.id.rec_title_input);
        _editTags = (EditText) fragmentView.findViewById(R.id.rec_tags_input);
        _editComment = (EditText) fragmentView.findViewById(R.id.rec_comments_input);

        _submitButton = (Button) fragmentView.findViewById(R.id.add_recommendation_button);
        return fragmentView;
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void startMainActivity(boolean posted) {
    }
}
