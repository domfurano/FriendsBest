package app.friendsbest.net.data.services;

import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;

import com.google.android.gms.gcm.GcmListenerService;
import com.google.gson.Gson;

import java.util.Map;

import app.friendsbest.net.R;
import app.friendsbest.net.ui.DualFragmentActivity;

public class AppGcmListenerService extends GcmListenerService {

    private static final int PROMPT_ID = 1;
    private static final int RECOMMENDATION_ID = 2;
    private static int _promptMessages = 0;
    private static int _recommendationMessages = 0;

    @Override
    public void onMessageReceived(String from, Bundle data) {

        if (from.startsWith("/topics/") && !DualFragmentActivity._isActivityRunning) {
            String user;
            String title;
            String message;
            if (from.contains(RegistrationIntentService.PROMPT_TOPIC)) {
                Map<String, String> prompt = new Gson().fromJson(data.getString("friend"), Map.class);
                String tagString;
                if (_promptMessages == 0){
                    tagString = data.getString("tagstring");
                    user = prompt.get("name");
                    message = tagString + ". Do you have a recommendation?";
                    title = user + " is looking for";
                }
                else {
                    user = prompt.get("name");
                    title = user + " and " + _promptMessages + " others";
                    message = "Need recommendations, help them out!";
                }
                sendNotification(PROMPT_ID, message, title);
                _promptMessages++;
            }
            else if (from.contains(RegistrationIntentService.RECOMMENDATION_TOPIC)) {
                Map<String, String> rec = new Gson().fromJson(data.getString("user"), Map.class);
                user = rec.get("name");
                String detail;
                if (_recommendationMessages == 0){
                    detail = data.getString("detail");
                    title = "New Recommendation";
                    message = user + " recommends " + detail;
                }
                else {
                    message =  "From " + user + " and " + _recommendationMessages + " others";
                    title = "New Recommendations";
                }
                sendNotification(RECOMMENDATION_ID, message, title);
                _recommendationMessages++;
            }
        }
    }

    private void sendNotification(int notificationId, String message, String title) {
        Intent intent = new Intent(this, DualFragmentActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent,
                PendingIntent.FLAG_ONE_SHOT);

        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.ic_logo_vector)
                .setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.ic_app_notification))
                .setContentTitle(title)
                .setContentText(message)
                .setAutoCancel(true)
                .setSound(defaultSoundUri)
                .setContentIntent(pendingIntent);

        NotificationManager notificationmanager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationmanager.notify(notificationId, notificationBuilder.build());
    }
}
