package com.marakana;

import java.io.BufferedReader;
import java.io.FileReader;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

public class readfile extends Activity {
	NativeLib nativeLib;
	@Override
	public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.read);
        
        final String s = Environment.getExternalStorageDirectory().getAbsolutePath();
        nativeLib = new NativeLib();
        
        final EditText filename = (EditText) findViewById(R.id.editText1);
        filename.setText("");
        
        Button open = (Button) findViewById(R.id.button1);
        open.setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {
            	String t = filename.getText().toString();
            	String helloText = nativeLib.readFile(s,t);
            	TextView msg = (TextView) findViewById(R.id.textView2);
            	
            	if(helloText.equals("Done"))
            	{
            		msg.setText("Opening file ...");
            		Intent myIntent = new Intent(view.getContext(), imageData.class);
            		Bundle pass = new Bundle();
            		pass.putString("file",t);
            		myIntent.putExtras(pass);
                    startActivityForResult(myIntent, 0);
            	}
            	else
            		msg.setText(helloText);
            	
            }

        });
        
  
        Button back = (Button) findViewById(R.id.button2);
        back.setOnClickListener(new View.OnClickListener() {
        	public void onClick(View view) {
                Intent myIntent = new Intent(view.getContext(),NDKDemoActivity.class);
                startActivityForResult(myIntent, 0);
            }

        });
        
         
        String root = new String("/mnt/sdcard/storage/allocation.txt");
        String[] temp;
        String delimiter = " ";
        StringBuilder builder = new StringBuilder();
        BufferedReader reader = null;
        try 
        {
			reader = new BufferedReader(new FileReader(root));
			String line;
			while ((line = reader.readLine()) != null)
			{
				temp = line.split(delimiter);
				line = temp[0];
				line+='\n' ;	
				builder.append(line);
			}
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
