package app.friendsbest.net.ui;

import android.content.Context;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
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
import app.friendsbest.net.presenter.CardPresenter;
import app.friendsbest.net.ui.swipecards.FlingCardListener;
import app.friendsbest.net.ui.swipecards.SwipeFlingAdapterView;

public class MainActivity extends FragmentActivity implements
        View.OnClickListener,
        View.OnFocusChangeListener,
        View.OnTouchListener,
        FlingCardListener.ActionDownInterface {

    public static String CLASS_TAG = "classname";
    public static String CONTENT_TAG = "content";
    public static int RESULT_PASS = 0;
    public static int RESULT_FAIL = -1;
    public static final int REQUEST_CODE = 5115;
    public static ViewContainer _viewContainer;
    public static CardAdapter _cardAdapter;

    private SwipeFlingAdapterView _adapterView;
    private CardPresenter _cardPresenter;
    private TextView _historyBtn;
    private ImageButton _searchBtn;
    private EditText _searchField;
    private TextView _homeBtn;
    private TextView _profileBtn;
    private TextView _addRecommendBtn;
    private List<PromptCard> _cards;


    public static void removeBackground() {
        _viewContainer.background.setVisibility(View.GONE);
        _cardAdapter.notifyDataSetChanged();
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.content_main);
        Typeface typeface = FontManager
                .getTypeface(getApplicationContext(), FontManager.FONT_AWESOME);
        FontManager.markAsIconContainer(findViewById(R.id.navigation_container), typeface);
        FontManager.markAsIconContainer(findViewById(R.id.query_layout), typeface);
        _adapterView = (SwipeFlingAdapterView) findViewById(R.id.swipe_card);
        _cardPresenter = new CardPresenter(this, getApplicationContext());

        _historyBtn = (TextView) findViewById(R.id.query_results_button);
        _searchField = (EditText) findViewById(R.id.query_field);
        _searchBtn = (ImageButton) findViewById(R.id.submit_query_button);

        _addRecommendBtn = (TextView) findViewById(R.id.nav_recommend_button);
        _homeBtn = (TextView) findViewById(R.id.nav_home_button);
        _profileBtn = (TextView) findViewById(R.id.nav_profile_button);
    }

    @Override
    public void onStart() {
        super.onStart();
        _historyBtn.setOnClickListener(this);
        _searchBtn.setOnClickListener(this);
        _searchField.setOnFocusChangeListener(this);
        _addRecommendBtn.setOnClickListener(this);
        _profileBtn.setOnClickListener(this);
        _cardPresenter.getPrompts();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (_cards == null)
            _cards = new ArrayList<>();
        displayCards(_cards);
    }

    public void displayCards(List<PromptCard> cards) {
        _cards = cards;

        _cardAdapter = new CardAdapter(_cards, MainActivity.this);
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
                Intent intent = new Intent(MainActivity.this, DualFragmentActivity.class);
                intent.putExtra(CLASS_TAG, DualFragmentActivity.ADD_RECOMMENDATION_ID);
                startActivityForResult(intent, REQUEST_CODE);
            }

            @Override
            public void onAdapterAboutToEmpty(int itemsInAdapter) {

            }

            @Override
            public void onScroll(float scrollProgressPercent) {
            }
        });
    }

    @Override
    public void onClick(View v) {
        if (v != _homeBtn) {
            // Ensures data is valid before sending it with intent
            boolean okayToSend = true;
            Intent intent = new Intent(this, DualFragmentActivity.class);
            if (v == _historyBtn) {
                intent.putExtra(CLASS_TAG, DualFragmentActivity.SEARCH_HISTORY_ID);
            } else if (v == _addRecommendBtn) {
                intent.putExtra(CLASS_TAG, DualFragmentActivity.ADD_RECOMMENDATION_ID);
            } else if (v == _profileBtn) {
                intent.putExtra(CLASS_TAG, DualFragmentActivity.PROFILE_ID);
            } else if (v == _searchBtn) {
                String searchText = _searchField.getText().toString();
                if (_cardPresenter.isValidQuery(searchText)){
                    intent.putExtra(CLASS_TAG, DualFragmentActivity.SEARCH_HISTORY_ID);
                    intent.putExtra(CONTENT_TAG, searchText);
                }
                else {
                    okayToSend = false;
                }
            }

            if (okayToSend)
                startActivity(intent);
        }
    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
            InputMethodManager methodManager = (InputMethodManager)
                    getApplicationContext().
                    getSystemService(Context.INPUT_METHOD_SERVICE);
            methodManager.hideSoftInputFromWindow(_searchField.getWindowToken(), 0);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE) {
            if (resultCode == RESULT_PASS) {
                deleteCard();
            }
        }
    }

    @Override
    public void onActionDownPerform() {

    }

    private void deleteCard() {
        PromptCard deletedCard =_cards.remove(0);
        _cardAdapter.notifyDataSetChanged();
        _cardPresenter.deletePromptCard(deletedCard.getId());
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        return false;
    }

    public static class ViewContainer {
        public static FrameLayout background;
        public TextView friendText;
        public TextView tagStringText;
    }

    public class CardAdapter extends BaseAdapter {

        public List<PromptCard> _promptCards;
        public Context _context;

        private CardAdapter(List<PromptCard> apps, Context context) {
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
                LayoutInflater inflater = getLayoutInflater();
                rowView = inflater.inflate(R.layout.item, parent, false);

                _viewContainer = new ViewContainer();
                _viewContainer.tagStringText = (TextView) rowView.findViewById(R.id.bookText);
                _viewContainer.friendText = (TextView) rowView.findViewById(R.id.bookText1);
                _viewContainer.background = (FrameLayout) rowView.findViewById(R.id.background);
                rowView.setTag(_viewContainer);
            }
            else {
                _viewContainer = (ViewContainer) convertView.getTag();
            }

            String basedOnSearch = "Based on a search by ";
            _viewContainer.friendText.setText(basedOnSearch + _promptCards.get(position).getFriend().getName());
            _viewContainer.tagStringText.setText(_promptCards.get(position).getTagstring());
            return rowView;
        }
    }
}
