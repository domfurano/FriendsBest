package app.friendsbest.net;

import android.os.AsyncTask;
import android.os.Bundle;
import android.support.design.widget.CoordinatorLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import com.google.gson.Gson;

public class RecommendActivity extends AppCompatActivity {

    private Button _submitBtn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_rec);

        Toolbar toolBar = (Toolbar) findViewById(R.id.add_recommendation_toolbar);
        setSupportActionBar(toolBar);

        // Enable back button on action bar
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowHomeEnabled(true);

        final EditText titleInput = (EditText) findViewById(R.id.rec_title_input);
        final EditText tagsInput = (EditText) findViewById(R.id.rec_tags_input);
        final EditText commentsInput = (EditText) findViewById(R.id.rec_comments_input);

        _submitBtn = (Button) findViewById(R.id.add_recommendation_button);

        _submitBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String title = titleInput.getText().toString();
                String tagsText = tagsInput.getText().toString();
                String[] tags = tagsText.split(",");
                String comments = commentsInput.getText().toString();
                new HttpPost(title, tags, comments).execute();
                RecommendActivity.this.finish();
            }
        });

    }

    private class HttpPost extends AsyncTask<Void, Void, Boolean> {

        private String _description;
        private String[] _tags;
        private String _comments;

        public HttpPost(String description, String[] tags, String comments) {
            this._description = description;
            this._tags = tags;
            this._comments = comments;
        }

        @Override
        protected Boolean doInBackground(Void... params) {
            Thing thing = new Thing();
            thing.setDescription(_description);
            thing.setUser(2);
            thing.setComments(_comments);
            thing.setTags(_tags);
            String jsonData = new Gson().toJson(thing, Thing.class);
            Response response = APIUtility.postRequest("recommend/", jsonData);
            return response.wasPosted();
        }
    }
}
