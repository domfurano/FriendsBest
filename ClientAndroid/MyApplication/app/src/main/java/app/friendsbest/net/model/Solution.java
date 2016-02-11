package app.friendsbest.net.model;

import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;

public class Solution {
    @SerializedName("recommendation")
    private ArrayList<UserRecommendation> _recommendation;

    @SerializedName("name")
    private String _name;

    @SerializedName("tags")
    private String[] _tags;

    @SerializedName("taghash")
    private String _tagHash;

    @SerializedName("tagstring")
    private String _tagString;

    @SerializedName("id")
    private int _id;

    @SerializedName("timestamp")
    private String _timeStamp;


    public ArrayList<UserRecommendation> getRecommendation() {
        return _recommendation;
    }

    public void setRecommendation(ArrayList<UserRecommendation> recommendation) {
        _recommendation = recommendation;
    }

    public void setName(String name) {
        _name = name;
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

    @Override
    public String toString(){
        String[] nameParts = this._name.split("\r\n");
        return nameParts[0];
    }
    public String getName(){
        return this._name;
    }

    public ArrayList<UserRecommendation> getRecommendations(){
        return this._recommendation;
    }
}
