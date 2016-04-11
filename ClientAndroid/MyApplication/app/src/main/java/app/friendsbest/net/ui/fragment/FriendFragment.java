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
import app.friendsbest.net.data.model.Friend;
import app.friendsbest.net.data.model.FriendAdapter;
import app.friendsbest.net.data.model.OnListItemClickListener;
import app.friendsbest.net.presenter.FriendPresenter;
import app.friendsbest.net.ui.view.DualFragmentView;

public class FriendFragment extends Fragment implements OnListItemClickListener<Friend> {

    public static final String BUNDLE_KEY = "key";
    private FriendPresenter _presenter;
    private List<Friend> _friends = new ArrayList<>();

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        OnFragmentInteractionListener listener = (DualFragmentView) getActivity();
        listener.showSupportActionBar();
        listener.onFragmentTitleChange("Facebook Friends");
        listener.onFragmentToolbarColorChange(R.color.blue900);
        listener.onFragmentStatusBarChange(R.color.blue900);
        listener.showBottomNavigationBar();
        _presenter = new FriendPresenter(getActivity().getApplicationContext(), this);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_friend, container, false);
        init(getArguments());
        RecyclerView recyclerView = (RecyclerView) rootView.findViewById(R.id.fragment_friend_recycler_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(getActivity().getApplicationContext()));
        FriendAdapter adapter = new FriendAdapter(getActivity(), _friends, this);
        recyclerView.setAdapter(adapter);
        return rootView;
    }

    private void init(Bundle arguments) {
        String friendListJson = arguments.getString(BUNDLE_KEY);
        Type type = new TypeToken<List<Friend>>(){}.getType();
        _friends = new Gson().fromJson(friendListJson, type);
    }

    @Override
    public void onListItemClick(Friend item) {
        _presenter.changeMuteState(item);
    }
}
