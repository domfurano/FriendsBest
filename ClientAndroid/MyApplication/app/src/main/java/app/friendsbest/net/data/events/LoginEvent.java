package app.friendsbest.net.data.events;

import java.util.Map;

import app.friendsbest.net.data.utilities.PreferencesUtility;

public class LoginEvent {

    private final Map<String, String> _loginEvent;
    private String _value;

    public LoginEvent(Map<String,String> event) {
        _loginEvent = event;
    }

    public Map<String, String> getLoginEvent(){
        return _loginEvent;
    }

    public boolean isAccessTokenKey() {
        String value = _loginEvent.get(PreferencesUtility.ACCESS_TOKEN_KEY);
        _value = value;
        return value != null;
    }

    public boolean isFacebookToken() {
        String value = _loginEvent.get(PreferencesUtility.FACEBOOK_TOKEN_KEY);
        _value = value;
        return value != null;
    }

    public boolean isLoginValidityKey() {
        String value = _loginEvent.get(PreferencesUtility.LOGIN_VALIDITY_KEY);
        _value = value;
        return value != null;
    }

    public String getKeyValue(){
        return _value;
    }
}
