package app.friendsbest.net.data.model;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.Switch;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.services.ImageService;

public class FriendAdapter extends RecyclerView.Adapter<FriendAdapter.FriendViewHolder> {

    private final OnListItemClickListener<Query> _listener;
    private final LayoutInflater _inflater;
    private List<Friend> _friendsList = new ArrayList<>();
    private Context _context;

    public FriendAdapter(Context context, List<Friend> friendList, OnListItemClickListener listener) {
        _context = context;
        _inflater = LayoutInflater.from(context);
        _friendsList = friendList;
        _listener = listener;
    }


    @Override
    public FriendViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = _inflater.inflate(R.layout.friend_item_card, parent, false);
        FriendViewHolder holder = new FriendViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(FriendViewHolder holder, int position) {
        Friend friend = _friendsList.get(position);
        holder.bind(friend, _listener);
    }

    @Override
    public int getItemCount() {
        return _friendsList.size();
    }

    class FriendViewHolder extends RecyclerView.ViewHolder {

        TextView _friendNameTextView;
        TextView _muteTextView;
        Switch _muteSwitchView;
        ImageView _profileImageView;

        public FriendViewHolder(View itemView) {
            super(itemView);
            _friendNameTextView = (TextView) itemView.findViewById(R.id.friend_item_friend_name);
            _muteTextView = (TextView) itemView.findViewById(R.id.friend_item_mute_text);
            _muteSwitchView = (Switch) itemView.findViewById(R.id.friend_item_mute_switch);
            _profileImageView = (ImageView) itemView.findViewById(R.id.friend_item_picture_view);
        }

        public void bind(final Friend friend, final OnListItemClickListener listener) {

            _friendNameTextView.setText(friend.getName());
            _muteTextView.setText(getSwitchText(friend.isMuted()));
            _muteSwitchView.setChecked(friend.isMuted());

            ImageService.getInstance(_context)
                    .retrieveProfileImage(
                            _profileImageView,
                            friend.getId(),
                            ImageService.PictureSize.MEDIUM);
            _muteSwitchView.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    friend.setMuted(isChecked);
                    _muteTextView.setText(getSwitchText(isChecked));
                    listener.onListItemClick(friend);
                }
            });
        }

        private String getSwitchText(boolean state) {
            return state ? "Unmute" : "Mute";
        }
    }
}
