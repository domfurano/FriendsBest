package app.friendsbest.net.data.model;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.R;

public class RecommendationItemAdapter extends RecyclerView.Adapter<RecommendationItemAdapter.RecommendationItemViewHolder> {

    private final LayoutInflater _inflater;
    private List<RecommendationItem> _recommendationItems = new ArrayList<>();

    public RecommendationItemAdapter(Context context, List<RecommendationItem> recommendationItems) {
        _inflater = LayoutInflater.from(context);
        _recommendationItems = recommendationItems;
    }

    @Override
    public RecommendationItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = _inflater.inflate(R.layout.recommendation_item_card, parent, false);
        RecommendationItemViewHolder holder = new RecommendationItemViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(RecommendationItemViewHolder holder, int position) {
        RecommendationItem item = _recommendationItems.get(position);
        holder._titleTextView.setText(item.getUser().getName());
        holder._descriptionTextView.setText(item.getComment());
    }

    @Override
    public int getItemCount() {
        return _recommendationItems.size();
    }

    class RecommendationItemViewHolder extends RecyclerView.ViewHolder {

        TextView _titleTextView;
        TextView _descriptionTextView;

        public RecommendationItemViewHolder(View itemView) {
            super(itemView);
            _titleTextView = (TextView) itemView.findViewById(R.id.recommendation_item_title);
            _descriptionTextView = (TextView) itemView.findViewById(R.id.recommendation_item_description);
        }
    }
}
