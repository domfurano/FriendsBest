package app.friendsbest.net.data.services;

import android.content.Intent;

import com.google.android.gms.iid.InstanceIDListenerService;

public class GcmIDListenerService extends InstanceIDListenerService {
    @Override
    public void onTokenRefresh() {
        Intent intent = new Intent(this, RegistrationIntentService.class);
        startService(intent);
    }
}
