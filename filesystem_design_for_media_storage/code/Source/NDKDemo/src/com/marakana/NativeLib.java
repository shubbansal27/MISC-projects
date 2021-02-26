package com.marakana;

public class NativeLib {

  static {
    System.loadLibrary("ndk_demo");
  }
  
  public native String hello(String s);
  public native String details(String s);
  public native String saveFile(String s,String src,String t);
  public native String readFile(String s,String t);
}