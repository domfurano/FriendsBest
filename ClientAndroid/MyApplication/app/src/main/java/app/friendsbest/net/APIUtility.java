package app.friendsbest.net;

import android.util.Log;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;

import app.friendsbest.net.data.model.Response;

public class APIUtility {

    public static final String API_BASE_URL = "https://www.friendsbest.net/fb/api/";
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
            urlConnection.setRequestProperty("Authorization", "Token " + token);
            urlConnection.setRequestMethod("GET");
            try {
                Log.i("GET response code", Integer.toString(urlConnection.getResponseCode()));
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
     * Post JSON formatted string to endpoint with authorization token in header.
     * @param apiURL - Endpoint url
     * @param payload - JSON formatted string
     * @param token - Authorization token
     * @return - Response containing status code and (if applicable) JSON string.
     */
    public static Response postRequest(String apiURL, String payload, String token) {
        try {
            Log.i("APIUtility ", "JSON Data: \n" + payload);
            if (token != null)
               Log.i("APIUtility POST Token: ", token);

            URL url = new URL(API_BASE_URL + apiURL);
            HttpURLConnection client = (HttpURLConnection) url.openConnection();

            client.setRequestMethod("POST");
            client.setRequestProperty("Content-Type", CONTENT_TYPE);

            // hack for facebook
            if (!apiURL.equals("facebook/")) {
//                client.setRequestProperty("Accept-Language", ACCEPT_LANG);
                client.setRequestProperty("Accept-Type", CONTENT_TYPE);
                client.setRequestProperty("Authorization", "Token " + token);
            }


            // Send POST request
            client.setDoOutput(true);
            client.setDoInput(true);
            OutputStream outputStream = client.getOutputStream();
            OutputStreamWriter writer = new OutputStreamWriter(outputStream, "UTF-8");
            writer.write(payload);
            writer.flush();
            writer.close();
            outputStream.close();

            int responseCode = client.getResponseCode();
            Log.i("POSTing", Integer.toString(responseCode));

            InputStream input = client.getInputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(input));
            StringBuilder responseBuffer = new StringBuilder();
            String line;

            while((line = reader.readLine()) != null){
                responseBuffer.append(line);
            }

            Log.i("Response: ", responseBuffer.toString());

            boolean wasPosted = responseCode == 201;

            // hack for facebook
            if (apiURL.equals("facebook/"))
                wasPosted = responseCode >= 200 && responseCode < 300;
            return new Response(wasPosted, responseBuffer.toString(), responseCode);
        }
        catch (Exception e) {
            Log.e("Error ", e.getMessage(), e);
            return new Response(false, e.getMessage(), -1);
        }
    }

    public static void deleteRequest(String apiUrl, String token){
        try {
            URL url = new URL(API_BASE_URL + apiUrl);
            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setRequestProperty("Authorization", "Token " + token);
            urlConnection.setRequestMethod("DELETE");
            Log.i("GET response code", Integer.toString(urlConnection.getResponseCode()));
            urlConnection.disconnect();
        }
        catch (Exception e) {
            Log.e("Error ", e.getMessage(), e);
        }
    }
}
