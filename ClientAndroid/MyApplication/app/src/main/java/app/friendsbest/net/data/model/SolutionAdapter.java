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

public class SolutionAdapter extends RecyclerView.Adapter<SolutionAdapter.SolutionViewHolder> {

    private List<Solution> _solutions = new ArrayList<>();
    private final LayoutInflater _inflater;
    private final OnListItemClickListener<Solution> _listener;

    public SolutionAdapter(Context context,
                           List<Solution> solutions,
                           OnListItemClickListener listener) {
        _inflater = LayoutInflater.from(context);
        _solutions = solutions;
        _listener = listener;
    }

    @Override
    public SolutionViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = _inflater.inflate(R.layout.solution_item_card, parent, false);
        SolutionViewHolder holder = new SolutionViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(SolutionViewHolder holder, int position) {
        Solution solution = _solutions.get(position);
        holder.bind(solution, _listener);
    }

    @Override
    public int getItemCount() {
        return _solutions.size();
    }

    class SolutionViewHolder extends RecyclerView.ViewHolder {

        CardView _cardView;
        TextView _titleView;
        ImageView _arrowRight;

        public SolutionViewHolder(View itemView) {
            super(itemView);
            _cardView = (CardView) itemView.findViewById(R.id.solution_item_card_view);
            _titleView = (TextView) itemView.findViewById(R.id.solution_item_title);
            _arrowRight = (ImageView) itemView.findViewById(R.id.solution_arrow_right);
        }

        public void bind(final Solution solution, final OnListItemClickListener listener) {
            String detail = solution.getDetail();
            _titleView.setText(detail);

            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onListItemClick(solution);
                }
            });
        }
    }
}
