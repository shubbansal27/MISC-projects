package com.marakana;

import java.io.BufferedReader;
import java.io.FileReader;
import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class data extends Activity {
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.data);
        
        Bundle bundle = getIntent().getExtras();
        String filename = bundle.getString("file");
        String root = new String("/mnt/sdcard/storage/tmp/");
        String path = root.concat(filename);
        TextView header = (TextView) findViewById(R.id.textView1);
        header.setText(filename);
        
        String obj = new String("hello android");
        
        StringBuilder builder = new StringBuilder();
        BufferedReader reader = null;
        try 
        {
			reader = new BufferedReader(new FileReader(path));
			String line;
			while ((line = reader.readLine()) != null) 
				builder.append(line);
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		} 
        try {
			reader.close();
		} catch (Exception e) 
		{
			e.printStackTrace();
		}
		
		TextView datapart = (TextView) findViewById(R.id.textView3);
        datapart.setText(builder);
		
	}
}
