#include<stdio.h>
#include<stdlib.h>
#include <stdio.h>

#define n 4096    // block size in bytes


int prevBlock;
int flag;
int file_size;

//-------------------------------------------------------------disk storage level implementation--------------------------------------------------------


int writeBlock(int blockNum,char *buff,int offset,int length)
{
	int pos = (blockNum-1)*4096 + offset;
	int count;
	FILE *fs = fopen("./storage/disk.vs","r+");
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

int readBlock(int blockNum,int offset,int length)
{
        int pos = (blockNum-1)*4096 + offset;
	char c;
	int count;
	FILE *fs = fopen("./storage/disk.vs","r+");
	fseek(fs,pos,SEEK_SET);
	
	count = 0;
	while(count != length)
	{
		c = getc(fs);
		printf("%c",c);
		count ++ ;
	}
	
	fclose(fs);

	return 1;
}

int readNextBlockNo(int blockNum)
{
        int pos = (blockNum-1)*4096;
	FILE *fs = fopen("./storage/disk.vs","r+");
	int next;
	fseek(fs,pos,SEEK_SET);
	fscanf(fs,"%d",&next);
        fclose(fs);

	return next;
}



//--------------------------------------------------------------allocation Level Implementation-------------------------------------------------------

int writeToFAT(char *path, int blockNo, int size)
{
	FILE *p= fopen("./storage/allocation.txt", "a");
	fprintf(p,"%s %d %d\n", path, blockNo, size);
       	fclose(p);	
	
	return 1;
}


int search_free()
{
	int i=0, x=0;
	FILE *p;
	char c;
 
 	p=fopen("./storage/free.txt","rb+");
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
	 FILE *q = fopen("./storage/free.txt","w");
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
	FILE *p= fopen("./storage/allocation.txt", "r");
	char temp[50];
	int t;
	
	while(!feof(p))
	{
		fscanf(p,"%s",temp);
		fscanf(p,"%d",&t);
		fscanf(p,"%d",&t);
	
		if(strcmp(temp,filename)==0)
		{
			printf("\nFile with the similar name exists...!!! \n\n");
			fclose(p);			
			return 0;
		}

	}

	

	fclose(p);		
	return 1;
}



int readFileByName(char *filename)
{
	FILE *p= fopen("./storage/allocation.txt", "r");
	char temp[50];
	int inode,size,found=0;	

	while(!feof(p))
	{
		fscanf(p,"%s",temp);
		fscanf(p,"%d",&inode);
		fscanf(p,"%d",&size);
			
		if(strcmp(temp,filename)==0)
		{
			readFileByInode(inode, size);
			found=1;
			break;
		}

	}

	if(found==0)	printf("\nFILE NOT FOUND...!!!\n");

	fclose(p);		
	return 1;
}

int readFileByInode(int inode,int size)
{
	int tmp = inode;
	int t = size;
	int length;
	while(1)
	{
		if(t > 4090) length = 4090;
		else length = t;
				
		readBlock(tmp,6,length);
		tmp=readNextBlockNo(tmp);
		if(tmp==0)	break;
		
		t = t-4090;				
	}

}
	

int deleteFileByName(char *filename)
{
	FILE *p= fopen("./storage/allocation.txt", "r");
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
	
	while(k != 0)
        {
		p=fopen("./storage/free.txt","rb+");
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


int checkDiskSpace()
{
	int free=0, used=0,total=0;
	FILE *p;
	char c;
 
 	p=fopen("./storage/free.txt","rb+");
        while((c=fgetc(p)) != EOF)
	{
                if(c=='1')		free++;
    		else			used++;
	}
        
	free=free*4096;	
	used=used*4096;
	total=free+used;
	
	printf("\nDisk Size: %d bytes \nUsed Space: %d bytes\nFree Space: %d bytes\n ",free,used,total);

	fclose(p);
	return 1;        
}


//----------------------------------------------------------------------------Main-------------------------------------------------------------------------------------

int main()
{
	int choice,inode;
	char path[50],name[50],file[50];
	
      /*initialise_free(); */					//for initialising free block list

	
	printf("\n");
	do
	{
		printf("Operations menu:\n");
		printf("1. Store a file\n");
		printf("2. Delete a file\n");
		printf("3. Read a file\n");
		printf("4. detail\n");
		printf("5. Exit.\n");
		printf("Enter your choice..: ");
		scanf("%d",&choice);
		switch(choice)
		{

			case 1 	:  	prevBlock = 0;
					flag = 0;
					file_size = 0;
					printf("\nEnter the source file path:  ");
					scanf("%s",path);
					printf("\nEnter name of file:  ");
					scanf("%s",name);
					
					if(checkFileExist(name))
					{
 						FILE *fs = fopen(path,"r");
                                        
						while(storeFile(fs) != -1) ;		
						
						writeToFAT(name,flag,file_size);							
	
						fclose(fs);
						printf("\nsuccessfully written in disk...\n\n");                            	
					}			
					break;
			 
			case 2 	:	printf("\nFile name:  ");
					scanf("%s", file);
					deleteFileByName(file);		
					printf("\n");
					break;
			
			case 3 	:	printf("\nFile name:  ");
					scanf("%s", file);
					readFileByName(file);		
					
					
					break;
			
			case 4	:	checkDiskSpace();	
					printf("\n");
					break;

			default :	printf("Please enter a valid choice !!!\n\n");
					break;
		}
	}
	while (choice != 5);
}
