package app.friendsbest.net.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Prompt {

    public static enum Key {
        PROMPT_STRING("prompt_string");

        private String _key;
        Key(String key){
            _key = key;
        }

        public String getKey(){
            return _key;
        }
    }

    @SerializedName("article")
    private String _article;

    @SerializedName("friend")
    private String _friend;

    @SerializedName("tagstring")
    private String tagString;

    @SerializedName("tags")
    private String[] _tags;

    @SerializedName("id")
    private int _id;

    public String getArticle() {
        return _article;
    }

    public void setArticle(String article) {
        _article = article;
    }

    public String getFriend() {
        return _friend;
    }

    public void setFriend(String friend) {
        _friend = friend;
    }

    public String getTagString() {
        return tagString;
    }

    public void setTagString(String tagString) {
        this.tagString = tagString;
    }

    public String[] getTags() {
        return _tags;
    }

    public void setTags(String[] tags) {
        _tags = tags;
    }

    public int getId() {
        return _id;
    }

    public void setId(int id) {
        _id = id;
    }
}
