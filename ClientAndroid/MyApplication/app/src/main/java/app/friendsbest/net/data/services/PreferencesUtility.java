package app.friendsbest.net.data.services;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

public class PreferencesUtility {

    public static final String ACCESS_TOKEN_KEY = "key";
    public static final String USER_NAME_KEY = "user_name";
    public static final String FACEBOOK_TOKEN_KEY = "access_token";
    public static final String PROFILE_PICTURE_URI = "user_picture";
    public static final String LOGIN_VALIDITY_KEY = "login_validity";
    public static final String VALID = "valid";
    public static final String INVALID = "invalid";

    public static PreferencesUtility _instance = null;
    private SharedPreferences _preferences;
    private SharedPreferences.Editor _editor;


    private PreferencesUtility(Context context){
        _preferences = PreferenceManager.getDefaultSharedPreferences(context);
        _editor = _preferences.edit();
    }

    public static PreferencesUtility getInstance(Context context){
        if (_instance == null)
            _instance = new PreferencesUtility(context);
        return _instance;
    }

    public String getToken(){
        String token = _preferences.getString(ACCESS_TOKEN_KEY, null);
        return token;
    }

    public String getUserName(){
        String fullName =_preferences.getString(USER_NAME_KEY, null);
        return fullName;
    }

    public String getProfilePictureUri() {
        String uri = _preferences.getString(PROFILE_PICTURE_URI, null);
        return uri;
    }

    public boolean saveToken(String token) {
        _editor.putString(ACCESS_TOKEN_KEY, token);
        return _editor.commit();
    }

    public boolean saveUserName(String fullName){
        _editor.putString(USER_NAME_KEY, fullName);
        return _editor.commit();
    }

    /**
     * Save a URI of user's Facebook profile picture.
     * @param uri - String representation of profile picture URI
     * @return - Result of committing to SharedPreferences
     */
    public boolean saveProfilePicture(String uri) {
        _editor.putString(PROFILE_PICTURE_URI, uri);
        return _editor.commit();
    }

    public void deleteStoredData(){
        _editor.remove(ACCESS_TOKEN_KEY);
        _editor.remove(USER_NAME_KEY);
        _editor.remove(PROFILE_PICTURE_URI);
        _editor.commit();
    }
}
