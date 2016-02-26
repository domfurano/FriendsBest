package app.friendsbest.net;

import android.content.Context;
import android.content.res.Resources;
import android.util.AttributeSet;
import android.util.Log;
import android.util.TypedValue;
import android.widget.LinearLayout;
import android.widget.TextView;

public class CardLayout extends LinearLayout {

    private final String TITLE = "Do you have a recommendation for";
    private final String FRIEND_TEXT = "Based on a search by ";

    private TextView _cardTagText;
    private TextView _cardFriendText;

    public CardLayout(Context context) {
        super(context);
        init(context);
    }

    public CardLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    private void init(Context context){
    }

    private float convertDipToPixel(int dip) {
        Resources resources = getResources();
        return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dip, resources.getDisplayMetrics());
    }

    public void setCardTagText(String tagString) {
        _cardTagText.setText(tagString);
    }

    public void setCardFriendText(String friendName) {
        Log.i("Caller", "Set Card Text");
    }
}
