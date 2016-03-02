package app.friendsbest.net.data.model;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import app.friendsbest.net.R;

public class RecommendationItemAdapter extends ArrayAdapter<RecommendationItem> {

    public RecommendationItemAdapter(Context context, int resource) {
        super(context, resource);
    }

    public RecommendationItemAdapter(Context context, int resource, int textViewResourceId) {
        super(context, resource, textViewResourceId);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        RecommendationItem item = getItem(position);

        if (convertView == null){
            convertView = LayoutInflater.from(getContext())
                    .inflate(R.layout.user_rec_item, parent, false);
        }

        if (item != null) {
            TextView userName = (TextView) convertView.findViewById(R.id.user_name);
            TextView userComment = (TextView) convertView.findViewById(R.id.user_comment);

            userName.setText(item.getUser().getName());
            userComment.setText(item.getComment());
        }
        return convertView;
    }
}
