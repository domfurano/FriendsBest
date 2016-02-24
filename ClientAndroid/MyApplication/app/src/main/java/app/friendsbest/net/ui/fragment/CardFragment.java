package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.TextView;

import app.friendsbest.net.R;
import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.presenter.CardPresenter;
import app.friendsbest.net.presenter.MainPresenter;
import app.friendsbest.net.ui.view.CardView;

public class CardFragment extends Fragment implements
                                                        CardView,
                                                        View.OnClickListener,
                                                        View.OnTouchListener,
                                                        View.OnFocusChangeListener {

    private FrameLayout _contentFrame;
    private TextView _cardTagText;
    private TextView _friendText;
    private ImageButton _historyBtn;
    private ImageButton _searchBtn;
    private EditText _searchField;
    private CardPresenter _cardPresenter;
    private MainPresenter _mainPresenter;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        _cardPresenter = new CardPresenter(this, getActivity().getApplicationContext());
        _mainPresenter = new MainPresenter(this, getActivity().getApplicationContext());
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_main, container, false);
        _contentFrame = (FrameLayout) view.findViewById(R.id.content_frame);
        _searchField = (EditText) view.findViewById(R.id.query_field);
        _historyBtn = (ImageButton) view.findViewById(R.id.query_history_button);
        _searchBtn = (ImageButton) view.findViewById(R.id.submit_query_button);
        return view;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        _historyBtn.setOnClickListener(this);
        _searchBtn.setOnClickListener(this);
        _searchField.setOnTouchListener(this);
        _cardPresenter.getPrompts();
    }

    public void setCardTagText(String text) {
        _cardTagText.setText(text);
    }

    public void setFriendText(String text) {
        _friendText.setText(text);
    }

    @Override
    public void onClick(View v) {
        if (v == _searchBtn)
            _mainPresenter.onQueryClicked(_searchField.getText().toString().trim());
        else if (v == _historyBtn)
            _mainPresenter.onHistoryClicked();
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
            methodManager.hideSoftInputFromWindow(_searchField.getWindowToken(), 0);
        }
    }
}
