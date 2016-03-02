package app.friendsbest.net.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

public class Query {
    @SerializedName("timestamp")
    @Expose
    private String timestamp;

    @SerializedName("tags")
    @Expose
    private List<String> _tags = new ArrayList<String>();

    @SerializedName("id")
    @Expose
    private int _id;

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public List<String> getTags() {
        return _tags;
    }

    public void setTags(List<String> tags) {
        _tags = tags;
    }

    public int getId() {
        return _id;
    }

    public void setId(int id) {
        _id = id;
    }

    @Override
    public String toString(){
        String tagString = "";
        for (String tag : _tags)
            tagString += tag + " ";
        return tagString;
    }
}