package app.friendsbest.net.data.model;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.text.util.Linkify;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.R;

public class RecommendationAdapter extends RecyclerView.Adapter<RecommendationAdapter.RecommendationViewHolder> {

    private final OnListItemClickListener<Recommendation> _listener;
    private final Context _context;
    private final LayoutInflater _inflater;
    private List<Recommendation> _recommendationList = new ArrayList<>();


    public RecommendationAdapter
            (
                    Context context,
                    List<Recommendation> recommendations,
                    OnListItemClickListener listener
            ) {
        _context = context;
        _listener = listener;
        _recommendationList = recommendations;
        _inflater = LayoutInflater.from(context);
    }

    @Override
    public RecommendationViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = _inflater.inflate(R.layout.item_profile_recommendation, parent, false);
        RecommendationViewHolder holder = new RecommendationViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(RecommendationViewHolder holder, int position) {
        Recommendation recommendation = _recommendationList.get(position);
        holder.bind(recommendation, _listener);
    }

    @Override
    public int getItemCount() {
        return _recommendationList.size();
    }

    class RecommendationViewHolder extends RecyclerView.ViewHolder {

        TextView _commentTextView;
        TextView _detailTextView;
        TextView _tagsTextView;
        ImageButton _deleteButton;

        public RecommendationViewHolder(View itemView) {
            super(itemView);
            _commentTextView = (TextView) itemView.findViewById(R.id.profile_recommendation_description);
            _detailTextView = (TextView) itemView.findViewById(R.id.profile_recommendation_title);
            _tagsTextView = (TextView) itemView.findViewById(R.id.profile_recommendation_tags_text);
            _deleteButton = (ImageButton) itemView.findViewById(R.id.profile_recommendation_delete);
        }

        public void bind(final Recommendation recommendation, final OnListItemClickListener listener) {
            List<String> tags = recommendation.getTags();
            StringBuilder sb = new StringBuilder(tags.get(0));
            String type = recommendation.getType();
            for (int i = 1; i < tags.size(); i++) {
                sb.append(" ").append(tags.get(i));
            }

            _commentTextView.setText(recommendation.getComment());
            _detailTextView.setText(recommendation.getDetail());
            _tagsTextView.setText(sb.toString());

            if (type.equals("url")) {
                Linkify.addLinks(_detailTextView, Linkify.WEB_URLS);
            }

            _deleteButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onListItemClick(recommendation);
                }
            });
        }
    }
}
