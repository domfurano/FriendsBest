package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.presenter.PromptPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.swipecards.FlingCardListener;
import app.friendsbest.net.ui.swipecards.SwipeFlingAdapterView;
import app.friendsbest.net.ui.view.FragmentView;

public class PromptFragment extends Fragment implements
        FragmentView<List<PromptCard>>,
        View.OnClickListener,
        View.OnFocusChangeListener,
        FlingCardListener.ActionDownInterface {

    public static final String BUNDLE_TAG = "promptFragmentTag";
    private long INTERVAL = 6500l;
    public static IViewContainer _viewContainer;
    public static ICardAdapter _cardAdapter;

    private OnFragmentInteractionListener _listener;
    private PromptPresenter _presenter;
    private SwipeFlingAdapterView _adapterView;
    private ImageView _historyBtn;
    private TextView _updateView;
    private EditText _searchField;
    private ImageButton _searchBtn;
    private List<PromptCard> _cards = new ArrayList<>();
    boolean _deleteRecommendation = false;
    private Handler _handler;
    private Runnable _runnable;

    public static void removeBackground() {
        _viewContainer.background.setVisibility(View.GONE);
        _cardAdapter.notifyDataSetChanged();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_main, container, false);
        initialize(getArguments());
        setHasOptionsMenu(true);
        _adapterView = (SwipeFlingAdapterView) view.findViewById(R.id.fragment_main_swipe_card);
        _historyBtn = (ImageView) view.findViewById(R.id.fragment_main_query_results_button);
        _updateView = (TextView) view.findViewById(R.id.fragment_main_query_results_update);
        _searchField = (EditText) view.findViewById(R.id.fragment_main_query_field);
        _searchBtn = (ImageButton) view.findViewById(R.id.fragment_main_submit_query_button);

        _updateView.setVisibility(View.INVISIBLE);
        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _historyBtn.setOnClickListener(this);
        _searchField.setOnClickListener(this);
        _searchField.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_DONE) {
                    _searchBtn.performClick();
                }
                return false;
            }
        });
        _searchBtn.setOnClickListener(this);
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.hideSupportActionBar();
        _listener.showBottomNavigationBar();
        _listener.onFragmentStatusBarChange(R.color.colorPrimaryDark);
        _presenter = new PromptPresenter(this, getActivity());

        _runnable = new Runnable() {
            @Override
            public void run() {
                fetchBackgroundData();
            }
        };
        _handler = new Handler();
        fetchBackgroundData();
    }

    @Override
    public void onStop() {
        super.onStop();
        _handler.removeCallbacks(_runnable);
    }

    @Override
    public void onActionDownPerform() {

    }

    @Override
    public void onClick(View v) {
        if (v == _searchBtn) {
            String searchText = _searchField.getText().toString();
            _presenter.submitQuery(searchText);
        } else if (v == _historyBtn) {
            _listener.onFragmentChange(DualFragmentActivity.SEARCH_HISTORY_ID);
        }
    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {

    }

    @Override
    public void displayContent(List<PromptCard> cards) {
        if (cards.size() > 0) {
            _cards = cards;
            if (_deleteRecommendation)
                deleteCard();

            if (_cards.size() == 1)
                _presenter.getData();

            _cardAdapter = new ICardAdapter(_cards, getActivity());
            _adapterView.setAdapter(_cardAdapter);
            _cardAdapter.notifyDataSetChanged();
            _adapterView.setFlingListener(new SwipeFlingAdapterView.onFlingListener() {
                @Override
                public void removeFirstObjectInAdapter() {

                }

                @Override
                public void onLeftCardExit(Object dataObject) {
                    deleteCard();
                }

                @Override
                public void onRightCardExit(Object dataObject) {
                    PromptCard card = _cards.get(0);
                    Bundle bundle = new Bundle();
                    bundle.putString(BUNDLE_TAG, card.getTagstring());
                    _listener.onFragmentChange(DualFragmentActivity.ADD_RECOMMENDATION_ID, bundle);
                }

                @Override
                public void onAdapterAboutToEmpty(int itemsInAdapter) {

                }

                @Override
                public void onScroll(float scrollProgressPercent) {
                }
            });
        }
    }

    public void hasNewRecommendations(boolean hasUpdate) {
        int visibility = View.INVISIBLE;
        if (hasUpdate) {
            visibility = View.VISIBLE;
            INTERVAL += 10000;
        }
        _updateView.setVisibility(visibility);
    }

    private void initialize(Bundle arguments) {
        if (arguments != null) {
            _deleteRecommendation = arguments.getBoolean(PostRecommendationFragment.BUNDLE_KEY);
        }
    }

    private void fetchBackgroundData() {
        _presenter.getData();
        _presenter.getQueryUpdates();
        Log.i("Poo in the loo", "Called runnable");
        _handler.postDelayed(_runnable, INTERVAL);
    }

    @Override
    public void showProgressBar() {
    }

    @Override
    public void hideProgressBar() {
    }

    @Override
    public void displayMessage(String message) {
    }

    public void changeFragment(String fragmentTag, Bundle payload) {
        _searchField.setText("");
        _listener.onFragmentChange(fragmentTag, payload);
    }

    private void deleteCard() {
        PromptCard deletedCard = _cards.remove(0);
        _cardAdapter.notifyDataSetChanged();
        _presenter.deletePromptCard(deletedCard.getId());
    }

    public static class IViewContainer {
        public static FrameLayout background;
        public TextView friendText;
        public TextView tagStringText;
    }

    public class ICardAdapter extends BaseAdapter {

        public List<PromptCard> _promptCards;
        public Context _context;

        private ICardAdapter(List<PromptCard> apps, Context context) {
            _promptCards = apps;
            _context = context;
        }

        @Override
        public int getCount() {
            return _promptCards.size();
        }

        @Override
        public Object getItem(int position) {
            return position;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            View rowView = convertView;

            if (rowView == null) {
                LayoutInflater inflater = getActivity().getLayoutInflater();
                rowView = inflater.inflate(R.layout.item, parent, false);

                _viewContainer = new IViewContainer();
                _viewContainer.tagStringText = (TextView) rowView.findViewById(R.id.bookText);
                _viewContainer.friendText = (TextView) rowView.findViewById(R.id.bookText1);
                _viewContainer.background = (FrameLayout) rowView.findViewById(R.id.background);
                rowView.setTag(_viewContainer);
            } else {
                _viewContainer = (IViewContainer) convertView.getTag();
            }

            String searchBy = "Based on a search by ";
            _viewContainer.friendText.setText(searchBy + _promptCards.get(position).getFriend().getName());
            _viewContainer.tagStringText.setText(_promptCards.get(position).getTagstring());
            return rowView;
        }
    }
}
