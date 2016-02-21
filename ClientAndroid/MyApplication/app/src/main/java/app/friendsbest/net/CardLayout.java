package app.friendsbest.net;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class CardLayout extends RelativeLayout {

    private View rootView;
    private TextView _cardTitleText;
    private TextView _tagTitleText;
    private TextView _authorTitleText;

    public CardLayout(Context context) {
        super(context);
        init(context);
    }

    public CardLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    private void init(Context context){
        // TODO: Implement

    }
}
