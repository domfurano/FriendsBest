package app.friendsbest.net.ui.fragment;

import android.app.ListFragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import com.google.gson.Gson;

import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.RecommendationItem;
import app.friendsbest.net.data.model.Solution;

public class RecommendationItemFragment extends ListFragment {

    public static final String TAG = "solutionItemTag";

    private OnFragmentInteractionListener _listener;
    private List<RecommendationItem> _recommendations;
    private String _toolbarTitle;


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_solution_item, container, false);
        init(getArguments());
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
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.onFragmentTitleChange(_toolbarTitle);
    }
}
