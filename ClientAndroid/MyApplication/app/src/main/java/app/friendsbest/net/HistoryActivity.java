package app.friendsbest.net;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;

import java.util.List;

import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.presenter.QueryHistoryPresenter;
import app.friendsbest.net.ui.view.SearchHistoryView;

public class HistoryActivity extends AppCompatActivity implements SearchHistoryView {

    private LinearLayout _layout;
    private ListView _listView;
    private ArrayAdapter<Query> _adapter;
    private ProgressBar _progressBar;

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
        _listView = (ListView) findViewById(android.R.id.list);
        _adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_2, android.R.id.text1);
        setListener();
        new QueryHistoryPresenter(this, getApplicationContext());
    }

    private void setListener(){
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

    @Override
    public void displaySearchHistory(List<Query> queries) {
        _adapter.addAll(queries);
        _listView.setAdapter(_adapter);
    }

    @Override
    public void showProgress() {
        _progressBar.setVisibility(View.VISIBLE);
    }

    @Override
    public void hideProgress() {
        _progressBar.setVisibility(View.GONE);
    }
}
