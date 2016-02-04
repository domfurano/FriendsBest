package app.friendsbest.net;

import com.google.gson.annotations.SerializedName;

public class UserProfile {
    @SerializedName("name")
    private String _fullName;

    @SerializedName("id")
    private String _userID;

    private String _facebookToken;
    private String _djangoToken;

    public UserProfile(){}

    public String getFullName() {
        return _fullName;
    }

    public void setFullName(String fullName) {
        _fullName = fullName;
    }

    public String getUserID() {
        return _userID;
    }

    public void setUserID(String userID) {
        _userID = userID;
    }

    public String getFacebookToken() {
        return _facebookToken;
    }

    public void setFacebookToken(String facebookToken) {
        _facebookToken = facebookToken;
    }

    public String getDjangoToken() {
        return _djangoToken;
    }

    public void setDjangoToken(String djangoToken) {
        _djangoToken = djangoToken;
    }
}

