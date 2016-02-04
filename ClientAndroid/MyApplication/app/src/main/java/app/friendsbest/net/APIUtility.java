package app.friendsbest.net;

import android.util.Log;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;

public class APIUtility {

    public static final String API_BASE_URL = "http://10.0.1.13:8000/fb/api/";
    private static final String ACCEPT_LANG = "en-US,en;q=0.5";
    private static final String CONTENT_TYPE = "application/json";

    /**
     * Given a URL of a web service, retrieves response data in the form of a JSON String.
     * @param apiURL - URL of the web service to retrieve response from
     * @return - Response retrieved from API.
     */
    public static String getResponse(String apiURL, String token) {
        try {
            URL url = new URL(API_BASE_URL + apiURL);
            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setRequestProperty("Authorization", token);
            urlConnection.setRequestMethod("GET");
            try {
                BufferedReader reader = new BufferedReader(
                        new InputStreamReader(urlConnection.getInputStream()));
                StringBuilder stringBuilder = new StringBuilder();
                String line;
                while((line = reader.readLine()) != null) {
                    stringBuilder.append(line);
                    stringBuilder.append("\n");
                }
                reader.close();
                return stringBuilder.toString();
            }
            finally {
                urlConnection.disconnect();
            }
        }
        catch (Exception e) {
            Log.e("Error ", e.getMessage(), e);
            return null;
        }
    }

    /**
     * Given a URL for a web service and a JSON formatted String, posts data to the web service.
     * @param apiURL - URL of the web service to post data to.
     * @param payload - JSON formatted string containing data to send to web service.
     * @return - Response from the server.
     */
    public static Response postRequest(String apiURL, String payload) {
        try {
            Log.i("APIUtility ", "JSON Data: \n" + payload);
            URL url = new URL(apiURL);
            HttpURLConnection client = (HttpURLConnection) url.openConnection();

            client.setRequestMethod("POST");
            client.setRequestProperty("Content-Type", CONTENT_TYPE);
            client.setRequestProperty("Accept-Type", CONTENT_TYPE);
            client.setRequestProperty("Accept-Language", ACCEPT_LANG);

            // Send POST request
            client.setDoOutput(true);
            client.setDoInput(true);
            OutputStream outputStream = client.getOutputStream();
            OutputStreamWriter writer = new OutputStreamWriter(outputStream, "UTF-8");
            writer.write(payload);
            writer.flush();
            writer.close();
            outputStream.close();

            InputStream input = client.getInputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(input));
            StringBuilder responseBuffer = new StringBuilder();
            String line;

            while((line = reader.readLine()) != null){
                responseBuffer.append(line);
            }

            Log.i("Response: ", responseBuffer.toString());

            int responseCode = client.getResponseCode();
            boolean wasPosted = responseCode == 201;
            return new Response(wasPosted, responseBuffer.toString(), responseCode);
        }
        catch (Exception e) {
            Log.e("Error ", e.getMessage(), e);
            return new Response(false, e.getMessage(), -1);
        }
    }
}
