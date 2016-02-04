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

import java.util.ArrayList;
import java.util.List;

public class SolutionActivity  extends AppCompatActivity{

    private ListView _listView;
    private ArrayAdapter<Solution> _adapter;
    private ProgressBar _progressBar;
    private String _token;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_solution);

        Toolbar toolbar = (Toolbar) findViewById(R.id.solution_toolbar);
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);

        _progressBar = (ProgressBar) findViewById(R.id.solution_progress_bar);
        _listView = (ListView) findViewById(R.id.solution_items);

        Intent intent = getIntent();

        _token = intent.getStringExtra("access-token");
        int queryId = intent.getIntExtra("QUERY_ID", -1);
        String title = intent.getStringExtra("QUERY_TITLE");
        setTitle(title);

        _adapter = new ArrayAdapter<>(
                this,
                android.R.layout.simple_list_item_1,
                android.R.id.text1);
        new SolutionFetch(queryId).execute();

        _listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Solution solution = _adapter.getItem(position);
                String serializedData = new Gson().toJson(solution, Solution.class);
                Intent recommendationsIntent = new Intent(SolutionActivity.this, UserRecommendationActivity.class);
                recommendationsIntent.putExtra("SOLUTION_DATA", serializedData);
                startActivity(recommendationsIntent);
            }
        });
    }

    class SolutionFetch extends AsyncTask<Void, Void, List<Solution>> {
        private int _queryId;

        public SolutionFetch(int id){
            this._queryId = id;
        }

        @Override
        protected void onPreExecute() {
            _progressBar.setVisibility(View.VISIBLE);
        }

        @Override
        protected List<Solution> doInBackground(Void... params) {
            String data = APIUtility.getResponse("query/" + _queryId, _token);
            Gson gson = new Gson();
            QuerySolution querySolution = gson.fromJson(data, QuerySolution.class);

            // Check for data
            if (querySolution != null)
                return querySolution.getSolutions();

            return new ArrayList<>();
        }

        @Override
        protected void onPostExecute(List<Solution> solutions) {
            _progressBar.setVisibility(View.GONE);
            _adapter.addAll(solutions);
            _listView.setAdapter(_adapter);
        }
    }
}
