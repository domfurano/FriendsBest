package app.friendsbest.net.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Friend {

    @SerializedName("name")
    @Expose
    private String _name;

    @SerializedName("id")
    @Expose
    private String _id;

    @SerializedName("muted")
    @Expose
    private boolean _muted;

    public String getName() {
        return _name;
    }

    public void setName(String name) {
        _name = name;
    }

    public String getId() {
        return _id;
    }

    public void setId(String id) {
        _id = id;
    }

    public boolean isMuted() {
        return _muted;
    }

    public void setMuted(boolean muted) {
        _muted = muted;
    }
}
