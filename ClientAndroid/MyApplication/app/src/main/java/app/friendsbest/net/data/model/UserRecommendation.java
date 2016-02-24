package app.friendsbest.net.data.model;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class UserRecommendation {
    @SerializedName("comment")
    private String _comment;

    @SerializedName("name")
    private String _name;

    @SerializedName("tags")
    private List<String> _tags;

    public UserRecommendation(){}

    public String getComment() {
        return _comment;
    }

    public void setComment(String comment) {
        this._comment = comment;
    }

    public String getName() {
        return _name;
    }

    public void setName(String name) {
        this._name = name;
    }

    public void setTags(List<String> tags){
        _tags = tags;
    }

    public List<String> getTags() {
        return _tags;
    }
}
