package app.friendsbest.net.ui.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

public class PromptView extends View {

    private final String _cardTitle = "Do you have a recommendation for";
    private String _tagsText;
    private String _authorText;
    private Paint _card;

    public PromptView(Context context) {
        super(context);
        init(context, null);
    }

    public PromptView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs){
        _card = new Paint();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        int viewWidth = getMeasuredWidth();
        int viewHeight = getMeasuredHeight();
        _card.setColor(Color.RED);
        _card.setAntiAlias(true);
        _card.setStyle(Paint.Style.FILL);
    }
}
