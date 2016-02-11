package app.friendsbest.net.model;

import com.google.gson.annotations.SerializedName;

public class UserProfile {

    public enum ProfileKey {

        FULL_NAME("full_name"),
        USER_ID("user_id"),
        ACCESS_TOKEN("access_token"),
        FACEBOOK_TOKEN("facebook_token");

        private String _key;

        private ProfileKey(String key){
            _key = key;
        }

        public String getKey(){
            return _key;
        }
    }

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

