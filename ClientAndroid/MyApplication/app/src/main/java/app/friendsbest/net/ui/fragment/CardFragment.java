package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.CardLayout;
import app.friendsbest.net.R;
import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.presenter.CardPresenter;
import app.friendsbest.net.presenter.MainPresenter;
import app.friendsbest.net.swipecards.Data;
import app.friendsbest.net.swipecards.FlingCardListener;
import app.friendsbest.net.swipecards.SwipeFlingAdapterView;
import app.friendsbest.net.ui.view.CardView;

public class CardFragment extends Fragment implements
                                                        CardView,
                                                        View.OnClickListener,
                                                        View.OnTouchListener,
                                                        View.OnFocusChangeListener,
        FlingCardListener.ActionDownInterface {

//    private RelativeLayout _cardContainer;
//    private ImageButton _historyBtn;
//    private ImageButton _searchBtn;
//    private EditText _searchField;
    private CardPresenter _cardPresenter;
    public static MyAppAdapter myAppAdapter;
    public static ViewHolder viewHolder;
    private ArrayList<Data> dataList;
    private SwipeFlingAdapterView flingContainer;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_main, container, false);
        flingContainer = (SwipeFlingAdapterView) view.findViewById(R.id.swipe_card);

//        _searchField = (EditText) view.findViewById(R.id.query_field);
//        _historyBtn = (ImageButton) view.findViewById(R.id.query_results_button);
//        _searchBtn = (ImageButton) view.findViewById(R.id.submit_query_button);
//        _cardContainer = (RelativeLayout) view.findViewById(R.id.prompt_layout);
        return view;
    }

    public static void removeBackground() {
        viewHolder.background.setVisibility(View.GONE);
        myAppAdapter.notifyDataSetChanged();
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        _cardPresenter = new CardPresenter(this, getActivity().getApplicationContext());
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        dataList = new ArrayList<>();
        dataList.add(new Data("http://i.ytimg.com/vi/PnxsTxV8y3g/maxresdefault.jpg", "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness."));
        dataList.add(new Data("http://switchboard.nrdc.org/blogs/dlashof/mission_impossible_4-1.jpg", "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness."));
        dataList.add(new Data("http://i.ytimg.com/vi/PnxsTxV8y3g/maxresdefault.jpg", "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness."));
        dataList.add(new Data("http://switchboard.nrdc.org/blogs/dlashof/mission_impossible_4-1.jpg", "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness."));
        dataList.add(new Data("http://i.ytimg.com/vi/PnxsTxV8y3g/maxresdefault.jpg", "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness."));

        myAppAdapter = new MyAppAdapter(dataList, getActivity().getApplicationContext());
        flingContainer.setAdapter(myAppAdapter);
        flingContainer.setFlingListener(new SwipeFlingAdapterView.onFlingListener() {
            @Override
            public void removeFirstObjectInAdapter() {

            }

            @Override
            public void onLeftCardExit(Object dataObject) {
                dataList.remove(0);
                myAppAdapter.notifyDataSetChanged();
            }

            @Override
            public void onRightCardExit(Object dataObject) {
                dataList.remove(0);
                myAppAdapter.notifyDataSetChanged();
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
    public void onStart() {
        super.onStart();
//        _historyBtn.setOnClickListener(this);
//        _searchBtn.setOnClickListener(this);
//        _searchField.setOnTouchListener(this);
        _cardPresenter.getPrompts();
    }

    public void setCardTagText(String text) {
    }

    public void setCardFriendText(String text) {
    }

    @Override
    public void onClick(View v) {
    }

    @Override
    public void displayCards(PromptCard cards) {
        boolean exist = cards != null;
        String result = "Cards are not null " + exist;
        Log.i("displayCards", result);
    }

    @Override
    public void onSwipeLeft(float distance) {

    }

    @Override
    public void onSwipeRight(float distance) {

    }

    @Override
    public void replaceView(String oldFragmentTag, String newFragmentTag, Bundle bundle, String key) {

    }

    @Override
    public void replaceView(String oldFragmentTag, String newFragmentTag) {

    }

    @Override
    public void startView(String fragmentId) {

    }

    @Override
    public void displayMessage(String message) {

    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        return false;
    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
            InputMethodManager methodManager = (InputMethodManager) getActivity().
                    getApplicationContext().
                    getSystemService(Context.INPUT_METHOD_SERVICE);
//            methodManager.hideSoftInputFromWindow(_searchField.getWindowToken(), 0);
        }
    }

    @Override
    public void onActionDownPerform() {

    }

    private static class CardAdapter {
    }

    public static class ViewHolder {
        public static FrameLayout background;
        public TextView dataText;
        public ImageView cardImage;
    }

    public class MyAppAdapter extends BaseAdapter {

        public List<Data> parkingList;
        public Context context;

        private MyAppAdapter(List<Data> apps, Context context) {
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
                LayoutInflater inflater = getActivity().getLayoutInflater();
                rowView = inflater.inflate(R.layout.item, parent, false);

                viewHolder = new ViewHolder();
                viewHolder.dataText = (TextView) rowView.findViewById(R.id.bookText);
                viewHolder.background = (FrameLayout) rowView.findViewById(R.id.background);
                viewHolder.cardImage = (ImageView) rowView.findViewById(R.id.cardImage);
                rowView.setTag(viewHolder);
            }
            else {
                viewHolder = (ViewHolder) convertView.getTag();
            }

            viewHolder.dataText.setText(parkingList.get(position).getDescription() + "");
            Glide.with(CardFragment.this).load(parkingList.get(position).getImagePath()).into(viewHolder.cardImage);
            return rowView;
        }
    }
}
