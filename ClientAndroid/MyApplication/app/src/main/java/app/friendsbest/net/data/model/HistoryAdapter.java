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

public class HistoryAdapter extends RecyclerView.Adapter<HistoryAdapter.HistoryItemViewHolder> {

    private final OnListItemClickListener<Query> _listener;
    private final LayoutInflater _inflater;
    private List<Query> _queries = new ArrayList<>();

    public HistoryAdapter(Context context, List<Query> queries, OnListItemClickListener listener) {
        _inflater = LayoutInflater.from(context);
        _queries = queries;
        _listener = listener;
    }


    @Override
    public HistoryItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = _inflater.inflate(R.layout.history_item_card, parent, false);
        HistoryItemViewHolder holder = new HistoryItemViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(HistoryItemViewHolder holder, int position) {
        Query query = _queries.get(position);
        holder.bind(query, _listener);
    }

    @Override
    public int getItemCount() {
        return _queries.size();
    }

    class HistoryItemViewHolder extends RecyclerView.ViewHolder {

        CardView _cardView;
        TextView _textBubbleFirst;
        TextView _textBubbleSecond;
        TextView _textBubbleOverflow;
        ImageView _arrowRight;

        public HistoryItemViewHolder(View itemView) {
            super(itemView);
            _cardView = (CardView) itemView.findViewById(R.id.history_item_card_view);
            _textBubbleFirst = (TextView) itemView.findViewById(R.id.history_bubble1);
            _textBubbleSecond = (TextView) itemView.findViewById(R.id.history_bubble2);
            _textBubbleOverflow = (TextView) itemView.findViewById(R.id.history_bubble_overflow);
            _arrowRight = (ImageView) itemView.findViewById(R.id.history_arrow_right);
        }

        public void bind(final Query query, final OnListItemClickListener listener) {
            List<String> queryTags = query.getTags();

            switch (queryTags.size()) {
                case 1:
                    _textBubbleFirst.setText(queryTags.get(0));
                    _textBubbleSecond.setVisibility(View.GONE);
                    _textBubbleOverflow.setVisibility(View.GONE);
                    break;
                case 2:
                    _textBubbleFirst.setText(queryTags.get(0));
                    _textBubbleSecond.setText(queryTags.get(1));
                    _textBubbleOverflow.setVisibility(View.GONE);
                default:
                    _textBubbleFirst.setText(queryTags.get(0));
                    _textBubbleSecond.setText(queryTags.get(1));
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
