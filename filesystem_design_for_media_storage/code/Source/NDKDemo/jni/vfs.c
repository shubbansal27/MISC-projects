#include "vfs.h"
#include<stdio.h>
#include<string.h>
#include<stdlib.h>

#define n 4096    // block size in bytes


int prevBlock;
int flag;
int file_size;
char fullPath[100];


JNIEXPORT jstring JNICALL Java_com_marakana_NativeLib_hello
  (JNIEnv * env, jobject obj,jstring path) {
		
		const char *appPath = (*env)->GetStringUTFChars(env, path, 0);
		sprintf(fullPath,"%s/storage",appPath);
		
		//initialise_free();
		
		
		return (*env)->NewStringUTF(env,"done");
			
}

JNIEXPORT jstring JNICALL Java_com_marakana_NativeLib_saveFile
  (JNIEnv * env, jobject obj,jstring path,jstring src,jstring filename) {
		
		const char *appPath = (*env)->GetStringUTFChars(env, path, 0);
		sprintf(fullPath,"%s/storage",appPath);
		
		const char *source = (*env)->GetStringUTFChars(env, src, 0);
		
		const char *file = (*env)->GetStringUTFChars(env, filename, 0);
		
		if(!checkFileExist(file))
			return (*env)->NewStringUTF(env,"file already exists !!!");
		else
		{
			FILE *fs;
			if((fs = fopen(source,"r")) == NULL)
				return (*env)->NewStringUTF(env,"Error: reading source file !!!");
            while(storeFile(fs) != -1) ;		
			writeToFAT(file,flag,file_size);							
			fclose(fs);
		}	
		return (*env)->NewStringUTF(env,"file successfully written to disk !!!");
}

JNIEXPORT jstring JNICALL Java_com_marakana_NativeLib_readFile
  (JNIEnv * env, jobject obj,jstring path,jstring filename) {
		
		const char *appPath = (*env)->GetStringUTFChars(env, path, 0);
		sprintf(fullPath,"%s/storage",appPath);
		
		const char *file = (*env)->GetStringUTFChars(env, filename, 0);

		FILE *p = fopen("/mnt/sdcard/tmp/test.txt","w");
		fputc('s',p);  fputc('h',p); fputc('u',p); fputc('b',p);  fputc('h',p);  fputc('a',p); fputc('m',p); 	
		fclose(p);
		
		if(!readFileByName(file))
			return (*env)->NewStringUTF(env,"File not found !!");
		else	
			return (*env)->NewStringUTF(env,"Done");
}

//----------------------------------------------------FILE SYSTEM FUNCTIONS- LIBRARY IMPLEMENTATION-----------------------------------------------------------

//--------------------------------------------------------disk storage level implementation-------------------------------------------------------------------


int writeBlock(int blockNum,char *buff,int offset,int length)
{
	char path[50];
	sprintf(path,"%s/disk.vs",fullPath);
	int pos = (blockNum-1)*4096 + offset;
	int count;
	FILE *fs = fopen(path,"r+");																		//disk.vs
	fseek(fs,pos,SEEK_SET);
		
	count = 0;
	
	while(count != length)
	{
		putc(buff[count],fs);
		count ++ ;
	}

	fclose(fs);
        return 1;
}

int readBlock(int blockNum,int offset,int length,char *filename)
{
    char path[50],tmpPath[70];
	sprintf(path,"%s/disk.vs",fullPath);
	sprintf(tmpPath,"%s/tmp/%s",fullPath,filename);
	int pos = (blockNum-1)*4096 + offset;														//disk.vs
	char c;
	int count;
	FILE *fs = fopen(path,"r+");
	FILE *ts = fopen(tmpPath,"a");
	fseek(fs,pos,SEEK_SET);
	
	count = 0;
	while(count != length)
	{
		c = getc(fs);
		putc(c,ts);
		count ++ ;
	}
	
	fclose(fs);
    fclose(ts); 
	return 1;
}

int readNextBlockNo(int blockNum)
{
    char path[50];
	sprintf(path,"%s/disk.vs",fullPath);
	int pos = (blockNum-1)*4096;												//disk.vs
	FILE *fs = fopen(path,"r+");
	int next;
	fseek(fs,pos,SEEK_SET);
	fscanf(fs,"%d",&next);
    fclose(fs);

	return next;
}



//--------------------------------------------------------------allocation Level Implementation-------------------------------------------------------

int writeToFAT(char *file, int blockNo, int size)
{
	char path[50];
	sprintf(path,"%s/allocation.txt",fullPath);
	FILE *p= fopen(path, "a");												//allocation.txt
	fprintf(p,"%s %d %d\n", file, blockNo, size);
    fclose(p);	
	
	return 1;
}


