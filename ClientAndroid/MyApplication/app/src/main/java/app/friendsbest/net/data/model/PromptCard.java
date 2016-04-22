package app.friendsbest.net.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

public class PromptCard {

    @SerializedName("tagstring")
    @Expose
    private String _tagstring;
    @SerializedName("tags")
    @Expose
    private List<String> _tags = new ArrayList<>();
    @SerializedName("id")
    @Expose
    private int _id;
    @SerializedName("friend")
    @Expose
    private Friend _friend;
    @SerializedName("article")
    @Expose
    private String _article;
    @SerializedName("urgent")
    @Expose
    private boolean _urgent;

    public String getTagstring() {
        return _tagstring;
    }

    public void setTagstring(String tagstring) {
        this._tagstring = tagstring;
    }

    public List<String> getTags() {
        return _tags;
    }

    public void setTags(List<String> tags) {
        this._tags = tags;
    }

    public int getId() {
        return _id;
    }

    public void setId(int id) {
        this._id = id;
    }

    public Friend getFriend() {
        return _friend;
    }

    public void setFriend(Friend friend) {
        this._friend = friend;
    }

    public String getArticle() {
        return _article;
    }

    public void setArticle(String article) {
        this._article = article;
    }

    public boolean isUrgent() {
        return _urgent;
    }

    public void setUrgent(boolean urgent) {
        _urgent = urgent;
    }
}