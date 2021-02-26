#include <jni.h>
#include<stdio.h>

#ifndef _Included_com_marakana_NativeLib
#define _Included_com_marakana_NativeLib
#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT jstring JNICALL Java_com_marakana_NativeLib_details(JNIEnv *, jobject, jstring);
JNIEXPORT jstring JNICALL Java_com_marakana_NativeLib_hello(JNIEnv *, jobject, jstring);
JNIEXPORT jstring JNICALL Java_com_marakana_NativeLib_saveFile(JNIEnv *, jobject,jstring,jstring,jstring);
JNIEXPORT jstring JNICALL Java_com_marakana_NativeLib_readFile(JNIEnv *, jobject, jstring,jstring);

//-----------------------------------------Storage-level-------------------------------------------------------------------------------------------

int writeBlock(int,char *,int,int);
int readBlock(int,int,int,char *);
int readNextBlockNo(int);

//----------------------------------------allocation-level----------------------------------------------------------------------------------------

int writeToFAT(char *, int, int);
int search_free();
void initialise_free();
int storeFile(FILE *);

//----------------------------------------user-level-----------------------------------------------------------------------------------

int checkFileExist(char *);
int readFileByName(char *);
int readFileByInode(int,int,char *);
int deleteFileByName(char *);
int deleteFileByInode(int inode,char *);
 
#ifdef __cplusplus
}
#endif
#endif
