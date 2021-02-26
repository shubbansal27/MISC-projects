package com.marakana;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

public class storefile extends Activity {
	
	NativeLib nativeLib;
	@Override
	public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.store);

        final String s = Environment.getExternalStorageDirectory().getAbsolutePath();
        
        nativeLib = new NativeLib();
        
        
        // Update the UI
        final EditText source = (EditText) findViewById(R.id.editText1);
        source.setText("");
        
        final EditText filename = (EditText) findViewById(R.id.editText2);
        filename.setText("");
        
        Button save = (Button) findViewById(R.id.button1);
        save.setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {
            	String t = filename.getText().toString();
            	String src = source.getText().toString();
            	String helloText = nativeLib.saveFile(s,src,t);
            	
            	TextView msg = (TextView) findViewById(R.id.textView3);
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
        
         }

}
