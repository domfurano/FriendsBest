package app.friendsbest.net.data.services;

import android.util.Log;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import app.friendsbest.net.data.model.Friend;
import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.model.RecommendationItem;
import app.friendsbest.net.data.model.QueryResult;
import app.friendsbest.net.presenter.interfaces.BasePresenter;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class BaseRepository {

    private final BasePresenter _presenter;
    private final BaseService _service;

    public BaseRepository(BasePresenter presenter, String token){
        _presenter = presenter;
        _service = ServiceGenerator.createService(BaseService.class, token);
    }

    public void getPrompts() {
        _service.getPrompts().enqueue(new Callback<List<PromptCard>>() {
            @Override
            public void onResponse(Call<List<PromptCard>> call, Response<List<PromptCard>> response) {
                List<PromptCard> prompts = null;
                if (response.isSuccess())
                    prompts = response.body();
                _presenter.sendToPresenter(prompts);
            }

            @Override
            public void onFailure(Call<List<PromptCard>> call, Throwable t) {
                logError("Get Prompts", t);
            }
        });
    }

    public void deletePrompt(int id) {
        _service.deletePrompt(id).enqueue(new Callback() {
            @Override
            public void onResponse(Call call, Response response) {
                Log.i("Delete Prompt", "Success: " + response.isSuccess());
            }

            @Override
            public void onFailure(Call call, Throwable t) {
                logError("Delete Prompt", t);
            }
        });
    }

    public void getRecommendations() {
        _service.getRecommendations().enqueue(new Callback<List<RecommendationItem>>() {
            @Override
            public void onResponse(Call<List<RecommendationItem>> call, Response<List<RecommendationItem>> response) {
                List<RecommendationItem> recommendations = null;
                if (response.isSuccess())
                    recommendations = response.body();
                _presenter.sendToPresenter(recommendations);
            }

            @Override
            public void onFailure(Call<List<RecommendationItem>> call, Throwable t) {
                logError("Get Recommendations", t);
            }
        });
    }

    public void postRecommendation(Recommendation recommendation) {
        _service.postRecommendation(recommendation).enqueue(new Callback<Recommendation>() {
            @Override
            public void onResponse(Call<Recommendation> call, Response<Recommendation> response) {
                _presenter.sendToPresenter(response.body());
            }

            @Override
            public void onFailure(Call<Recommendation> call, Throwable t) {
                logError("Post Recommendation", t);
            }
        });
    }

    public void getQueries() {
        _service.getQueryHistory().enqueue(new Callback<List<Query>>() {
            @Override
            public void onResponse(Call<List<Query>> call, Response<List<Query>> response) {
                List<Query> queries = null;
                if (response.isSuccess())
                    queries = response.body();
                _presenter.sendToPresenter(queries);
            }

            @Override
            public void onFailure(Call<List<Query>> call, Throwable t) {
                logError("Get Query History", t);
            }
        });
    }

    public void getQuery(int queryId) {
        _service.getQuery(queryId).enqueue(new Callback<QueryResult>() {
            @Override
            public void onResponse(Call<QueryResult> call, Response<QueryResult> response) {
                QueryResult solution = null;
                if (response.isSuccess())
                    solution = response.body();
                _presenter.sendToPresenter(solution);
            }

            @Override
            public void onFailure(Call<QueryResult> call, Throwable t) {
                logError("Get Query", t);
            }
        });
    }

    public void postQuery(Map<String, List<String>> tags) {
        _service.postQuery(tags).enqueue(new Callback<QueryResult>() {
            @Override
            public void onResponse(Call<QueryResult> call, Response<QueryResult> response) {
                QueryResult solution = null;
                if (response.isSuccess())
                    solution = response.body();
                _presenter.sendToPresenter(solution);
            }

            @Override
            public void onFailure(Call<QueryResult> call, Throwable t) {
                logError("Post Query", t);
            }
        });
    }

    public void getAuthToken(Map<String, String> facebookToken) {
        _service.getAuthToken(facebookToken).enqueue(new Callback<Map<String, String>>() {
            @Override
            public void onResponse(Call<Map<String, String>> call, Response<Map<String, String>> response) {
                Map<String, String> authToken = null;
                if (response.isSuccess())
                    authToken = response.body();
                _presenter.sendToPresenter(authToken);
            }

            @Override
            public void onFailure(Call<Map<String, String>> call, Throwable t) {
                logError("Get Auth", t);
            }
        });
    }

    public void getFriends() {
        _service.getFriends().enqueue(new Callback<List<Friend>>() {
            @Override
            public void onResponse(Call<List<Friend>> call, Response<List<Friend>> response) {
                Map<String, String> responseMap = new HashMap<>();
                String result = response.isSuccess() ? PreferencesUtility.VALID : PreferencesUtility.INVALID;
                responseMap.put(PreferencesUtility.LOGIN_VALIDITY_KEY, result);
                _presenter.sendToPresenter(responseMap);
            }

            @Override
            public void onFailure(Call<List<Friend>> call, Throwable t) {

            }
        });
    }

    private void logError(String message, Throwable t) {
        Log.e(message, t.getMessage(), t);
    }
}
