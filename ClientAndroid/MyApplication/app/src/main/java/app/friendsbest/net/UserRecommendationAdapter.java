package app.friendsbest.net;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import java.util.ArrayList;

import app.friendsbest.net.data.model.UserRecommendation;

public class UserRecommendationAdapter extends ArrayAdapter<UserRecommendation> {

    public UserRecommendationAdapter(Context context,
                                     int resource,
                                     ArrayList<UserRecommendation> recommendations) {
        super(context, resource, recommendations);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        UserRecommendation item = getItem(position);

        if (convertView == null){
            convertView = LayoutInflater.from(getContext())
                    .inflate(R.layout.user_rec_item, parent, false);
        }

        if (item != null) {
            TextView userName = (TextView) convertView.findViewById(R.id.user_name);
            TextView userComment = (TextView) convertView.findViewById(R.id.user_comment);

            userName.setText(item.getName());
            userComment.setText(item.getComment());
        }
        return convertView;
    }
}
