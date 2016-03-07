package app.friendsbest.net.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class User {
    @SerializedName("id")
    @Expose
    private String _id;

    @SerializedName("name")
    @Expose
    private String _name;

    public String getId() {
        return _id;
    }

    public void setId(String id) {
        _id = id;
    }

    public String getName() {
        return _name;
    }

    public void setName(String name) {
        _name = name;
    }

    @Override
    public boolean equals(Object o) {
        if (o == this)
            return true;
        if (o == null)
            return false;

        try {
            User user = (User) o;
            if (_id == null && user.getId() != null)
                return false;
            if (!_id.equals(user.getId()))
                return false;
            if (_name == null && user.getName() != null)
                return false;
            if (!_name.equals(user.getName()))
                return false;
            return true;
        }
        catch (ClassCastException e) {
            return false;
        }
    }
}
