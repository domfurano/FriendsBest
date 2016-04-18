package app.friendsbest.net.ui.fragment;

import android.app.Fragment;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;

import app.friendsbest.net.R;
import app.friendsbest.net.ui.DualFragmentActivity;

public class WebFragment extends Fragment implements View.OnClickListener {

    public static final String BUNDLE_TAG = "webViewTag";
    private OnFragmentInteractionListener _listener;
    private TextView _closeButton;
    private TextView _actionButton;
    private ImageButton _backButton;
    private ImageButton _forwardButton;
    private Bundle _bundle;
    private EditText _urlBar;
    private WebView _webView;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_web_view, container, false);
        initialize(view, getArguments());
        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        _listener = (OnFragmentInteractionListener) getActivity();
        _listener.hideSupportActionBar();
        _listener.hideBottomNavigationBar();
        _webView.getSettings().setJavaScriptEnabled(true);
        _webView.loadUrl("http://www.google.com");
    }

    @Override
    public void onClick(View v) {
        if (v == _closeButton) {
            if (_urlBar.getText().length() > 0) {
                _urlBar.setText("");
            }
            else {
                if (_urlBar.hasFocus()) {
                    _urlBar.setFocusable(false);
                }
                _listener.onFragmentChange("");
            }
        }
        else if (v == _actionButton) {
            if (_bundle == null)
                _bundle = new Bundle();

            _bundle.putString(BUNDLE_TAG, _webView.getUrl());
            _listener.onFragmentChange(DualFragmentActivity.CREATE_RECOMMENDATION_ID, _bundle);
        }
        else if (v == _backButton) {
            if (_webView.canGoBack()) {
                _webView.goBack();
            }

        }
        else if (v == _forwardButton) {
            if (_webView.canGoBack()) {
                _webView.goForward();
            }
        }
    }

    private void initialize(View view, Bundle bundle) {
        if (bundle != null)
            _bundle = bundle;
        _urlBar = (EditText) view.findViewById(R.id.web_view_nav_url);
        _closeButton = (TextView) view.findViewById(R.id.web_view_nav_clear);
        _actionButton = (TextView) view.findViewById(R.id.web_view_nav_action);
        _webView = (WebView) view.findViewById(R.id.web_view);
        _webView.setWebViewClient(new WebViewClient());
        _backButton = (ImageButton) view.findViewById(R.id.web_view_back);
        _forwardButton = (ImageButton) view.findViewById(R.id.web_view_forward);

        _closeButton.setOnClickListener(this);
        _actionButton.setOnClickListener(this);
        _backButton.setOnClickListener(this);
        _forwardButton.setOnClickListener(this);

        _urlBar.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_GO) {
                    String rawUrl = _urlBar.getText().toString();
                    String url = cleanUrl(rawUrl);
                    if (url.length() > 0 && isValidUrl(url)) {
                        _webView.loadUrl(url);
                        InputMethodManager imm = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
                        imm.hideSoftInputFromWindow(_urlBar.getWindowToken(), 0);
                    }
                }
                return false;
            }
        });
    }

    private boolean isValidUrl(String url) {
        String regex = "(http://|https://)(www.)?([a-zA-Z0-9\\-]+\\.)+[a-z]{2,3}(\\/{1}[^\\/\\\\]+)*";
        return url.matches(regex);
    }

    private String cleanUrl(String url) {
        if (!url.contains("http://")) {
            String fixedUrl = "http://" + url;
            return fixedUrl;
        }
        else {
            return url;
        }
    }
}