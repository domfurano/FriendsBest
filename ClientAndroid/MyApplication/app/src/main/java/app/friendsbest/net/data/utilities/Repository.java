package app.friendsbest.net.data.utilities;

import android.util.Log;

import com.squareup.otto.Bus;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import app.friendsbest.net.data.events.DeleteRecommendationEvent;
import app.friendsbest.net.data.events.LoadFriendsEvent;
import app.friendsbest.net.data.events.LoadPromptEvent;
import app.friendsbest.net.data.events.LoadQueryEvent;
import app.friendsbest.net.data.events.LoadRecommendationEvent;
import app.friendsbest.net.data.events.LoginEvent;
import app.friendsbest.net.data.events.LoadNotificationEvent;
import app.friendsbest.net.data.model.Friend;
import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.data.model.QueryResult;
import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.model.RecommendationPost;
import app.friendsbest.net.data.services.RestClientService;
import app.friendsbest.net.data.services.ServiceGenerator;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/**
 * Handles network communication with both internal and external endpoints.
 */
public class Repository {

    private RestClientService _service;
    private Bus _bus;

    public Repository(Bus bus) {
        _bus = bus;
        _service = ServiceGenerator.createService(RestClientService.class);
    }

    public Repository(String token, Bus bus) {
        _service = ServiceGenerator.createService(RestClientService.class, token);
        _bus = bus;
    }

    public void getPrompts() {
        Call call = _service.getPrompts();
        call.clone().enqueue(new Callback<List<PromptCard>>() {
            @Override
            public void onResponse(Call<List<PromptCard>> call, Response<List<PromptCard>> response) {
                List<PromptCard> prompts = response.isSuccess() ? response.body()
                        : new ArrayList<PromptCard>();
                _bus.post(new LoadPromptEvent(prompts));
            }

            @Override
            public void onFailure(Call<List<PromptCard>> call, Throwable t) {
                _bus.post(new LoadPromptEvent(new ArrayList<PromptCard>()));
                logError("Get Prompts", t);
            }
        });
    }

