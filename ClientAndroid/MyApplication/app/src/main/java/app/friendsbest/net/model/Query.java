package app.friendsbest.net.model;

import java.util.List;

public class Query {
    public void setId(int id) {
        this.id = id;
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    private int id;
    private List<String> tags;
    private String timestamp;

    public int getId() {
        return this.id;
    }

    @Override
    public String toString(){
        StringBuilder builder = new StringBuilder();
        for(String tag : tags){
            builder.append(tag).append(" ");
        }
        return builder.toString();
    }
}
