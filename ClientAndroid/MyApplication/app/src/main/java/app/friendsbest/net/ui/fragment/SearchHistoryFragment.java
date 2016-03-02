package app.friendsbest.net.ui.fragment;

import android.app.ListFragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ProgressBar;

import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.presenter.QueryHistoryPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.view.FragmentView;

public class SearchHistoryFragment extends ListFragment implements
        FragmentView<List<Query>>,
        AdapterView.OnItemClickListener {

    private OnFragmentChangeListener _listener;
    private ArrayAdapter<Query> _adapter;
    private ProgressBar _progressBar;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _adapter = new ArrayAdapter<>(getActivity().getApplicationContext(),
                android.R.layout.simple_expandable_list_item_1);
        setListAdapter(_adapter);
        getListView().setOnItemClickListener(this);
        _listener = (OnFragmentChangeListener) getActivity();
        new QueryHistoryPresenter(this, getActivity().getApplicationContext());

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View contentView = inflater.inflate(R.layout.query_history_list, container, false);
        _progressBar = (ProgressBar) contentView.findViewById(R.id.history_fragment_progressbar);
        return contentView;
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        Query query = _adapter.getItem(position);
        Bundle bundle = new Bundle();
        bundle.putInt(SolutionFragment.SOLUTION_ID_TAG, query.getId());
        _listener.onFragmentChange(DualFragmentActivity.VIEW_SOLUTION_ID, bundle);
    }

    @Override
    public void displayContent(List<Query> queries) {
        _adapter.addAll(queries);
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
