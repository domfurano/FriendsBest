package app.friendsbest.net;

import java.util.ArrayList;

public class Solution {
    private ArrayList<UserRecommendation> recommendation;
    private String name;

    @Override
    public String toString(){
        String[] nameParts = this.name.split("\r\n");
        return nameParts[0];
    }
    public String getName(){
        return this.name;
    }

    public ArrayList<UserRecommendation> getRecommendations(){
        return this.recommendation;
    }
}
