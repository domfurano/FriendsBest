package app.friendsbest.net.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

public class Recommendation {

    @SerializedName("id")
    @Expose
    private int _id;

    @SerializedName("tags")
    @Expose
    private List<String> _tags = new ArrayList<>();

    @SerializedName("comments")
    @Expose
    private String _comment;

    @SerializedName("detail")
    @Expose
    private String _detail;

    @SerializedName("type")
    @Expose
    private String _type;

    @SerializedName("user")
    @Expose
    private User _user;

    public int getId() {
        return _id;
    }

    public void setId(int id) {
        _id = id;
    }

    public List<String> getTags() {
        return _tags;
    }

    public void setTags(List<String> tags) {
        _tags = tags;
    }

    public String getComment() {
        return _comment;
    }

    public void setComment(String comment) {
        _comment = comment;
    }

    public String getDetail() {
        return _detail;
    }

    public void setDetail(String detail) {
        _detail = detail;
    }

    public String getType() {
        return _type;
    }

    public void setType(String type) {
        _type = type;
    }

    public User getUser() {
        return _user;
    }

    public void setUser(User user) {
        _user = user;
    }
}
