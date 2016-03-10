package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.OnListItemClickListener;
import app.friendsbest.net.data.model.QueryResult;
import app.friendsbest.net.data.model.Solution;
import app.friendsbest.net.data.model.SolutionAdapter;
import app.friendsbest.net.presenter.SolutionPresenter;
import app.friendsbest.net.presenter.interfaces.ListPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.view.FragmentView;

public class SolutionFragment extends Fragment implements
        FragmentView<QueryResult>,
        OnListItemClickListener<Solution> {

    public static final String SOLUTION_TAGS = "solutionTag";
    public static final String SOLUTION_ID_TAG = "solutionId";

    private final String _fragmentTitleTag = "fragmentTitle";
    private final String _solutionBundleTag = "solutionBundle";
    private OnFragmentInteractionListener _listener;
    private SolutionAdapter _adapter;
    private RecyclerView _recyclerView;
    private List<Solution> _solutions = new ArrayList<>();
    private QueryResult _queryResult;
    private ProgressBar _progressBar;
    private ListPresenter _presenter;


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_solution, container, false);
        init(getArguments());
        _progressBar = (ProgressBar) rootView.findViewById(R.id.solution_progress_bar);
        _recyclerView = (RecyclerView) rootView.findViewById(R.id.solution_recycler_view);
        _recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
        _adapter = new SolutionAdapter(getActivity(), _solutions, this);
        _recyclerView.setAdapter(_adapter);
        return rootView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.onFragmentTitleChange(_queryResult.getTagString());

        if (savedInstanceState != null) {
            String title = savedInstanceState.getString(_fragmentTitleTag);
            String solutionJson = savedInstanceState.getString(_solutionBundleTag);
            Type type = new TypeToken<List<Solution>>(){}.getType();
            _solutions = new Gson().fromJson(solutionJson, type);
            _listener.onFragmentTitleChange(title);
        }
        else {
            _presenter = new SolutionPresenter(this, getActivity().getApplicationContext());
            _presenter.getData(_queryResult);
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        List<Solution> solutions = new ArrayList<>();
        for (Solution solution : solutions)
            solutions.add(solution);

        Type type = new TypeToken<List<Solution>>(){}.getType();
        String solutionJson = new Gson().toJson(solutions, type);
        outState.putString(_fragmentTitleTag, _queryResult.getTagString());
        outState.putString(_solutionBundleTag, solutionJson);
    }

    @Override
    public void displayContent(QueryResult solution) {
        _solutions = solution.getSolutions();
        _recyclerView.setAdapter(new SolutionAdapter(getActivity(), _solutions, this));
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

    @Override
    public void onListItemClick(Solution item) {
        String itemJson = new Gson().toJson(item, Solution.class);

        Bundle bundle = new Bundle();
        bundle.putString(RecommendationItemFragment.TAG, itemJson);
        _listener.onFragmentChange(DualFragmentActivity.VIEW_SOLUTION_ITEM_ID, bundle);
    }
}
