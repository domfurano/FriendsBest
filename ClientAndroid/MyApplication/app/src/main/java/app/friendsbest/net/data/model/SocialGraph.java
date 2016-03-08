package app.friendsbest.net.data.model;

import com.google.gson.annotations.SerializedName;

import java.util.List;
import java.util.Map;

public class SocialGraph {

    @SerializedName("data")
    List<Map<String, String>> _data;

    public List<Map<String, String>> getData() {
        return _data;
    }

    public void setData(List<Map<String, String>> data) {
        _data = data;
    }
}
