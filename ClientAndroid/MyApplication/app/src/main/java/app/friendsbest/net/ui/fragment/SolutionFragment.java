package app.friendsbest.net.ui.fragment;

import android.app.ListFragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ProgressBar;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
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

    public static final String SOLUTION_TAGS = "solutionTag";
    public static final String SOLUTION_ID_TAG = "solutionId";

    private final String _fragmentTitleTag = "fragmentTitle";
    private final String _solutionBundleTag = "solutionBundle";
    private OnFragmentInteractionListener _listener;
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
        return rootView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _arrayAdapter = new ArrayAdapter<>(getActivity().getApplicationContext(),
                android.R.layout.simple_expandable_list_item_1);
        setListAdapter(_arrayAdapter);
        getListView().setOnItemClickListener(this);
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.onFragmentTitleChange(_queryResult.getTagString());
        _presenter = new SolutionPresenter(this, getActivity().getApplicationContext());
        _presenter.getData(_queryResult);
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        List<Solution> solutions = new ArrayList<>();
        for (int i = 0; i < _arrayAdapter.getCount(); i++)
            solutions.add(_arrayAdapter.getItem(i));

        Type type = new TypeToken<List<Solution>>(){}.getType();
        String solutionJson = new Gson().toJson(solutions, type);
        outState.putString(_fragmentTitleTag, _queryResult.getTagString());
        outState.putString(_solutionBundleTag, solutionJson);
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

    private void init(Bundle bundle) {
        int solutionId = bundle.getInt(SOLUTION_ID_TAG);
        String tagString = bundle.getString(SOLUTION_TAGS);
        _queryResult = new QueryResult();
        _queryResult.setId(solutionId);
        _queryResult.setTagString(tagString);
    }
}
