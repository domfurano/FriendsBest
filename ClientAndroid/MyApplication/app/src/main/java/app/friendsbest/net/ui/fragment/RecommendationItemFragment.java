package app.friendsbest.net.ui.fragment;

import android.app.ListFragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import com.google.gson.Gson;

import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.RecommendationItem;
import app.friendsbest.net.data.model.Solution;
import app.friendsbest.net.ui.DualFragmentActivity;

public class RecommendationItemFragment extends ListFragment {

    public static final String TAG = "solutionItemTag";

    private OnFragmentChangeListener _listener;
    private List<RecommendationItem> _recommendations;
    private String _toolbarTitle;


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_solution_item, container, false);
        init(getArguments());
        Toolbar toolbar = (Toolbar) rootView.findViewById(R.id.solution_item_toolbar);
        toolbar.setTitle(_toolbarTitle);
        AppCompatActivity activity = (AppCompatActivity) getActivity();
        activity.setSupportActionBar(toolbar);
        activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        return rootView;
    }

    private void init(Bundle arguments) {
        String solutionJson = arguments.getString(TAG);
        Solution solution = new Gson().fromJson(solutionJson, Solution.class);
        _toolbarTitle = solution.getDetail();
        _recommendations = solution.getRecommendations();
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        ArrayAdapter<RecommendationItem> adapter =
                new ArrayAdapter<>(getActivity().getApplicationContext(),
                android.R.layout.simple_expandable_list_item_1);
        setListAdapter(adapter);
        adapter.addAll(_recommendations);
        _listener = (OnFragmentChangeListener) getActivity();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            _listener.onFragmentChange(DualFragmentActivity.VIEW_SOLUTION_ID);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
