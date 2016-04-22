package app.friendsbest.net.data.utilities;

import com.squareup.otto.Bus;

public class BusProvider {

    private static Bus _bus;

    private BusProvider() {
        _bus = new Bus();
    }

    public static Bus getInstance() {
        if (_bus == null)
            _bus = new Bus();
        return _bus;
    }
}
