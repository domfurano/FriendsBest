package app.friendsbest.net.data.utilities;

import android.app.Application;

import com.squareup.otto.Bus;

public class MainApplication extends Application {

    private Bus _bus = BusProvider.getInstance();

    @Override
    public void onCreate() {
        super.onCreate();
        _bus.register(this);
    }
}
