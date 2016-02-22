package app.friendsbest.net;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.widget.ListView;

import com.google.gson.Gson;

import java.util.ArrayList;

import app.friendsbest.net.data.model.Solution;
import app.friendsbest.net.data.model.UserRecommendation;

public class UserRecommendationActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_rec);

        Toolbar toolbar = (Toolbar) findViewById(R.id.user_rec_toolbar);
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);

        Intent intent = getIntent();
        String serializedData = intent.getStringExtra("SOLUTION_DATA");
        Solution solution = new Gson().fromJson(serializedData, Solution.class);
        ArrayList<UserRecommendation> recommendations = solution.getRecommendations();

        setTitle(solution.getName());

        UserRecommendationAdapter adapter = new UserRecommendationAdapter(this, R.layout.user_rec_item, recommendations);
        ListView listView = (ListView) findViewById(R.id.user_rec_list);
        listView.setAdapter(adapter);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                onBackPressed();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }
}
