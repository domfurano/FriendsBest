package app.friendsbest.net.data.services;

import android.content.Context;
import android.util.DisplayMetrics;
import android.widget.ImageView;

import com.bumptech.glide.Glide;

import app.friendsbest.net.R;

public class ImageService {

    private static final String FACEBOOK_URL = "https://graph.facebook.com/";
    public static final int LARGE_PHOTO = 2;
    public static final int MEDIUM_PHOTO = 1;
    public static final int SMALL_PHOTO = 0;
    private static ImageService _imageService = null;
    private Context _context;

    public enum PictureSize {
        LARGE("large"),
        MEDIUM("normal"),
        SMALL("small");

        private String _sizeText;

        PictureSize(String sizeText) {
            _sizeText = sizeText;
        }
    }

    public static ImageService getInstance(Context activity){
        if (_imageService == null)
            _imageService = new ImageService(activity);
        return _imageService;
    }

    private ImageService(Context context){
        _context = context;
    }

    public void retrieveProfileImage(ImageView view, String id, PictureSize size) {
        String uri = FACEBOOK_URL + id + "/picture?type=" + size._sizeText;
        Glide.with(_context)
                .load(uri)
                .error(R.drawable.ic_account_vector)
                .transform(new CircleTransform(_context))
                .crossFade()
                .into(view);
    }

    public void retrieveImage(ImageView view, String uri, int width, int height){
        Glide.with(_context)
                .load(uri)
                .override(dipToPixel(width), dipToPixel(height))
                .transform(new CircleTransform(_context))
                .into(view);
    }

    public void clearImageCache() {
        Glide.get(_context).clearMemory();
    }

    private int dipToPixel(int measure) {
        DisplayMetrics metrics = _context.getResources().getDisplayMetrics();
        return Math.round(measure * (metrics.xdpi / DisplayMetrics.DENSITY_DEFAULT));
    }
}
