package app.friendsbest.net.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;

public class CardViewGroup extends ViewGroup {

    public CardViewGroup(Context context) {
        super(context);
    }

    public CardViewGroup(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public CardViewGroup(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        int childCount = getChildCount();

        int top = getPaddingTop();

        for(int i = 0; i < childCount; i++){
            View childView = getChildAt(i);

            Rect childRect = new Rect();
            childRect.left = getPaddingLeft();
            childRect.top = top;
            childRect.right = getWidth() - getPaddingRight();
            childRect.bottom = (getHeight() - getPaddingBottom()) / (childCount - i);
            childView.layout(childRect.left, childRect.top, childRect.right, childRect.bottom);
            top = childRect.bottom;
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec,heightMeasureSpec);
//        measureChildren(widthMeasureSpec, heightMeasureSpec);
//        int layoutHeight = getChildAt(0).getHeight();
//
//        int childSize = getChildCount();
//        for(int i = 0; i < childSize; i++){
//            View childView = getChildAt(i);
//            int size = childView.getMeasuredWidth() + childView.getMeasuredHeight();
//            int width = ViewGroup.resolveSize(size, widthMeasureSpec);
//            int height = ViewGroup.resolveSize(layoutHeight / 3, heightMeasureSpec);
//            setMeasuredDimension(width, height);
//        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
    }
}
