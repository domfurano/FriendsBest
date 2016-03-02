package app.friendsbest.net.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

public class QueryResult {
    @SerializedName("solutions")
    @Expose
    private List<Solution> _solutions;

    @SerializedName("tags")
    @Expose
    private String[] _tags;

    @SerializedName("taghash")
    @Expose
    private String _tagHash;

    @SerializedName("tagstring")
    @Expose
    private String _tagString;

    @SerializedName("id")
    @Expose
    private int _id;

    @SerializedName("timestamp")
    @Expose
    private String _timeStamp;

    public List<Solution> getSolutions() {
        return _solutions;
    }

    public void setSolutions(List<Solution> solutions) {
        _solutions = solutions;
    }

    public String[] getTags() {
        return _tags;
    }

    public void setTags(String[] tags) {
        _tags = tags;
    }

    public String getTagHash() {
        return _tagHash;
    }

    public void setTagHash(String tagHash) {
        _tagHash = tagHash;
    }

    public String getTagString() {
        return _tagString;
    }

    public void setTagString(String tagString) {
        _tagString = tagString;
    }

    public int getId() {
        return _id;
    }

    public void setId(int id) {
        _id = id;
    }

    public String getTimeStamp() {
        return _timeStamp;
    }

    public void setTimeStamp(String timeStamp) {
        _timeStamp = timeStamp;
    }
}
