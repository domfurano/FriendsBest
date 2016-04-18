package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.Snackbar;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.List;
import java.util.Queue;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.OnListItemClickListener;
import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.model.RecommendationAdapter;
import app.friendsbest.net.presenter.RecommendationPresenter;
import app.friendsbest.net.ui.view.DualFragmentView;

public class RecommendationFragment extends Fragment implements OnListItemClickListener<Recommendation> {

    public static final String BUNDLE_KEY = "bundle_key";
    private RecommendationAdapter _adapter;
    private CoordinatorLayout _parentLayout;
    private RecommendationPresenter _presenter;
    private Queue<Recommendation> _deleteQueue;
    private List<Recommendation> _recommendationList = new ArrayList<>();

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        OnFragmentInteractionListener listener = (DualFragmentView) getActivity();
        listener.showSupportActionBar();
        listener.onFragmentTitleChange("Your Recommendations");
        listener.onFragmentToolbarColorChange(R.color.appGreen);
        listener.onFragmentStatusBarChange(R.color.appGreenDark);
        listener.showBottomNavigationBar();
        _presenter = new RecommendationPresenter(getActivity(), this);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_profile_recommendation, container, false);
        init(getArguments());
        _parentLayout = (CoordinatorLayout) rootView.findViewById(R.id.fragment_profile_parent_layout);
        RecyclerView recyclerView = (RecyclerView) rootView.findViewById(R.id.recommendation_recycler_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(getActivity().getApplicationContext()));
        _adapter = new RecommendationAdapter(getActivity(), _recommendationList, this);
        recyclerView.setAdapter(_adapter);
        return rootView;
    }

    @Override
    public void onPause() {
        super.onPause();
        while (!_deleteQueue.isEmpty()) {
            _presenter.deleteRecommendation(_deleteQueue.poll());
        }
    }

    private void init(Bundle arguments) {
        String recommendationListJson = arguments.getString(BUNDLE_KEY);
        Type type = new TypeToken<List<Recommendation>>(){}.getType();
        _recommendationList = new Gson().fromJson(recommendationListJson, type);
        _deleteQueue = new ArrayDeque<>();
    }

    public void removeRecommendationItem(int id) {
        int removeIndex = -1;
        for (int i = 0; i < _recommendationList.size(); i++) {
            if (_recommendationList.get(i).getId() == id) {
                removeIndex = i;
                break;
            }
        }

        if (removeIndex >= 0) {
            Recommendation item =_recommendationList.remove(removeIndex);
            _adapter.notifyDataSetChanged();
            _deleteQueue.offer(item);
            notifyUser(removeIndex);

        }
    }

    private void notifyUser(final int index) {
        Snackbar snackbar = Snackbar.make(_parentLayout, "Recommendation Deleted", Snackbar.LENGTH_SHORT);
        snackbar.setAction("UNDO", new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!_deleteQueue.isEmpty()) {
                   Recommendation item =  _deleteQueue.poll();
                    _recommendationList.add(index, item);
                    _adapter.notifyDataSetChanged();
                }
            }
        }).show();
    }

    @Override
    public void onListItemClick(Recommendation item) {
        removeRecommendationItem(item.getId());
    }
}
