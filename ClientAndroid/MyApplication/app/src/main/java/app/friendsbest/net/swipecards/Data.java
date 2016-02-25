package app.friendsbest.net.swipecards;

public class Data {
    String description;
    String imagePath;

    public Data(String imagePath, String description){
        this.description = description;
        this.imagePath = imagePath;
    }

    public String getDescription(){
        return description;
    }

    public String getImagePath(){
        return imagePath;
    }
}
