package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.gson.Gson;

import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.RecommendationItem;
import app.friendsbest.net.data.model.RecommendationItemAdapter;
import app.friendsbest.net.data.model.Solution;

public class RecommendationItemFragment extends Fragment {

    public static final String TAG = "solutionItemTag";

    private List<RecommendationItem> _recommendations;
    private OnFragmentInteractionListener _listener;
    private RecyclerView _recyclerView;
    private RecommendationItemAdapter _adapter;
    private String _toolbarTitle;


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_recommendation_item, container, false);
        init(getArguments());
        _recyclerView = (RecyclerView) rootView.findViewById(R.id.solution_item_recycler_view);
        _recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
        _adapter = new RecommendationItemAdapter(getActivity(), _recommendations);
        _recyclerView.setAdapter(_adapter);
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
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.showSupportActionBar();
        _listener.onFragmentTitleChange(_toolbarTitle);
    }
}
