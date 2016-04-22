package app.friendsbest.net.data.model;

import android.content.Context;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.R;

public class QueryHistoryAdapter extends RecyclerView.Adapter<QueryHistoryAdapter.QueryItemViewHolder> {

    private final OnListItemClickListener<Query> _listener;
    private final LayoutInflater _inflater;
    private Context _context;
    private List<Query> _queries = new ArrayList<>();

    public QueryHistoryAdapter(Context context, List<Query> queries, OnListItemClickListener listener) {
        _context = context;
        _inflater = LayoutInflater.from(context);
        _queries = queries;
        _listener = listener;
    }


    @Override
    public QueryItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = _inflater.inflate(R.layout.item_history_card, parent, false);
        QueryItemViewHolder holder = new QueryItemViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(QueryItemViewHolder holder, int position) {
        Query query = _queries.get(position);
        holder.bind(query, _listener);
    }

    @Override
    public int getItemCount() {
        return _queries.size();
    }

    class QueryItemViewHolder extends RecyclerView.ViewHolder {

        CardView _cardView;
        TextView _textBubbleFirst;
        TextView _textBubbleSecond;
        TextView _textBubbleOverflow;
        TextView _textSolutionCount;
        ImageView _arrowRight;

        public QueryItemViewHolder(View itemView) {
            super(itemView);
            _cardView = (CardView) itemView.findViewById(R.id.history_item_card_view);
            _textBubbleFirst = (TextView) itemView.findViewById(R.id.history_bubble1);
            _textBubbleSecond = (TextView) itemView.findViewById(R.id.history_bubble2);
            _textBubbleOverflow = (TextView) itemView.findViewById(R.id.history_bubble_overflow);
            _textSolutionCount = (TextView) itemView.findViewById(R.id.history_count);
            _arrowRight = (ImageView) itemView.findViewById(R.id.history_arrow_right);
        }

        public void bind(final Query query, final OnListItemClickListener listener) {
            List<String> queryTags = query.getTags();
            int solutionSize = query.getSolutions().size();

            switch (queryTags.size()) {
                case 1:
                    _textBubbleFirst.setText(queryTags.get(0));
                    _textBubbleSecond.setVisibility(View.INVISIBLE);
                    _textBubbleOverflow.setVisibility(View.INVISIBLE);
                    break;
                case 2:
                    _textBubbleFirst.setText(queryTags.get(0));
                    if (_textBubbleSecond.getVisibility() == View.INVISIBLE)
                        _textBubbleSecond.setVisibility(View.VISIBLE);
                    _textBubbleSecond.setText(queryTags.get(1));
                    _textBubbleOverflow.setVisibility(View.INVISIBLE);
                    break;
                case 0:
                    break;
                default:
                    _textBubbleFirst.setText(queryTags.get(0));
                    if (_textBubbleSecond.getVisibility() == View.INVISIBLE)
                        _textBubbleSecond.setVisibility(View.VISIBLE);
                    _textBubbleSecond.setText(queryTags.get(1));
                    if (_textBubbleOverflow.getVisibility() == View.INVISIBLE)
                        _textBubbleOverflow.setVisibility(View.VISIBLE);
                    _textBubbleOverflow.setText(queryTags.get(2));
                    break;
            }

            _textSolutionCount.setVisibility(View.INVISIBLE);
            if (solutionSize > 0) {
                int count = 0;
                List<Solution> solutions = query.getSolutions();
                for (Solution solution : solutions) {
                    for (RecommendationItem item : solution.getRecommendations()) {
                        if (item.isNew())
                            count++;
                    }
                }

                if (count > 0) {
                    _textSolutionCount.setVisibility(View.VISIBLE);
                    _textSolutionCount.setText("" + count);
                }
            }

            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onListItemClick(query);
                }
            });
        }
    }
}
