package app.friendsbest.net.data.services;

import android.util.Log;

import java.util.List;
import java.util.Map;

import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.data.model.UserRecommendation;
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
                Log.e("Could not get prompts", t.getMessage(), t);
            }
        });
    }

    public void deletePrompt(int id) {
        // TODO: Implement
    }

    public void getRecommendations() {
        _service.getRecommendations().enqueue(new Callback<List<UserRecommendation>>() {
            @Override
            public void onResponse(Call<List<UserRecommendation>> call, Response<List<UserRecommendation>> response) {
                List<UserRecommendation> recommendations = null;
                if (response.isSuccess())
                    recommendations = response.body();
                _presenter.sendToPresenter(recommendations);
            }

            @Override
            public void onFailure(Call<List<UserRecommendation>> call, Throwable t) {
                Log.e("Could not get recs", t.getMessage(), t);
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
                Log.e("Could not get queries", t.getMessage(), t);
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
                Log.e("Could get authenticate", t.getMessage(), t);
            }
        });
    }
}
