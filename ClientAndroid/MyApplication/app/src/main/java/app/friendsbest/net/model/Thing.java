package app.friendsbest.net.model;

import com.google.gson.annotations.SerializedName;

public class Thing {
    @SerializedName("comments")
    private String _comments;

    @SerializedName("description")
    private String _description;

    @SerializedName("tags")
    private String[] _tags;

    @SerializedName("user")
    private int _user;

    public String getComments() {
        return _comments;
    }

    public void setComments(String comments) {
        this._comments = comments;
    }

    public String getDescription() {
        return _description;
    }

    public void setDescription(String description) {
        this._description = description;
    }

    public String[] getTags() {
        return _tags;
    }

    public void setTags(String[] tags) {
        this._tags = tags;
    }

    public int getUser() {
        return _user;
    }

    public void setUser(int user) {
        this._user = user;
    }
}