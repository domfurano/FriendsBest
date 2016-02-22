package app.friendsbest.net.data.services;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

public class NetworkUtility {

    private static ConnectivityManager _connectionManager;
    private static NetworkUtility _instance = null;

    private NetworkUtility(Activity activity){
        _connectionManager = (ConnectivityManager)
                activity.getSystemService(Context.CONNECTIVITY_SERVICE);
    }

    public static NetworkUtility getInstance(Activity activity){
        if (_instance == null){
            _instance = new NetworkUtility(activity);
        }
        return _instance;
    }

    public boolean isDeviceConnected(){
        NetworkInfo networkInfo = _connectionManager.getActiveNetworkInfo();
        return networkInfo != null && networkInfo.isConnected();
    }
}
