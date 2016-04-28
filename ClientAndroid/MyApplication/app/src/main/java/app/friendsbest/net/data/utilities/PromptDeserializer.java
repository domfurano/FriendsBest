package app.friendsbest.net.data.utilities;

import com.google.gson.JsonArray;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import app.friendsbest.net.data.model.Friend;
import app.friendsbest.net.data.model.PromptCard;

public class PromptDeserializer implements JsonDeserializer<PromptCard> {
    @Override
    public PromptCard deserialize(JsonElement json, Type typeOfT,
                                  JsonDeserializationContext context) throws JsonParseException {

        JsonObject jsonObject = json.getAsJsonObject();
        PromptCard promptCard = new PromptCard();
        String tagString = jsonObject.get("tagstring").getAsString();
        List<String> tags = new ArrayList<>();
        JsonArray array = jsonObject.get("tags").getAsJsonArray();
        for(int i = 0; i < array.size(); i++) {
            tags.add(array.get(i).getAsString());
        }
        int id = jsonObject.get("id").getAsInt();
        boolean urgent = jsonObject.get("urgent").getAsBoolean();
        String article = jsonObject.get("article").getAsString();
        Friend friend = new Friend();
        try {
            friend.setName(jsonObject.get("friend").getAsJsonObject().get("name").getAsString());
            friend.setId(jsonObject.get("friend").getAsJsonObject().get("id").getAsString());
        }
        catch (ClassCastException e) {
            friend.setName("");
            friend.setId("");
        }
        catch (IllegalStateException e2) {
            friend.setName("");
            friend.setId("");
        }

        promptCard.setArticle(article);
        promptCard.setTags(tags);
        promptCard.setTagstring(tagString);
        promptCard.setFriend(friend);
        promptCard.setId(id);
        promptCard.setUrgent(urgent);
        return promptCard;
    }
}
