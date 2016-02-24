package app.friendsbest.net.ui.view;

import app.friendsbest.net.data.model.Solution;
import app.friendsbest.net.data.model.UserRecommendation;

public interface SolutionView {
    void displaySolutions(Solution solution);
    void displayRecommendation(UserRecommendation recommendation);
}
