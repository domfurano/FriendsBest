package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;

import com.facebook.CallbackManager;
import com.facebook.FacebookSdk;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.ShareDialog;
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
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.view.FragmentView;

public class SolutionFragment extends Fragment implements
        FragmentView<QueryResult>,
        OnListItemClickListener<Solution> {

    public static final String SOLUTION_TAGS = "solutionTag";
    public static final String SOLUTION_ID_TAG = "solutionId";
    public static final String BUTTON_TYPE = "postToFacebookButton";

    private final String _fragmentTitleTag = "fragmentTitle";
    private final String _solutionBundleTag = "solutionBundle";
    private OnFragmentInteractionListener _listener;
    private SolutionAdapter _adapter;
    private RecyclerView _recyclerView;
    private List<Solution> _solutions = new ArrayList<>();
    private QueryResult _queryResult;
    private ProgressBar _progressBar;
    private SolutionPresenter _presenter;
    private CallbackManager _callbackManager;
    private ShareDialog _shareDialog;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_solution, container, false);
        initialize(getArguments());
        _progressBar = (ProgressBar) rootView.findViewById(R.id.solution_progress_bar);
        _recyclerView = (RecyclerView) rootView.findViewById(R.id.solution_recycler_view);
        _recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
        _adapter = new SolutionAdapter(getActivity(), _solutions, this);
        _recyclerView.setAdapter(_adapter);
        if (_solutions.size() > 1){
            hideProgressBar();
        }
        return rootView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        FacebookSdk.sdkInitialize(getActivity().getApplicationContext());
        _callbackManager = CallbackManager.Factory.create();
        _shareDialog = new ShareDialog(getActivity());
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.showSupportActionBar();
        _listener.onFragmentTitleChange(_queryResult.getTagString());
        _listener.onFragmentToolbarColorChange(R.color.blue_gray200);
        _listener.onFragmentStatusBarChange(R.color.colorPrimaryDark);
        _listener.showBottomNavigationBar();

        if (savedInstanceState != null) {
            String title = savedInstanceState.getString(_fragmentTitleTag);
            String solutionJson = savedInstanceState.getString(_solutionBundleTag);
            Type type = new TypeToken<List<Solution>>(){}.getType();
            _solutions = new Gson().fromJson(solutionJson, type);
            _listener.onFragmentTitleChange(title);
        }
        else {
            _presenter = new SolutionPresenter(this, getActivity().getApplicationContext());
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        _presenter.onResume();
        _presenter.getData(_queryResult);
    }

    @Override
    public void onPause() {
        super.onPause();
        _presenter.onPause();
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.menu_recommendation_item, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.action_delete) {
            if (_queryResult != null) {
                _presenter.deleteSearch(_queryResult.getId());
                _listener.onFragmentChange("");
            }
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
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
        if (getActivity() == null) {
            return;
        }
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

    private void initialize(Bundle bundle) {
        int solutionId = bundle.getInt(SOLUTION_ID_TAG);
        String tagString = bundle.getString(SOLUTION_TAGS);
        _queryResult = new QueryResult();
        _queryResult.setId(solutionId);
        _queryResult.setTagString(tagString);
    }

    @Override
    public void onListItemClick(Solution item) {
        if (item.getType().equals(BUTTON_TYPE)) {
            Log.i("SolutionFragment", "Clicked post to facebook button");
            if (ShareDialog.canShow(ShareLinkContent.class)) {
                ShareLinkContent linkContent = new ShareLinkContent.Builder()
                        .setContentTitle("I need a recommendation for '" + _queryResult.getTagString() + "'")
                        .setContentDescription(
                                "Please join me on FriendsBest.net and share your recommendation!")
                        .setContentUrl(Uri.parse("http://www.friendsbest.net/fb/link/" + _queryResult.getId() + "/"))
                        .build();

                _shareDialog.show(linkContent);
            }
        }
        else {
            String itemJson = new Gson().toJson(item, Solution.class);

            Bundle bundle = new Bundle();
            bundle.putString(RecommendationItemFragment.TAG, itemJson);
            _listener.onFragmentChange(DualFragmentActivity.VIEW_SOLUTION_ITEM_ID, bundle);
        }
    }
}
