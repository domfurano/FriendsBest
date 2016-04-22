package app.friendsbest.net.data.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.Comparator;

public class RecommendationItem implements Comparator {

    @SerializedName("comment")
    @Expose
    private String _comment;

    @SerializedName("user")
    @Expose
    private User _user;

    @SerializedName("isNew")
    @Expose
    private boolean _isNew;

    @SerializedName("id")
    @Expose
    private int _id;

    public String getComment() {
        return _comment;
    }

    public void setComment(String comment) {
        _comment = comment;
    }

    public User getUser() {
        return _user;
    }

    public void setUser(User user) {
        _user = user;
    }

    public boolean isNew() {
        return _isNew;
    }

    public void setIsNew(boolean isNew) {
        _isNew = isNew;
    }

    public int getId() {
        return _id;
    }

    public void setId(int id) {
        _id = id;
    }

    @Override
    public int compare(Object lhs, Object rhs) {
        RecommendationItem leftHand = (RecommendationItem) lhs;
        RecommendationItem rightHand = (RecommendationItem) lhs;

        if (leftHand.isNew() && !rightHand.isNew()) {
            return 1;
        }
        else if (!leftHand.isNew() && rightHand.isNew()) {
            return -1;
        }
        else {
            User leftUser = leftHand.getUser();
            User rightUser = rightHand.getUser();

            if (leftHand != null && rightHand != null) {
                return leftUser.getName().compareTo(rightUser.getName());
            }
            else if (leftHand != null) {
                return 1;
            }
            else if (rightHand != null) {
                return -1;
            }
            else {
                return leftHand.getComment().compareTo(rightHand.getComment());
            }
        }
    }
}
