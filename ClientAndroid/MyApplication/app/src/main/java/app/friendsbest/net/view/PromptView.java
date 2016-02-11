package app.friendsbest.net.view;

import android.content.Context;
import android.graphics.PointF;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import app.friendsbest.net.model.Prompt;

public class PromptView extends ViewGroup {

    private Prompt _prompt;

    public PromptView(Context context) {
        super(context);
    }

    public PromptView(Context context, Prompt prompt){
        super(context);
        _prompt = prompt;
    }

    @Override
    public boolean onTouchEvent(MotionEvent event){
        PointF pointF = new PointF();
        View view = getChildCount() == 0 ? null : getChildAt(0);
        if (view != null){

        }
        return true;
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {

    }
}
