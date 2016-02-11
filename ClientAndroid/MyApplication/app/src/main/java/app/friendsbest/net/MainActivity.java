package app.friendsbest.net;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Type;
import java.util.Arrays;
import java.util.Queue;

import app.friendsbest.net.model.Prompt;
import app.friendsbest.net.model.Response;
import app.friendsbest.net.model.UserProfile;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    //    private static final String API_BASE_URL = "https://www.friendsbest.net/fb/api/";
//    private static final String QUERY_URL = "https://www.friendsbest.net/fb/api/query/";
    public static final String QUERY_SUCCESS = "Submitted query.";
    public static final String QUERY_FAIL = "Error, could not submit query.";
    public final String dummyPrompt = "[{'article': 'a','tags': ['restaurant', 'mexican'],'friend': 'Ray Phillips','id': 10,'tagstring': 'mexican restaurant' }, { 'article': 'a', 'tags': [ 'birds' ], 'friend': 'Ray Phillips', 'id': 9, 'tagstring': 'birds' } ]";
    private final String PROMPT_QUERY_BY = "Based on a search by ";
    private static ConnectivityManager _connectionManager;

    private CoordinatorLayout _layout;
    private RelativeLayout _promptCardLayout;
    private Queue<Prompt> _prompts;
    private int _messageIdStatus;
    private String _token;
    private String _fullName;
    private EditText _searchField;
    private ImageButton _profileBtn;
    private ImageButton _settingsBtn;
    private ImageButton _recommendationBtn;
    private ImageButton _historyBtn;
    private ImageButton _searchBtn;
    private TextView _prompthTags;
    private TextView _promptAuthor;
    private TextView _promptTitle;
    private float _x1,_x2;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        _connectionManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        SharedPreferences savedData = PreferenceManager.getDefaultSharedPreferences(this);
        _token = savedData.getString(UserProfile.ProfileKey.ACCESS_TOKEN.getKey(), null);
        _fullName = savedData.getString(UserProfile.ProfileKey.FULL_NAME.getKey(), null);

        inflateViews();
        _prompts = showPrompts();
        cyclePromptCards(false);

        // Set focus listener for search field
        _searchField.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (!hasFocus) {
                    InputMethodManager methodManager = (InputMethodManager) getApplicationContext()
                            .getSystemService(Context.INPUT_METHOD_SERVICE);
                    methodManager.hideSoftInputFromWindow(_searchField.getWindowToken(), 0);
                }
            }
        });

        // Set listeners for buttons
        _historyBtn.setOnClickListener(this);
        _searchBtn.setOnClickListener(this);
        _profileBtn.setOnClickListener(this);
        _settingsBtn.setOnClickListener(this);
        _recommendationBtn.setOnClickListener(this);

        _promptCardLayout.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (_prompts != null) {
                    switch (event.getAction()) {
                        case MotionEvent.ACTION_DOWN:
                            _x1 = event.getX();
                            break;
                        case MotionEvent.ACTION_UP:
                            _x2 = event.getX();
                            float deltaX = _x2 - _x1;
                            // Swipe right
                            if (deltaX > 50) {
                                Prompt prompt = cyclePromptCards(true);
                                if (prompt != null) {
                                    Intent intent = new Intent(MainActivity.this, RecommendActivity.class);
                                    intent.putExtra(UserProfile.ProfileKey.ACCESS_TOKEN.getKey(), _token);
                                    intent.putExtra(Prompt.Key.PROMPT_STRING.getKey(), prompt.getTagString());
                                    intent.putExtra("distance", deltaX);
                                    startActivity(intent);
                                }
                            }
                            // Swipe left
                            else if (deltaX < -50) {
                                cyclePromptCards(true);
                            }
                            break;
                    }
                    return true;
                }
                return false;
            }
        });
    }

    private Queue<Prompt> showPrompts() {
        Gson gson = new Gson();
        Type promptType = new TypeToken<Queue<Prompt>>(){}.getType();
        return gson.fromJson(dummyPrompt, promptType);
    }

    /**
     * Moves through prompt cards, removing them from stack if remove is true
     */
    private Prompt cyclePromptCards(boolean remove){
        if (_prompts != null && !_prompts.isEmpty()){
            Prompt prompt;
            if (!remove)
                prompt = _prompts.peek();
            else
                prompt = _prompts.poll();
            _promptAuthor.setText(PROMPT_QUERY_BY + prompt.getFriend());
            _prompthTags.setText(prompt.getTagString());
            return prompt;
        }
        else {
            _promptAuthor.setText("");
            _prompthTags.setText("No prompts");
            _promptTitle.setText("");
            return null;
        }
    }

    @Override
    public void onClick(View v) {
        Intent intent;
        String key = UserProfile.ProfileKey.ACCESS_TOKEN.getKey();

        if (v == _searchBtn) {
            String searchText = _searchField.getText().toString().trim();
            if (searchText.length() > 0){
                String[] tags = searchText.split(" ");
                new QueryPost().execute(tags);
            }
        }
        else if (v == _recommendationBtn){
            intent = new Intent(MainActivity.this, RecommendActivity.class);
            intent.putExtra(key, _token);
            startActivityForConnectedDevice(intent);
        }
        else if (v == _historyBtn) {
            intent = new Intent(MainActivity.this, HistoryActivity.class);
            intent.putExtra(key, _token);
            startActivityForConnectedDevice(intent);
        }
        else if (v == _profileBtn){
            intent = new Intent(MainActivity.this, ProfileActivity.class);
            intent.putExtra(key, _token);
            intent.putExtra(UserProfile.ProfileKey.FULL_NAME.getKey(), _fullName);
            startActivityForConnectedDevice(intent);
        }
        else {
            intent = new Intent(MainActivity.this, SettingsActivity.class);
            startActivity(intent);
        }
    }

    private void inflateViews(){
        // Get buttons related to query history and search
        _historyBtn = (ImageButton) findViewById(R.id.historyButton);
        _searchBtn = (ImageButton) findViewById(R.id.submit_query_button);
        _searchField = (EditText) findViewById(R.id.query_field);

        // Get buttons for settings, profile, add recommendation
        _profileBtn = (ImageButton) findViewById(R.id.profile_button);
        _settingsBtn = (ImageButton) findViewById(R.id.settings_button);
        _recommendationBtn = (ImageButton) findViewById(R.id.recommendation_button);

        // Get text for prompt card
        _prompthTags = (TextView) findViewById(R.id.prompt_card_tag);
        _promptAuthor = (TextView) findViewById(R.id.prompt_card_asker);
        _promptTitle = (TextView) findViewById(R.id.prompt_card_title);

        _promptCardLayout = (RelativeLayout) findViewById(R.id.prompt_layout);
        _layout = (CoordinatorLayout) findViewById(R.id.home_coordinator_layout);
    }

    /**
     * Check if the device is connected to the internet and start activity.
     * Display error message otherwise.
     */
    private void startActivityForConnectedDevice(Intent intent){
        if (hasInternetConnection()) {
            startActivity(intent);
        }
        else {
            _messageIdStatus = R.string.no_internet;
            Snackbar snackbar = Snackbar.make(_layout, _messageIdStatus, Snackbar.LENGTH_LONG);
            snackbar.show();
        }
    }

    private boolean hasInternetConnection() {
        NetworkInfo networkInfo = _connectionManager.getActiveNetworkInfo();
        return networkInfo != null && networkInfo.isConnected();
    }

    class QueryPost extends AsyncTask<String[], String[], Boolean> {

        @Override
        protected void onPostExecute(Boolean result) {
            String message = result ? QUERY_SUCCESS : QUERY_FAIL;
            // Displays result of submission
            Snackbar snackbar = Snackbar.make(_layout, message, Snackbar.LENGTH_LONG);
            snackbar.show();
        }

        @Override
        protected Boolean doInBackground(String[]... params) {
            try {
                JSONObject serializedQuery = new JSONObject();
                JSONArray tagArray = new JSONArray(Arrays.asList(params[0]));
                serializedQuery.put("user", 2);
                serializedQuery.put("tags", tagArray);
                Response response = APIUtility.postRequest("query/", serializedQuery.toString(), _token);
                return response.wasPosted();
            }
            catch (JSONException e){
                Log.e("Error", e.getMessage(), e);
                return false;
            }
        }
    }
}
