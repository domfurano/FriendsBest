package app.friendsbest.net;

import java.util.List;

public class QuerySolution {
    private int id;
    private List<String> tags;
    private List<Solution> solutions;
    private String title;

    public List<Solution> getSolutions(){
        return this.solutions;
    }
}

