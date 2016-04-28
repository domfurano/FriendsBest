package app.friendsbest.net.data.model;

import android.content.Context;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.location.places.Place;
import com.google.android.gms.location.places.PlaceBuffer;
import com.google.android.gms.location.places.Places;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.fragment.SolutionFragment;

public class SolutionAdapter extends RecyclerView.Adapter<SolutionAdapter.SolutionViewHolder> {

    public static final int SOLUTION_ITEM = 0;
    public static final int BUTTON_ITEM = 1;
    private List<Solution> _solutions = new ArrayList<>();
    private final LayoutInflater _inflater;
    private final Context _context;
    private final OnListItemClickListener<Solution> _listener;

    public SolutionAdapter(Context context,
                           List<Solution> solutions,
                           OnListItemClickListener listener) {
        _inflater = LayoutInflater.from(context);
        _solutions = solutions;
        _listener = listener;
        _context = context;
    }

    @Override
    public SolutionViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view;
        if (viewType == SOLUTION_ITEM) {
            view = _inflater.inflate(R.layout.item_solution_card, parent, false);
        }
        else {
            view = _inflater.inflate(R.layout.item_facebook_post, parent, false);
        }
        SolutionViewHolder holder = new SolutionViewHolder(view);
        return holder;
    }

    @Override
    public void onBindViewHolder(SolutionViewHolder holder, int position) {
        if (position == _solutions.size()) {
            holder.bindButton(_listener);
        }
        else {
            Solution solution = _solutions.get(position);
            holder.bind(solution, _listener);
        }
    }

    @Override
    public int getItemCount() {
        return _solutions.size() + 1;
    }

    @Override
    public int getItemViewType(int position) {
        return (position == _solutions.size()) ? BUTTON_ITEM : SOLUTION_ITEM;
    }

    class SolutionViewHolder extends RecyclerView.ViewHolder {

        CardView _cardView;
        TextView _titleView;
        TextView _subtitleView;
        ImageView _arrowRight;

        public SolutionViewHolder(View itemView) {
            super(itemView);
            _cardView = (CardView) itemView.findViewById(R.id.solution_item_card_view);
            _titleView = (TextView) itemView.findViewById(R.id.solution_item_title);
            _subtitleView = (TextView) itemView.findViewById(R.id.solution_item_subtitle);
            _arrowRight = (ImageView) itemView.findViewById(R.id.solution_arrow_right);
        }

        public void bind(final Solution solution, final OnListItemClickListener listener) {
            String detail = solution.getDetail();
            String type = solution.getType();
            _subtitleView.setVisibility(View.GONE);
            if (type.equals("place")) {
                String placeId = solution.getDetail();
                GoogleApiClient apiClient = ((DualFragmentActivity) _context).getGoogleApiClient();
                Places.GeoDataApi.getPlaceById(apiClient, placeId).setResultCallback(new ResultCallback<PlaceBuffer>() {
                    @Override
                    public void onResult(PlaceBuffer places) {
                        if (places.getStatus().isSuccess() && places.getCount() > 0) {
                            final Place myPlace = places.get(0);
                            String name = myPlace.getName().toString();
                            String address = myPlace.getAddress().toString();
                            _titleView.setText(name);
                            _subtitleView.setText(address);
                            _subtitleView.setVisibility(View.VISIBLE);
                            solution.setDetail(name);
                            solution.setAddress(address);
                        }
                        else {
                            _titleView.setText(solution.getDetail());
                        }
                        places.release();
                    }
                });
            }
            else {
                _titleView.setText(detail);
            }

            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onListItemClick(solution);
                }
            });
        }

        public void bindButton(final OnListItemClickListener listener) {
            _cardView = (CardView) itemView.findViewById(R.id.facebook_post_view);
            final Solution emptySolution = new Solution();
            emptySolution.setType(SolutionFragment.BUTTON_TYPE);
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onListItemClick(emptySolution);
                }
            });
        }
    }
}
