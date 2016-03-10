package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.content.Context;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.services.FontManager;
import app.friendsbest.net.presenter.DemoPresenter;
import app.friendsbest.net.ui.DualFragmentActivity;
import app.friendsbest.net.ui.swipecards.FlingCardListener;
import app.friendsbest.net.ui.swipecards.SwipeFlingAdapterView;
import app.friendsbest.net.ui.view.FragmentView;

public class PromptFragment extends Fragment implements
        FragmentView<List<PromptCard>>,
        View.OnClickListener,
        View.OnFocusChangeListener,
        View.OnTouchListener,
        FlingCardListener.ActionDownInterface {

    public static IViewContainer _viewContainer;
    public static ICardAdapter _cardAdapter;

    private OnFragmentInteractionListener _listener;
    private DemoPresenter _presenter;
    private SwipeFlingAdapterView _adapterView;
    private TextView _historyBtn;
    private EditText _searchField;
    private ImageButton _searchBtn;
    private List<PromptCard> _cards = new ArrayList<>();


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_main, container, false);

        Typeface typeface = FontManager
                .getTypeface(getActivity().getApplicationContext(), FontManager.FONT_AWESOME);
        FontManager.markAsIconContainer(view.findViewById(R.id.fragment_main_query_layout), typeface);
        _adapterView = (SwipeFlingAdapterView) view.findViewById(R.id.fragment_main_swipe_card);

        _historyBtn = (TextView) view.findViewById(R.id.fragment_main_query_results_button);
        _searchField = (EditText) view.findViewById(R.id.fragment_main_query_field);
        _searchBtn = (ImageButton) view.findViewById(R.id.fragment_main_submit_query_button);
        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _historyBtn.setOnClickListener(this);
        _searchField.setOnClickListener(this);
        _searchBtn.setOnClickListener(this);
        _listener = (OnFragmentInteractionListener) getActivity();
        _presenter = new DemoPresenter(this, getActivity());
    }

    @Override
    public void onActionDownPerform() {

    }

    @Override
    public void onClick(View v) {

    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {

    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        return false;
    }

    @Override
    public void displayContent(List<PromptCard> cards) {
        if (cards.size() > 0) {
            _cards = cards;

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
                    _listener.onFragmentChange(DualFragmentActivity.ADD_RECOMMENDATION_ID);
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

    @Override
    public void showProgressBar() {
    }

    @Override
    public void hideProgressBar() {
    }

    @Override
    public void displayMessage(String message) {
    }

    private void deleteCard() {
        PromptCard deletedCard =_cards.remove(0);
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
            }
            else {
                _viewContainer = (IViewContainer) convertView.getTag();
            }

            String basedOnSearch = "Based on a search by ";
            _viewContainer.friendText.setText(basedOnSearch + _promptCards.get(position).getFriend().getName());
            _viewContainer.tagStringText.setText(_promptCards.get(position).getTagstring());
            return rowView;
        }
    }
}
