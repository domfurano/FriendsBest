package app.friendsbest.net;

import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.Collection;
import java.util.List;

import app.friendsbest.net.model.Query;
import app.friendsbest.net.model.UserProfile;

public class HistoryActivity extends AppCompatActivity {

    private final String HISTORY_KEY = "query_history";
    private LinearLayout _layout;
    private ListView _listView;
    private ArrayAdapter<Query> _adapter;
    private ProgressBar _progressBar;
    private String _serializedQueryHistory;
    private String _token;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_history);

        Toolbar toolbar = (Toolbar) findViewById(R.id.history_toolbar);
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);

        _layout = (LinearLayout) findViewById(R.id.history_layout);
        _progressBar = (ProgressBar) findViewById(R.id.history_progress_bar);
        _listView = (ListView) findViewById(R.id.history_items);
        _adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_2, android.R.id.text1);

        Intent intent = getIntent();
        _token = intent.getStringExtra(UserProfile.ProfileKey.ACCESS_TOKEN.getKey());

        // Load saved query history data if it exists
        String serializedQuery;
        if (savedInstanceState != null && (
                serializedQuery = savedInstanceState.getString(HISTORY_KEY)) != null){

            serializedQuery = savedInstanceState.getString(HISTORY_KEY);
            Type queryType = new TypeToken<Collection<Query>>(){}.getType();
            List<Query> queryHistory = new Gson().fromJson(serializedQuery, queryType);
            _adapter.addAll(queryHistory);
            _listView.setAdapter(_adapter);
        }
        else {
            new QueryHistoryFetch().execute();
        }

        setListener();
    }

    @Override
    public void onSaveInstanceState(Bundle savedInstance){
        savedInstance.putString(HISTORY_KEY, _serializedQueryHistory);
        super.onSaveInstanceState(savedInstance);
    }

    private void setListener(){
        _listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Query query = _adapter.getItem(position);
                int queryId = query.getId();

                Intent intent = new Intent(HistoryActivity.this, SolutionActivity.class);
                intent.putExtra(UserProfile.ProfileKey.ACCESS_TOKEN.getKey(), _token);
                intent.putExtra("QUERY_ID", queryId);
                intent.putExtra("QUERY_TITLE", query.toString());
                startActivity(intent);
            }
        });
    }

    private class QueryHistoryFetch extends AsyncTask<Void, Void, List<Query>> {
        @Override
        protected void onPreExecute() {
            _progressBar.setVisibility(View.VISIBLE);
        }

        @Override
        protected List<Query> doInBackground(Void... params) {
            String data = APIUtility.getResponse("query/", _token);
            _serializedQueryHistory = data;
            Gson gson = new Gson();
            Type collectionType = new TypeToken<Collection<Query>>(){}.getType();
            return gson.fromJson(data, collectionType);
        }

        @Override
        protected void onPostExecute(List<Query> queryHistory) {
            _progressBar.setVisibility(View.GONE);
            if (queryHistory != null) {
                _adapter.addAll(queryHistory);
                _listView.setAdapter(_adapter);
            }
            else {
                TextView emptyListView = new TextView(HistoryActivity.this);
                emptyListView.setText(R.string.no_results);
                _layout.addView(emptyListView);

                // Clear data so it is not stored in Bundle
                _serializedQueryHistory = null;
            }
        }
    }
}
