package com.marakana;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.widget.ImageView;


public class imageData extends Activity {
	@Override
	public void onCreate(Bundle savedInstanceState) {
	    super.onCreate(savedInstanceState);
	    setContentView(R.layout.image);
	    
	    Bundle bundle = getIntent().getExtras();
        String filename = bundle.getString("file");
        String root = new String("/mnt/sdcard/storage/tmp/");
        String path = root.concat(filename);
	     
	    ImageView myImage = (ImageView) findViewById(R.id.imageView1);
	    Bitmap bmImg = BitmapFactory.decodeFile(path);
	    myImage.setImageBitmap(bmImg);
	
}
}