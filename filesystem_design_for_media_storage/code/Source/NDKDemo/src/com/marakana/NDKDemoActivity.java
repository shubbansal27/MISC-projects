package com.marakana;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class NDKDemoActivity extends Activity {
	NativeLib nativeLib;
/** Called when the activity is first created. */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);
     
    nativeLib = new NativeLib();
    final String s = Environment.getExternalStorageDirectory().getAbsolutePath();
    //String uspace = nativeLib.details(s);
    
    TextView used = (TextView) findViewById(R.id.textView5);
    //used.setText(uspace);
    
    TextView free = (TextView) findViewById(R.id.textView6);
    //free.setText(uspace);
    
    Button store = (Button) findViewById(R.id.button1);
    store.setOnClickListener(new View.OnClickListener() {
        public void onClick(View view) {
            Intent myIntent = new Intent(view.getContext(), storefile.class);
            startActivityForResult(myIntent, 0);
        }

    });
    
    Button delete = (Button) findViewById(R.id.button2);
    delete.setOnClickListener(new View.OnClickListener() {
        public void onClick(View view) {
            Intent myIntent = new Intent(view.getContext(), deletefile.class);
            startActivityForResult(myIntent, 0);
        }

    });
    
    Button read = (Button) findViewById(R.id.button3);
    read.setOnClickListener(new View.OnClickListener() {
        public void onClick(View view) {
            Intent myIntent = new Intent(view.getContext(), readfile.class);
            startActivityForResult(myIntent, 0);
        }

    });
    
    Button exit = (Button) findViewById(R.id.button4);
    exit.setOnClickListener(new View.OnClickListener() {
        public void onClick(View view) {
        	finish();
            System.exit(0);
        }

    });

    Button format = (Button) findViewById(R.id.button5);
    format.setOnClickListener(new View.OnClickListener() {
        public void onClick(View view) {
        	nativeLib.hello(s);
        	
        }

    });
    
    
   }
}