    public void deletePrompt(int id) {
        Call call = _service.deletePrompt(id);
        call.clone().enqueue(new Callback() {
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
        Call call = _service.getRecommendations();
        call.clone().enqueue(new Callback<List<Recommendation>>() {
            @Override
            public void onResponse(Call<List<Recommendation>> call, Response<List<Recommendation>> response) {
                List<Recommendation> recommendations = response.isSuccess() ? response.body()
                        : new ArrayList<Recommendation>();
                _bus.post(new LoadRecommendationEvent(recommendations));
            }

            @Override
            public void onFailure(Call<List<Recommendation>> call, Throwable t) {
                _bus.post(new LoadRecommendationEvent(new ArrayList<Recommendation>()));
                logError("Get Recommendations", t);
            }
        });
    }

    public void postRecommendation(RecommendationPost recommendation) {
        Call call = _service.postRecommendation(recommendation);
        call.clone().enqueue(new Callback<Recommendation>() {
            @Override
            public void onResponse(Call<Recommendation> call, Response<Recommendation> response) {
                _bus.post(response.body());
            }

            @Override
            public void onFailure(Call<Recommendation> call, Throwable t) {
                logError("Post Recommendation", t);
            }
        });
    }

    public void deleteRecommendation(final int recommendationId) {
        Call call = _service.deleteRecommendation(recommendationId);
        call.clone().enqueue(new Callback<Void>() {
            @Override
            public void onResponse(Call<Void> call, Response<Void> response) {
                int deletedId = response.isSuccess() ? recommendationId : -1;
                _bus.post(new DeleteRecommendationEvent(deletedId));
            }

            @Override
            public void onFailure(Call<Void> call, Throwable t) {
                logError("Delete Recommendation", t);
            }
        });
    }

    public void deleteNotification(final int recommendationId) {
        Call call = _service.deleteNotification(recommendationId);
        call.clone().enqueue(new Callback<Void>() {
            @Override
            public void onResponse(Call<Void> call, Response<Void> response) {
                Log.i("Delete Notification", "Accepted = " + response.isSuccess());
            }

            @Override
            public void onFailure(Call<Void> call, Throwable t) {
                logError("Delete Notification", t);
            }
        });
    }

    public void getQueries() {
        Call call = _service.getQueryHistory();
        call.clone().enqueue(new Callback<List<Query>>() {
            @Override
            public void onResponse(Call<List<Query>> call, Response<List<Query>> response) {
                List<Query> queries = null;
                if (response.isSuccess())
                    queries = response.body();
                _bus.post(new LoadQueryEvent(queries));
            }

            @Override
            public void onFailure(Call<List<Query>> call, Throwable t) {
                logError("Get Query History", t);
            }
        });
    }

    public void getQuery(int queryId) {
        Call call = _service.getQuery(queryId);
        call.clone().enqueue(new Callback<QueryResult>() {
            @Override
            public void onResponse(Call<QueryResult> call, Response<QueryResult> response) {
                QueryResult solution = null;
                if (response.isSuccess())
                    solution = response.body();
                _bus.post(solution);
            }

            @Override
            public void onFailure(Call<QueryResult> call, Throwable t) {
                logError("Get Query", t);
            }
        });
    }

    public void postQuery(Map<String, List<String>> tags) {
        Call call = _service.postQuery(tags);
        call.clone().enqueue(new Callback<QueryResult>() {
            @Override
            public void onResponse(Call<QueryResult> call, Response<QueryResult> response) {
                QueryResult solution = null;
                if (response.isSuccess())
                    solution = response.body();
                _bus.post(solution);
            }

            @Override
            public void onFailure(Call<QueryResult> call, Throwable t) {
                logError("Post Query", t);
            }
        });
    }

    public void deleteQuery(int queryId) {
        Call call = _service.deleteQuery(queryId);
        call.clone().enqueue(new Callback<Void>() {
            @Override
            public void onResponse(Call<Void> call, Response<Void> response) {
                Log.i("Delete Query", "Success: " + response.isSuccess());
            }

            @Override
            public void onFailure(Call<Void> call, Throwable t) {
                logError("Delete Query", t);
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
                _bus.post(new LoginEvent(authToken));
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
                List<Friend> friendList = response.isSuccess() ? response.body() : new ArrayList<Friend>();
                _bus.post(new LoadFriendsEvent(friendList));
            }

            @Override
            public void onFailure(Call<List<Friend>> call, Throwable t) {
                Log.e("Friends", t.getMessage(), t);
                _bus.post(new LoadFriendsEvent(new ArrayList<Friend>()));
            }
        });
    }

    public void changeMuteState(final Friend friend) {
        _service.changeMuteState(friend.getId(), friend).enqueue(new Callback<Friend>() {
            @Override
            public void onResponse(Call<Friend> call, Response<Friend> response) {
                Log.i(friend.getName(), "Mute status changed: " + response.isSuccess());
            }

            @Override
            public void onFailure(Call<Friend> call, Throwable t) {
                logError("Change Mute Status", t);
            }
        });
    }

    public void getNotificationCount() {
        Call call = _service.getNotificationCount();
        call.clone().enqueue(new Callback<Map<String, Integer>>() {
            @Override
            public void onResponse(Call<Map<String, Integer>> call, Response<Map<String, Integer>> response) {
                int count = 0;
                if (response.isSuccess()) {
                    Map<String, Integer> map = response.body();
                    count = map.get("notifications");
                }
                _bus.post(new LoadNotificationEvent(count));
            }

            @Override
            public void onFailure(Call<Map<String, Integer>> call, Throwable t) {
                _bus.post(new LoadNotificationEvent(0));
                logError("Get Notifications", t);
            }
        });
    }

    public void checkLoginStatus() {
        final HashMap<String, String> resultMap = new HashMap<>();
        Call call = _service.getFriends();
        call.clone().enqueue(new Callback<List<Friend>>() {
            @Override
            public void onResponse(Call<List<Friend>> call, Response<List<Friend>> response) {
                String validity = response.isSuccess() ? PreferencesUtility.VALID : PreferencesUtility.INVALID;
                resultMap.put(PreferencesUtility.LOGIN_VALIDITY_KEY, validity);
                _bus.post(new LoginEvent(resultMap));
            }

            @Override
            public void onFailure(Call<List<Friend>> call, Throwable t) {
                Log.e("Login invlaid", t.getMessage(), t);
                resultMap.put(PreferencesUtility.LOGIN_VALIDITY_KEY, PreferencesUtility.INVALID);
                _bus.post(new LoginEvent(resultMap));
            }
        });
    }

    private void logError(String message, Throwable t) {
        Log.e(message, t.getMessage(), t);
    }
}
