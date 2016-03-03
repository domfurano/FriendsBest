package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
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
import app.friendsbest.net.data.model.HistoryAdapter;
import app.friendsbest.net.data.model.OnListItemClickListener;
import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.presenter.QueryHistoryPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.view.FragmentView;

public class SearchHistoryFragment extends Fragment implements
        OnListItemClickListener<Query>,
        FragmentView<List<Query>> {

    private OnFragmentInteractionListener _listener;
    private HistoryAdapter _adapter;
    private RecyclerView _recyclerView;
    private ProgressBar _progressBar;
    private List<Query> _queries = new ArrayList<>();

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.onFragmentTitleChange("");
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View contentView = inflater.inflate(R.layout.query_history_list, container, false);
        _progressBar = (ProgressBar) contentView.findViewById(R.id.history_fragment_progressbar);
        new QueryHistoryPresenter(this, getActivity().getApplicationContext());
        _recyclerView = (RecyclerView) contentView.findViewById(R.id.recycler_view);
        _recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
        _adapter = new HistoryAdapter(getActivity(), _queries, this);
        _recyclerView.setAdapter(_adapter);
        return contentView;
    }

    @Override
    public void displayContent(List<Query> queries) {
        _recyclerView.setAdapter(new HistoryAdapter(getActivity(), queries, this));
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
