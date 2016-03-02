package app.friendsbest.net.data.services;

import android.content.Context;
import android.graphics.Typeface;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.HashMap;

public class FontManager {
    public static final String ROOT = "fonts/";
    public static final String FONT_AWESOME = ROOT + "fontawesome-webfont.ttf";
    private static HashMap<String, Typeface>  _fontCache = new HashMap<>();

    public static Typeface getTypeface(Context context, String font) {
        Typeface typeface = _fontCache.get(font);
        if (typeface == null) {
            try {
                typeface = Typeface.createFromAsset(context.getAssets(), font);
            }
            catch (RuntimeException e) {
                Log.e("Typeface Error", e.getMessage(), e);
                return null;
            }

            _fontCache.put(font, typeface);
        }
        return typeface;
    }

    public static void markAsIconContainer(View v, Typeface typeface) {
        if (v instanceof ViewGroup) {
            ViewGroup vg = (ViewGroup) v;
            for (int i = 0; i < vg.getChildCount(); i++) {
                View child = vg.getChildAt(i);
                markAsIconContainer(child, typeface);
            }
        } else if (v instanceof TextView) {
            ((TextView) v).setTypeface(typeface);
        }
    }
}
