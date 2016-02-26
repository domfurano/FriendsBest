package app.friendsbest.net.swipecards;

public class Data {
    String friend;
    String tagString;

    public Data(String tagString, String friend){
        this.friend = friend;
        this.tagString = tagString;
    }

    public String getFriend(){
        return friend;
    }

    public String getTagString(){
        return tagString;
    }
}
