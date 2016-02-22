package app.friendsbest.net.data.services;

import java.util.List;
import java.util.Map;

import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.data.model.UserRecommendation;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.DELETE;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Path;

public interface BaseService {

    @GET("query")
    Call<List<Query>> getQueryHistory();

    @POST("query")
    int postQuery(@Body Query query);

    @GET("prompt")
    Call<List<PromptCard>> getPrompts();

    @DELETE("prompt/{id}")
    void deletePrompt(int id);

    @GET("recommend")
    Call<List<UserRecommendation>> getRecommendations();

    @GET("recommend/{recommendId}")
    Call<UserRecommendation> getRecommendation(@Path("recommendId") int id);

    @POST("recommend")
    public void postRecommendation(@Body UserRecommendation recommendation);

    @POST("facebook")
    Call<Map<String, String>> getAuthToken(@Body Map<String, String> facebookToken);
}
