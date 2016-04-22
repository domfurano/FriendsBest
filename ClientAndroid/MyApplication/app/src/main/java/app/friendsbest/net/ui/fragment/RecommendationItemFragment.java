package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.util.Linkify;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.gson.Gson;

import java.util.Collections;
import java.util.List;
import java.util.Stack;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.RecommendationItem;
import app.friendsbest.net.data.model.RecommendationItemAdapter;
import app.friendsbest.net.data.model.Solution;
import app.friendsbest.net.data.utilities.BusProvider;
import app.friendsbest.net.data.utilities.PreferencesUtility;
import app.friendsbest.net.data.utilities.Repository;
import app.friendsbest.net.presenter.interfaces.BasePresenter;

public class RecommendationItemFragment extends Fragment {

    public static final String TAG = "solutionItemTag";

    private Stack<RecommendationItem> _markAsReadStack;
    private List<RecommendationItem> _recommendations;
    private OnFragmentInteractionListener _listener;
    private RecommendationItemAdapter _adapter;
    private RecyclerView _recyclerView;
    private TextView _infoText;
    private ImageView _infoIcon;
    private String _toolbarTitle;
    private RelativeLayout _infoLayout;
    private Presenter _presenter;


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_recommendation_item, container, false);
        _infoText = (TextView) rootView.findViewById(R.id.recommendation_item_text);
        _infoIcon = (ImageView) rootView.findViewById(R.id.recommendation_item_info_icon);
        _infoLayout = (RelativeLayout) rootView.findViewById(R.id.recommendation_item_info_layout);
        init(getArguments());
        _recyclerView = (RecyclerView) rootView.findViewById(R.id.solution_item_recycler_view);
        _recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
        _adapter = new RecommendationItemAdapter(getActivity(), _recommendations);
        _recyclerView.setAdapter(_adapter);
        return rootView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.showSupportActionBar();
        _listener.onFragmentTitleChange(_toolbarTitle);
        _listener.showBottomNavigationBar();
        _listener.onFragmentToolbarColorChange(R.color.blue_gray200);
        _listener.onFragmentStatusBarChange(R.color.colorPrimaryDark);
    }

    @Override
    public void onPause() {
        super.onPause();
        while(!_markAsReadStack.empty()) {
            _presenter.updateReadStatus(_markAsReadStack.pop());
        }
    }

    private void init(Bundle arguments) {
        String solutionJson = arguments.getString(TAG);
        Solution solution = new Gson().fromJson(solutionJson, Solution.class);
        _toolbarTitle = solution.getDetail();
        _recommendations = solution.getRecommendations();
        Collections.sort(_recommendations, new RecommendationItem());
        String type = solution.getType();
        if (type.equals("url")) {
            _infoText.setText(solution.getDetail());
            Linkify.addLinks(_infoText, Linkify.WEB_URLS);
            _infoIcon.setImageResource(R.drawable.ic_language_white_24px);
        }
        else if (type.equals("place")) {
            String address = solution.getAddress();
            if (address != null) {
                _infoIcon.setImageResource(R.drawable.ic_map_white_24px);
                _infoText.setText(address);
                Linkify.addLinks(_infoText, Linkify.MAP_ADDRESSES);
            }
        }
        else {
            _infoLayout.setVisibility(View.GONE);
        }
        _markAsReadStack = new Stack<>();
        _presenter = new Presenter();
        for (RecommendationItem item : _recommendations) {
            if (item.isNew()) {
                _markAsReadStack.push(item);
//                presenter.updateReadStatus(item);
            }
        }
    }

    private class Presenter implements BasePresenter<Void> {

        private Repository _repository;

        public Presenter() {
            _repository = new Repository(PreferencesUtility.getInstance(getActivity()).getToken(),
                    BusProvider.getInstance());
        }

        public void updateReadStatus(RecommendationItem item) {
            _repository.deleteNotification(item.getId());
        }

        @Override
        public void onPause() {
        }

        @Override
        public void onResume() {
        }
    }
}
