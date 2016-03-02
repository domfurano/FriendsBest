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
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ProgressBar;

import com.google.gson.Gson;

import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.QueryResult;
import app.friendsbest.net.data.model.Solution;
import app.friendsbest.net.presenter.SolutionPresenter;
import app.friendsbest.net.presenter.interfaces.ListFragmentPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.view.FragmentView;

public class SolutionFragment extends ListFragment implements
        FragmentView<QueryResult>,
        AdapterView.OnItemClickListener {

    public static final String SOLUTION_TAG = "solutionTag";
    public static final String SOLUTION_ID_TAG = "solutionId";

    private OnFragmentChangeListener _listener;
    private ArrayAdapter<Solution> _arrayAdapter;
    private ListFragmentPresenter _presenter;
    private QueryResult _queryResult;
    private ProgressBar _progressBar;


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_solution, container, false);
        init(getArguments());

        _progressBar = (ProgressBar) rootView.findViewById(R.id.solution_progress_bar);

        Toolbar toolbar = (Toolbar) rootView.findViewById(R.id.solution_toolbar);
        toolbar.setTitle(_queryResult.getTagString());
        AppCompatActivity activity = (AppCompatActivity) getActivity();
        activity.setSupportActionBar(toolbar);
        activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        return rootView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _arrayAdapter = new ArrayAdapter<>(getActivity().getApplicationContext(),
                android.R.layout.simple_expandable_list_item_1);
        setListAdapter(_arrayAdapter);
        getListView().setOnItemClickListener(this);
        _listener = (OnFragmentChangeListener) getActivity();
        _presenter = new SolutionPresenter(this, getActivity().getApplicationContext());
        _presenter.getData(_queryResult);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home){
            _listener.onFragmentChangeResult(null);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void init(Bundle bundle) {
        int solutionId = bundle.getInt(SOLUTION_ID_TAG);
        _queryResult = new QueryResult();
        _queryResult.setId(solutionId);
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        Solution solution = _arrayAdapter.getItem(position);
        String itemJson = new Gson().toJson(solution, Solution.class);

        Bundle bundle = new Bundle();
        bundle.putString(RecommendationItemFragment.TAG, itemJson);
        _listener.onFragmentChange(DualFragmentActivity.VIEW_SOLUTION_ITEM_ID, bundle);
    }

    @Override
    public void displayContent(QueryResult solution) {
        List<Solution> recommendations = solution.getSolutions();
        _arrayAdapter.addAll(recommendations);
    }

    @Override
    public void showProgressBar() {
        _progressBar.setVisibility(View.VISIBLE);
    }

    @Override
    public void hideProgressBar() {
        _progressBar.setVisibility(View.GONE);
    }

    @Override
    public void displayMessage(String message) {

    }
}
