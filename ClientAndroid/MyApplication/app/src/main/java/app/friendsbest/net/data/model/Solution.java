package app.friendsbest.net.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

public class Solution {
    @SerializedName("type")
    @Expose
    private String _type;
    @SerializedName("recommendations")
    @Expose
    private List<RecommendationItem> _recommendations = new ArrayList<>();
    @SerializedName("detail")
    @Expose
    private String _detail;
    @SerializedName("isPinned")
    @Expose
    private boolean _isPinned;

    public String getType() {
        return _type;
    }

    public void setType(String type) {
        _type = type;
    }

    public List<RecommendationItem> getRecommendations() {
        return _recommendations;
    }

    public void setRecommendations(List<RecommendationItem> recommendations) {
        _recommendations = recommendations;
    }

    public String getDetail() {
        return _detail;
    }

    public void setDetail(String detail) {
        _detail = detail;
    }

    public boolean isPinned() {
        return _isPinned;
    }

    public void setIsPinned(boolean isPinned) {
        _isPinned = isPinned;
    }

    @Override
    public String toString() {
        return _detail;
    }
}
