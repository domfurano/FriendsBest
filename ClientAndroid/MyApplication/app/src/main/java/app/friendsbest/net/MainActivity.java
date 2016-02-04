package app.friendsbest.net;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageButton;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    //    private static final String API_BASE_URL = "https://www.friendsbest.net/fb/api/";
//    private static final String QUERY_URL = "https://www.friendsbest.net/fb/api/query/";
    public static final String QUERY_SUCCESS = "Submitted query.";
    public static final String QUERY_FAIL = "Error, could not submit query.";
    public static final String TOKEN_KEY = "access_token";

    private static ConnectivityManager _connectionManager;

    private CoordinatorLayout _layout;
    private int _messageIdStatus;
    private String _token;
    private EditText _searchField;
    private ImageButton _profileBtn;
    private ImageButton _settingsBtn;
    private ImageButton _recommendationBtn;
    private ImageButton _historyBtn;
    private ImageButton _searchBtn;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        _connectionManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        Intent intent = getIntent();
        _token = intent.getStringExtra(TOKEN_KEY);

        // Get buttons related to query history and search
        _historyBtn = (ImageButton) findViewById(R.id.historyButton);
        _searchBtn = (ImageButton) findViewById(R.id.submit_query_button);
        _searchField = (EditText) findViewById(R.id.query_field);

        // Get buttons for settings, profile, add recommendation
        _profileBtn = (ImageButton) findViewById(R.id.profile_button);
        _settingsBtn = (ImageButton) findViewById(R.id.settings_button);
        _recommendationBtn = (ImageButton) findViewById(R.id.recommendation_button);

        _layout = (CoordinatorLayout) findViewById(R.id.home_coordinator_layout);

        // Set listeners for all buttons
        _historyBtn.setOnClickListener(this);
        _searchBtn.setOnClickListener(this);
        _profileBtn.setOnClickListener(this);
        _settingsBtn.setOnClickListener(this);
        _recommendationBtn.setOnClickListener(this);

    }


    @Override
    public void onClick(View v) {
        Intent intent;

        if (v == _searchBtn) {
            String searchText = _searchField.getText().toString().trim();
            if (searchText.length() > 0){
                String[] tags = searchText.split(" ");
                new QueryPost().execute(tags);
            }
        }
        else if (v == _recommendationBtn){
            intent = new Intent(MainActivity.this, RecommendActivity.class);
            intent.putExtra(TOKEN_KEY, _token);
            startActivityForConnectedDevice(intent);
        }
        else if (v == _historyBtn) {
            intent = new Intent(MainActivity.this, HistoryActivity.class);
            intent.putExtra(TOKEN_KEY, _token);
            startActivityForConnectedDevice(intent);
        }
        else if (v == _profileBtn){
            intent = new Intent(MainActivity.this, ProfileActivity.class);
            intent.putExtra(TOKEN_KEY, _token);
            startActivityForConnectedDevice(intent);
        }
        else {
            intent = new Intent(MainActivity.this, SettingsActivity.class);
            startActivity(intent);
        }
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
                Response response = APIUtility.postRequest("query/", serializedQuery.toString());
                return response.wasPosted();
            }
            catch (JSONException e){
                Log.e("Error", e.getMessage(), e);
                return false;
            }
        }
    }
}
