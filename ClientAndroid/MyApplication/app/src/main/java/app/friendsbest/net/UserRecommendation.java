package app.friendsbest.net;

public class UserRecommendation {
    private String comment;
    private String name;

    public UserRecommendation(){}
    public UserRecommendation(String name, String comment){
        this.name = name;
        this.comment = comment;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
