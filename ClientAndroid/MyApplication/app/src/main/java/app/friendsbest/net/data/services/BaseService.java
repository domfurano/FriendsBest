package app.friendsbest.net.data.services;

import java.util.List;
import java.util.Map;

import app.friendsbest.net.data.model.Friend;
import app.friendsbest.net.data.model.PromptCard;
import app.friendsbest.net.data.model.Query;
import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.model.RecommendationItem;
import app.friendsbest.net.data.model.QueryResult;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.DELETE;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Path;

public interface BaseService {

    @GET("query")
    Call<List<Query>> getQueryHistory();

    @GET("query/{queryId}")
    Call<QueryResult> getQuery(@Path("queryId") int id);

    @POST("query")
    Call<QueryResult> postQuery(@Body Map<String, List<String>> tags);

    @GET("prompt")
    Call<List<PromptCard>> getPrompts();

    @DELETE("prompt/{id}")
    Call deletePrompt(int id);

    @GET("recommend")
    Call<List<RecommendationItem>> getRecommendations();

    @GET("recommend/{recommendId}")
    Call<RecommendationItem> getRecommendation(@Path("recommendId") int id);

    @POST("recommend")
    Call<Recommendation> postRecommendation(@Body Recommendation recommendation);

    @POST("facebook/")
    Call<Map<String, String>> getAuthToken(@Body Map<String, String> facebookToken);

    @GET("friend")
    Call<List<Friend>> getFriends();
}
