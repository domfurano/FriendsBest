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
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.OnListItemClickListener;
import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.model.RecommendationAdapter;
import app.friendsbest.net.ui.view.DualFragmentView;

public class RecommendationFragment extends Fragment implements OnListItemClickListener<Recommendation> {

    public static final String BUNDLE_KEY = "bundle_key";
    private List<Recommendation> _recommendationList = new ArrayList<>();

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        DualFragmentView view = (DualFragmentView) getActivity();
        view.showSupportActionBar();
        view.onFragmentTitleChange("Your Recommendations");
        view.onFragmentToolbarChange(R.color.appGreen);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_profile_recommendation, container, false);
        init(getArguments());
        RecyclerView recyclerView = (RecyclerView) rootView.findViewById(R.id.recommendation_recycler_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(getActivity().getApplicationContext()));
        RecommendationAdapter adapter = new RecommendationAdapter(getActivity().getApplicationContext(), _recommendationList, this);
        recyclerView.setAdapter(adapter);
        return rootView;
    }

    private void init(Bundle arguments) {
        String recommendationListJson = arguments.getString(BUNDLE_KEY);
        Type type = new TypeToken<List<Recommendation>>(){}.getType();
        _recommendationList = new Gson().fromJson(recommendationListJson, type);
    }

    @Override
    public void onListItemClick(Recommendation item) {

    }
}
