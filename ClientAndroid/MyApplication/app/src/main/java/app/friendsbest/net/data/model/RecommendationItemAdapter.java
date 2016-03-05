package app.friendsbest.net.data.model;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.services.ImageService;

public class RecommendationItemAdapter extends RecyclerView.Adapter<RecommendationItemAdapter.RecommendationItemViewHolder> {

    private final LayoutInflater _inflater;
    private final Context _context;
    private List<RecommendationItem> _recommendationItems = new ArrayList<>();

    public RecommendationItemAdapter(Context context, List<RecommendationItem> recommendationItems) {
        _inflater = LayoutInflater.from(context);
        _context = context;
        _recommendationItems = recommendationItems;
    }

    @Override
    public RecommendationItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = _inflater.inflate(R.layout.recommendation_row, parent, false);
        RecommendationItemViewHolder holder = new RecommendationItemViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(RecommendationItemViewHolder holder, int position) {
        RecommendationItem item = _recommendationItems.get(position);
        holder._nameTextView.setText(item.getUser().getName());
        holder._commentTextView.setText(item.getComment());
        ImageService.getInstance(_context).retrieveProfileImage(holder._profilePicture, item.getUser().getId(), ImageService.PictureSize.MEDIUM);
    }

    @Override
    public int getItemCount() {
        return _recommendationItems.size();
    }

    class RecommendationItemViewHolder extends RecyclerView.ViewHolder {

        ImageView _profilePicture;
        TextView _nameTextView;
        TextView _commentTextView;

        public RecommendationItemViewHolder(View itemView) {
            super(itemView);
            _nameTextView = (TextView) itemView.findViewById(R.id.recommendation_row_detail_view);
            _commentTextView = (TextView) itemView.findViewById(R.id.recommendation_row_comment_view);
            _profilePicture = (ImageView) itemView.findViewById(R.id.recommendation_row_image_view);
        }
    }
}