package app.friendsbest.net.data.model;

import java.util.ArrayList;
import java.util.List;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class PromptCard {

    @SerializedName("tagstring")
    @Expose
    private String tagstring;
    @SerializedName("tags")
    @Expose
    private List<String> tags = new ArrayList<>();
    @SerializedName("id")
    @Expose
    private int id;
    @SerializedName("friend")
    @Expose
    private String friend;
    @SerializedName("article")
    @Expose
    private String article;

    public String getTagstring() {
        return tagstring;
    }

    public void setTagstring(String tagstring) {
        this.tagstring = tagstring;
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFriend() {
        return friend;
    }

    public void setFriend(String friend) {
        this.friend = friend;
    }

    public String getArticle() {
        return article;
    }

    public void setArticle(String article) {
        this.article = article;
    }
}