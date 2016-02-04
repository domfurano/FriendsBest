package app.friendsbest.net;

import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.ProgressBar;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.Collection;
import java.util.List;

public class HistoryActivity extends AppCompatActivity {

    private ListView _listView;
    private ArrayAdapter<Query> _adapter;
    private ProgressBar _progressBar;
    private String _token;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_history);

        Toolbar toolbar = (Toolbar) findViewById(R.id.history_toolbar);
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);

        _progressBar = (ProgressBar) findViewById(R.id.history_progress_bar);
        _listView = (ListView) findViewById(R.id.history_items);
        _adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_2, android.R.id.text1);
        new QueryHistoryFetch().execute();

        Intent intent = getIntent();
        _token = intent.getStringExtra("access-token");

        _listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Query query = _adapter.getItem(position);
                int queryId = query.getId();

                Intent intent = new Intent(HistoryActivity.this, SolutionActivity.class);
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
            Gson gson = new Gson();
            Type collectionType = new TypeToken<Collection<Query>>(){}.getType();
            return gson.fromJson(data, collectionType);
        }

        @Override
        protected void onPostExecute(List<Query> queryHistory) {
            _progressBar.setVisibility(View.GONE);
            _adapter.addAll(queryHistory);
            _listView.setAdapter(_adapter);
        }
    }
}
