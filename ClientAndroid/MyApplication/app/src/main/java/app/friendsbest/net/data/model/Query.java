package app.friendsbest.net.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

public class Query {
    @SerializedName("accessed")
    @Expose
    private String _accessed;

    @SerializedName("tags")
    @Expose
    private List<String> _tags = new ArrayList<String>();

    @SerializedName("id")
    @Expose
    private int _id;

    @SerializedName("solutions")
    @Expose
    private List<Solution> _solutions = new ArrayList<>();

    @SerializedName("taghash")
    @Expose
    private String _tagHash;

    @SerializedName("tagstring")
    @Expose
    private String _tagString;

    public String getAccessed() {
        return _accessed;
    }

    public void setAccessed(String accessed) {
        this._accessed = accessed;
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

    public List<Solution> getSolutions() {
        return _solutions;
    }

    public void setSolutions(List<Solution> solutions) {
        _solutions = solutions;
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

    @Override
    public String toString(){
        String tagString = "";
        for (String tag : _tags)
            tagString += tag + " ";
        return tagString;
    }
}