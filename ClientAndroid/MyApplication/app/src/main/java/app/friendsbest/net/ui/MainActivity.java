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
import app.friendsbest.net.swipecards.Data;
import app.friendsbest.net.swipecards.FlingCardListener;
import app.friendsbest.net.swipecards.SwipeFlingAdapterView;

public class MainActivity extends FragmentActivity implements
        View.OnClickListener,
        View.OnTouchListener,
        View.OnFocusChangeListener,
        FlingCardListener.ActionDownInterface {

    public static String TAG = "classname";
    public static ViewContainer _viewContainer;
    public static CardAdapter _cardAdapter;

    private SwipeFlingAdapterView _adapterView;
    private CardPresenter _cardPresenter;
    private ImageButton _historyBtn;
    private ImageButton _searchBtn;
    private EditText _searchField;
    private TextView _homeBtn;
    private TextView _profileBtn;
    private TextView _addRecommendBtn;
    private ArrayList<Data> _cards;


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
        _adapterView = (SwipeFlingAdapterView) findViewById(R.id.swipe_card);
        _cardPresenter = new CardPresenter(this, getApplicationContext());

        _historyBtn = (ImageButton) findViewById(R.id.query_results_button);
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
        _searchField.setOnTouchListener(this);
        _addRecommendBtn.setOnClickListener(this);
        _profileBtn.setOnClickListener(this);
        _cardPresenter.getPrompts();
        displayCards(null);
    }

    public void displayCards(PromptCard card) {
        _cards = new ArrayList<>();
        _cards.add(new Data("Mexican Restaurant", "John Doe"));
        _cards.add(new Data("Chinese Restaurant", "Jane Doe"));
        _cards.add(new Data("Greek Restaurant", "Bob Doe"));
        _cards.add(new Data("Indian Restaurant", "John Doe"));
        _cards.add(new Data("Italian Restaurant", "John Doe"));
        _cards.add(new Data("Mongolian Restaurant", "John Doe"));

        _cardAdapter = new CardAdapter(_cards, MainActivity.this);
        _adapterView.setAdapter(_cardAdapter);
        _adapterView.setFlingListener(new SwipeFlingAdapterView.onFlingListener() {
            @Override
            public void removeFirstObjectInAdapter() {

            }

            @Override
            public void onLeftCardExit(Object dataObject) {
                _cards.remove(0);
                _cardAdapter.notifyDataSetChanged();
            }

            @Override
            public void onRightCardExit(Object dataObject) {
                _cards.remove(0);
                _cardAdapter.notifyDataSetChanged();
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
        Intent intent = new Intent(this, DualActivity.class);
        if (v == _historyBtn) {
            intent.putExtra(TAG, DualActivity.SEARCH_HISTORY_ID);
        }
        else if (v == _addRecommendBtn){
            intent.putExtra(TAG, DualActivity.ADD_RECOMMENDATION_ID);
        }
        startActivity(intent);
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        return false;
    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
            InputMethodManager methodManager = (InputMethodManager)
                    getApplicationContext().
                    getSystemService(Context.INPUT_METHOD_SERVICE);
//            methodManager.hideSoftInputFromWindow(_searchField.getWindowToken(), 0);
        }
    }

    @Override
    public void onActionDownPerform() {

    }

    public static class ViewContainer {
        public static FrameLayout background;
        public TextView friendText;
        public TextView tagStringText;
    }

    public class CardAdapter extends BaseAdapter {

        public List<Data> parkingList;
        public Context context;

        private CardAdapter(List<Data> apps, Context context) {
            this.parkingList = apps;
            this.context = context;
        }

        @Override
        public int getCount() {
            return parkingList.size();
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

            _viewContainer.friendText.setText(parkingList.get(position).getFriend() + "");
            _viewContainer.tagStringText.setText(parkingList.get(position).getTagString());
            return rowView;
        }
    }
}
