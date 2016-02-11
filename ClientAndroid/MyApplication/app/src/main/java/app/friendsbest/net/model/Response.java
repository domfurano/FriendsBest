package app.friendsbest.net.model;

public class Response {

    private boolean _posted;
    private String _data;
    private int _responseCode;

    public Response(boolean posted, String data, int responseCode) {
        _posted = posted;
        _data = data;
        _responseCode = responseCode;
    }

    public boolean wasPosted() {
        return _posted;
    }

    public String getData() {
        return _data;
    }

    public int getResponseCode() {
        return _responseCode;
    }
}
