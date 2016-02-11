package app.friendsbest.net.model;

import com.google.gson.annotations.SerializedName;

public class UserRecommendation {
    @SerializedName("comment")
    private String _comment;

    @SerializedName("name")
    private String _name;

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
}
