package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.transition.Fade;
import android.transition.Slide;
import android.transition.Transition;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.OnListItemClickListener;
import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.data.model.QueryHistoryAdapter;
import app.friendsbest.net.presenter.QueryHistoryPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.view.FragmentView;

public class QueryHistoryFragment extends Fragment implements
        OnListItemClickListener<Query>,
        FragmentView<List<Query>> {

    private OnFragmentInteractionListener _listener;
    private QueryHistoryAdapter _adapter;
    private QueryHistoryPresenter _presenter;
    private RecyclerView _recyclerView;
    private ProgressBar _progressBar;
    private List<Query> _queries = new ArrayList<>();

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        LinearLayoutManager manager = new LinearLayoutManager(getActivity());
        _recyclerView.setLayoutManager(manager);
        _presenter = new QueryHistoryPresenter(this, getActivity());
        _adapter = new QueryHistoryAdapter(getActivity(), _queries, this);
        _recyclerView.setAdapter(_adapter);

        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.showSupportActionBar();
        _listener.onFragmentTitleChange("Search History");
        _listener.onFragmentToolbarColorChange(R.color.blue_gray200);
        _listener.showBottomNavigationBar();

        if (_queries.size() > 0) {
            hideProgressBar();
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View contentView = inflater.inflate(R.layout.list_query_history, container, false);
        _progressBar = (ProgressBar) contentView.findViewById(R.id.history_fragment_progressbar);
        _recyclerView = (RecyclerView) contentView.findViewById(R.id.recycler_view);
        Transition fade = new Fade();
        Transition slide = new Slide();
        slide.setDuration(2000);
        fade.setDuration(2000);

        setEnterTransition(fade);
        setReturnTransition(slide);
        return contentView;
    }

    @Override
    public void onPause() {
        super.onPause();
        _presenter.closeRepository();
    }

    @Override
    public void displayContent(List<Query> queries) {
        Collections.reverse(queries);
        _recyclerView.setAdapter(new QueryHistoryAdapter(getActivity(), queries, this));
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

    @Override
    public void onListItemClick(Query query) {
        Bundle bundle = new Bundle();
        String tagString = "";
        for (String tag : query.getTags())
            tagString += tag + " ";
        bundle.putInt(SolutionFragment.SOLUTION_ID_TAG, query.getId());
        bundle.putString(SolutionFragment.SOLUTION_TAGS, tagString);
        _listener.onFragmentChange(DualFragmentActivity.VIEW_SOLUTION_ID, bundle);
    }
}