int search_free()
{
	char path[50];
	sprintf(path,"%s/free.txt",fullPath);
	int i=0, x=0;
	FILE *p;
	char c;
 
 	p=fopen(path,"rb+");													//free.txt
        while((c=fgetc(p)) != EOF)
	{  
                 x++;
		if(c=='1')							//1=free 0=used
                  { 
    		   fseek(p,i,SEEK_SET);	
                   fputc('0',p);
		    break;
		}
               i=ftell(p);
	}
        
	fclose(p);
	return x;                 
}

void initialise_free()
{
    char path[50];
	sprintf(path,"%s/free.txt",fullPath);
	FILE *q = fopen(path,"w");							//free.txt
	int i=1;
    while(i!=n)
    {
		fprintf(q,"1");
        i++;
	 }
        fclose(q);        
}


int storeFile(FILE *fs)
{
    int count,i;
	char buff[4090],t[6];
	char c;
	
	count = 0;
	
	while(count != 4090)
	{
		c = getc(fs);
		if(c == EOF) break;
	
		buff[count] = c;
		count ++ ;
	}

	i=search_free();

	if(flag == 0)  flag = i;

	sprintf(t,"%05d ",0);
	writeBlock(i,t,0,6);
	writeBlock(i,buff,6,4090);

	if(prevBlock != 0)  
	{
		sprintf(t,"%05d ",i);		
		writeBlock(prevBlock,t,0,6);	
	}

	prevBlock = i;

	file_size = file_size + count ;

	if(feof(fs)) return -1;      
	return count;
	
}

//--------------------------------------------------------------------User-level implementation----------------------------------------------------------------

int checkFileExist(char *filename)
{
	char path[50];
	sprintf(path,"%s/allocation.txt",fullPath);
	FILE *p= fopen(path, "r");							//allocation.txt
	char temp[50];
	int t;
	
	while(!feof(p))
	{
		fscanf(p,"%s",temp);
		fscanf(p,"%d",&t);
		fscanf(p,"%d",&t);
	
		if(strcmp(temp,filename)==0)
		{
			fclose(p);			
			return 0;
		}

	}

	

	fclose(p);		
	return 1;
}

int readFileByName(char *filename)
{
	char path[50],tmpPath[70];
	sprintf(path,"%s/allocation.txt",fullPath);
	sprintf(tmpPath,"%s/tmp/%s",fullPath,filename);
	FILE *p= fopen(path, "r");						//allocation.txt
	char temp[50];
	int inode,size,found=0;	

	while(!feof(p))
	{
		fscanf(p,"%s",temp);
		fscanf(p,"%d",&inode);
		fscanf(p,"%d",&size);
			
		if(strcmp(temp,filename)==0)
		{
			FILE *ts= fopen(tmpPath, "w");
			fclose(ts);
			readFileByInode(inode, size,filename);
			found=1;
			fclose(p);	
			break;
		}

	}

	if(found==0)   return 0;

	return 1;
}

int readFileByInode(int inode,int size,char *filename)
{
	int tmp = inode;
	int t = size;
	int length;
	while(1)
	{
		if(t > 4090) length = 4090;
		else length = t;
				
		readBlock(tmp,6,length,filename);
		tmp=readNextBlockNo(tmp);
		if(tmp==0)	break;
		
		t = t-4090;				
	}

}
	

int deleteFileByName(char *filename)
{
	char path[50];
	sprintf(path,"%s/allocation.txt",fullPath);	
	FILE *p= fopen(path, "r");											//allocation.txt
	char temp[50];
	int inode,size,found=0;	

	while(!feof(p))
	{
		fscanf(p,"%s",temp);
		fscanf(p,"%d",&inode);
		fscanf(p,"%d",&size);
			
		if(strcmp(temp,filename)==0)
		{
			deleteFileByInode(inode,filename);
			found=1;
			break;
		}

	}

	if(found==0)	printf("\nFILE NOT FOUND...!!!\n");

	fclose(p);		
	return 1;

}

int deleteFileByInode(int inode,char *filename)
{    	
	int k=inode;
	int i, x;
	FILE *p;
	char c;
	char path[50];
	sprintf(path,"%s/free.txt",fullPath);
	
	while(k != 0)
    {
		p=fopen(path,"rb+");					//free.txt
		i=0;
		x=0;
        while((c=fgetc(p)) != EOF)
		{  
            x++;
			if(x==k)				
            { 
				fseek(p,i,SEEK_SET);	
				fputc('1',p);
				break;
			}
            i=ftell(p);
		}
        fclose(p);  
		k=readNextBlockNo(k);
        } 

		 
     
}



