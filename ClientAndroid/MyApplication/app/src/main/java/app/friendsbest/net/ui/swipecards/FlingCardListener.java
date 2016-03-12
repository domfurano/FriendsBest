package app.friendsbest.net.ui.swipecards;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.graphics.PointF;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.OvershootInterpolator;

import app.friendsbest.net.ui.fragment.PromptFragment;

public class FlingCardListener implements View.OnTouchListener {

    private static final String TAG = FlingCardListener.class.getSimpleName();
    private static final int INVALID_POINTER_ID = -1;
    private final float _objectX;
    private final float _objectY;
    private final int _objectH;
    private final int _objectW;
    private final int _parentWidth;
    private final FlingListener _flingListener;
    private final Object _dataObject;
    private final float _halfWidth;
    private final int TOUCH_ABOVE = 0;
    private final int TOUCH_BELOW = 1;
    public ActionDownInterface _actionDownInterface;
    private float BASE_ROTATION_DEGREES;
    private float _aPosX;
    private float _aPosY;
    private float _aDownTouchX;
    private float _aDownTouchY;
    private int _invalidPointerId = INVALID_POINTER_ID;
    private View _frame = null;
    private int _touchPosition;
    private boolean _isAnimationRunning = false;
    private float MAX_COS = (float) Math.cos(Math.toRadians(45));

    public FlingCardListener(View frame, Object itemAtPosition, FlingListener flingListener) {
        this(frame, itemAtPosition, 15f, flingListener);

    }

    public FlingCardListener(View frame, Object itemAtPosition, float rotation_degrees, FlingListener flingListener) {
        super();

        this._frame = frame;
        this._objectX = frame.getX();
        this._objectY = frame.getY();
        this._objectH = frame.getHeight();
        this._objectW = frame.getWidth();
        this._halfWidth = _objectW / 2f;
        this._dataObject = itemAtPosition;
        this._parentWidth = ((ViewGroup) frame.getParent()).getWidth();
        this.BASE_ROTATION_DEGREES = rotation_degrees;
        this._flingListener = flingListener;

    }

    @Override
    public boolean onTouch(View view, MotionEvent event) {

        switch (event.getAction() & MotionEvent.ACTION_MASK) {
            case MotionEvent.ACTION_DOWN:

                // from http://android-developers.blogspot.com/2010/06/making-sense-of-multitouch.html
                // Save the ID of this pointer
                PromptFragment.removeBackground();


                _invalidPointerId = event.getPointerId(0);
                float x = 0;
                float y = 0;
                boolean success = false;
                try {
                    x = event.getX(_invalidPointerId);
                    y = event.getY(_invalidPointerId);
                    success = true;
                } catch (IllegalArgumentException e) {
                    Log.w(TAG, "Exception in onTouch(view, event) : " + _invalidPointerId, e);
                }
                if (success) {
                    // Remember where we started
                    _aDownTouchX = x;
                    _aDownTouchY = y;
                    //to prevent an initial jump of the magnifier, aposX and _aPosY must
                    //have the values from the magnifier _frame
                    if (_aPosX == 0) {
                        _aPosX = _frame.getX();
                    }
                    if (_aPosY == 0) {
                        _aPosY = _frame.getY();
                    }

                    if (y < _objectH / 2) {
                        _touchPosition = TOUCH_ABOVE;
                    } else {
                        _touchPosition = TOUCH_BELOW;
                    }
                }

                view.getParent().requestDisallowInterceptTouchEvent(true);
                break;

            case MotionEvent.ACTION_UP:
                _invalidPointerId = INVALID_POINTER_ID;
                resetCardViewOnStack();
                view.getParent().requestDisallowInterceptTouchEvent(false);
                break;

            case MotionEvent.ACTION_POINTER_DOWN:
                break;

            case MotionEvent.ACTION_POINTER_UP:
                // Extract the index of the pointer that left the touch sensor
                final int pointerIndex = (event.getAction() &
                        MotionEvent.ACTION_POINTER_INDEX_MASK) >> MotionEvent.ACTION_POINTER_INDEX_SHIFT;
                final int pointerId = event.getPointerId(pointerIndex);
                if (pointerId == _invalidPointerId) {
                    // This was our active pointer going up. Choose a new
                    // active pointer and adjust accordingly.
                    final int newPointerIndex = pointerIndex == 0 ? 1 : 0;
                    _invalidPointerId = event.getPointerId(newPointerIndex);
                }
                break;
            case MotionEvent.ACTION_MOVE:

                // Find the index of the active pointer and fetch its position
                final int pointerIndexMove = event.findPointerIndex(_invalidPointerId);
                final float xMove = event.getX(pointerIndexMove);
                final float yMove = event.getY(pointerIndexMove);

                //from http://android-developers.blogspot.com/2010/06/making-sense-of-multitouch.html
                // Calculate the distance moved
                final float dx = xMove - _aDownTouchX;
                final float dy = yMove - _aDownTouchY;


                // Move the _frame
                _aPosX += dx;
                _aPosY += dy;

                // calculate the rotation degrees
                float distobjectX = _aPosX - _objectX;
                float rotation = BASE_ROTATION_DEGREES * 2.f * distobjectX / _parentWidth;
                if (_touchPosition == TOUCH_BELOW) {
                    rotation = -rotation;
                }

                //in this area would be code for doing something with the view as the _frame moves.
                _frame.setX(_aPosX);
                _frame.setY(_aPosY);
                _frame.setRotation(rotation);
                _flingListener.onScroll(getScrollProgressPercent());
                break;

            case MotionEvent.ACTION_CANCEL: {
                _invalidPointerId = INVALID_POINTER_ID;
                view.getParent().requestDisallowInterceptTouchEvent(false);
                break;
            }
        }

        return true;
    }

