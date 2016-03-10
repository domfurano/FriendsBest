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
        View view = _inflater.inflate(R.layout.recommendation_row, parent, false);
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
        ImageView _imageView;

        public RecommendationViewHolder(View itemView) {
            super(itemView);
            _commentTextView = (TextView) itemView.findViewById(R.id.recommendation_row_comment_view);
            _detailTextView = (TextView) itemView.findViewById(R.id.recommendation_row_detail_view);
            _imageView = (ImageView) itemView.findViewById(R.id.recommendation_row_image_view);
        }

        public void bind(final Recommendation recommendation, final OnListItemClickListener listener) {
            _commentTextView.setText(recommendation.getComment());
            _detailTextView.setText(recommendation.getDetail());
            ImageService.getInstance(_context)
                    .retrieveProfileImage(
                            _imageView,
                            recommendation.getUser().getId(),
                            ImageService.PictureSize.MEDIUM);

            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onListItemClick(recommendation);
                }
            });
        }
    }
}
