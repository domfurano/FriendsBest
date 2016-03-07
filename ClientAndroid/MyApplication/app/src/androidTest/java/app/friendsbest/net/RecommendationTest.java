package app.friendsbest.net;


import android.support.test.runner.AndroidJUnit4;
import android.test.suitebuilder.annotation.SmallTest;

import com.google.gson.Gson;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.data.model.Recommendation;
import app.friendsbest.net.data.model.RecommendationPost;
import app.friendsbest.net.data.model.User;

import static org.junit.Assert.assertTrue;

@RunWith(AndroidJUnit4.class)
@SmallTest
public class RecommendationTest {

    private String _detail;
    private String _comments;
    private List<String> _tags;
    private String _type;
    private int _id;
    private User _user;

    public RecommendationTest(){
        _tags = new ArrayList<>();
    }

    @Before
    public void setUp() {
        _detail = "mexican food restaurant";
        _comments = "Their tomatillo sauce is so good!";
        _tags.add("cafe");
        _tags.add("rio");
        _id = 13;
        _type = "TEXT";
        _user = new User();
        _user.setId("139982843051386");
        _user.setName("Umair Naweed");
    }

    @Test
    public void testGsonObjects() {
        RecommendationPost request = new RecommendationPost();
        request.setDetail(_detail);
        request.setComments(_comments);
        request.setType(_type);
        request.setTags(_tags);
        String post = "{\"detail\":\"mexican food restaurant\",\"tags\":[\"cafe\",\"rio\"],\"comments\":\"Their tomatillo sauce is so good! \",\"type\":\"TEXT\"}";
        RecommendationPost expectedObj = new Gson().fromJson(post, RecommendationPost.class);

        assertTrue("Not same detail", expectedObj.getDetail().equals(request.getDetail()));
        assertTrue("Not same comments", expectedObj.getComments().equals(request.getComments()));
        assertTrue("Not same type", expectedObj.getType().equals(request.getType()));
        assertTrue("Not same tags", expectedObj.getTags().size() != request.getTags().size());
        for(int i = 0; i < expectedObj.getTags().size(); i++)
            assertTrue("Not same tags", expectedObj.getTags().get(i).equals(request.getTags().get(i)));
    }

    public void testGsonObjects1() {
        String response = "{\"id\":13,\"type\":\"Text\",\"comments\":\"Their tomatillo sauce is so good! \",\"tags\":[\"cafe\",\"rio\"],\"detail\":\"mexican food restaurant\",\"user\":{\"id\":\"139982843051386\",\"name\":\"Umair Naweed\"}}";
        Recommendation recommendation = new Gson().fromJson(response, Recommendation.class);
        Recommendation expectedObj = new Recommendation();
        expectedObj.setDetail(_detail);
        expectedObj.setId(_id);
        expectedObj.setTags(_tags);
        expectedObj.setComment(_comments);
        expectedObj.setUser(_user);
        expectedObj.setType(_type);

        assertTrue(recommendation.equals(expectedObj));
    }
}