    private float getScrollProgressPercent() {
        if (movedBeyondLeftBorder()) {
            return -1f;
        } else if (movedBeyondRightBorder()) {
            return 1f;
        } else {
            float zeroToOneValue = (_aPosX + _halfWidth - leftBorder()) / (rightBorder() - leftBorder());
            return zeroToOneValue * 2f - 1f;
        }
    }

    private boolean resetCardViewOnStack() {
        if (movedBeyondLeftBorder()) {
            // Left Swipe
            onSelected(true, getExitPoint(-_objectW), 100);
            _flingListener.onScroll(-1.0f);
        } else if (movedBeyondRightBorder()) {
            // Right Swipe
            onSelected(false, getExitPoint(_parentWidth), 100);
            _flingListener.onScroll(1.0f);
        } else {
            float abslMoveDistance = Math.abs(_aPosX - _objectX);
            _aPosX = 0;
            _aPosY = 0;
            _aDownTouchX = 0;
            _aDownTouchY = 0;
            _frame.animate()
                    .setDuration(200)
                    .setInterpolator(new OvershootInterpolator(1.5f))
                    .x(_objectX)
                    .y(_objectY)
                    .rotation(0);
            _flingListener.onScroll(0.0f);
            if (abslMoveDistance < 4.0) {
                _flingListener.onClick(_dataObject);
            }
        }
        return false;
    }

    private boolean movedBeyondLeftBorder() {
        return _aPosX + _halfWidth < leftBorder();
    }

    private boolean movedBeyondRightBorder() {
        return _aPosX + _halfWidth > rightBorder();
    }


    public float leftBorder() {
        return _parentWidth / 4.f;
    }

    public float rightBorder() {
        return 3 * _parentWidth / 4.f;
    }


    public void onSelected(final boolean isLeft,
                           float exitY, long duration) {

        _isAnimationRunning = true;
        float exitX;
        if (isLeft) {
            exitX = -_objectW - getRotationWidthOffset();
        } else {
            exitX = _parentWidth + getRotationWidthOffset();
        }

        this._frame.animate()
                .setDuration(duration)
                .setInterpolator(new AccelerateInterpolator())
                .x(exitX)
                .y(exitY)
                .setListener(new AnimatorListenerAdapter() {
                    @Override
                    public void onAnimationEnd(Animator animation) {
                        if (isLeft) {
                            _flingListener.onCardExited();
                            _flingListener.leftExit(_dataObject);
                        } else {
                            _flingListener.onCardExited();
                            _flingListener.rightExit(_dataObject);
                        }
                        _isAnimationRunning = false;
                    }
                })
                .rotation(getExitRotation(isLeft));
    }


    /**
     * Starts a default left exit animation.
     */
    public void selectLeft() {
        if (!_isAnimationRunning)
            onSelected(true, _objectY, 200);
    }

    /**
     * Starts a default right exit animation.
     */
    public void selectRight() {
        if (!_isAnimationRunning)
            onSelected(false, _objectY, 200);
    }


    private float getExitPoint(int exitXPoint) {
        float[] x = new float[2];
        x[0] = _objectX;
        x[1] = _aPosX;

        float[] y = new float[2];
        y[0] = _objectY;
        y[1] = _aPosY;

        LinearRegression regression = new LinearRegression(x, y);

        //Your typical y = ax+b linear regression
        return (float) regression.slope() * exitXPoint + (float) regression.intercept();
    }

    private float getExitRotation(boolean isLeft) {
        float rotation = BASE_ROTATION_DEGREES * 2.f * (_parentWidth - _objectX) / _parentWidth;
        if (_touchPosition == TOUCH_BELOW) {
            rotation = -rotation;
        }
        if (isLeft) {
            rotation = -rotation;
        }
        return rotation;
    }


    /**
     * When the object rotates it's width becomes bigger.
     * The maximum width is at 45 degrees.
     * <p/>
     * The below method calculates the width offset of the rotation.
     */
    private float getRotationWidthOffset() {
        return _objectW / MAX_COS - _objectW;
    }


    public void setRotationDegrees(float degrees) {
        this.BASE_ROTATION_DEGREES = degrees;
    }

    public boolean isTouching() {
        return this._invalidPointerId != INVALID_POINTER_ID;
    }

    public PointF getLastPoint() {
        return new PointF(this._aPosX, this._aPosY);
    }

    protected interface FlingListener {
        void onCardExited();

        void leftExit(Object dataObject);

        void rightExit(Object dataObject);

        void onClick(Object dataObject);

        void onScroll(float scrollProgressPercent);
    }

    public interface ActionDownInterface {
        void onActionDownPerform();
    }
}
