#include<stdio.h>
#include<stdlib.h>
#include <stdio.h>

#define n 524288    // block size in bytes


int prevBlock;
int flag;
int file_size;
int m=4096;
int p=1;
int k;

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

int noOfBlock(int blockNum)
{
	int pos = (blockNum-1)*4096+7;
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
	int count,i,j,l=1;
	char buff[4082],t[14];
	char c;
	count = 0;
	i=search_free();
        if(i==prevBlock+1 && i!=1)
	{
		m=4096;
		p++;
	}
	else 
	{
		if(p!=1)
		{		
			sprintf(t,"%06d ",i);		
			writeBlock(k,t,0,7);	
			sprintf(t,"%06d ",p);	
			writeBlock(k,t,7,7);
		}
		m=4082; k=i; p=1;
	}
	while(count != m)
	{
		c = getc(fs);
		if(c == EOF) break;
	
		buff[count] = c;
		count++ ;
	}

	if(flag==0)  flag = i;
	if(k==i)
		writeBlock(i,buff,14,m);
	else
		writeBlock(i,buff,0,m);
	
	prevBlock = i;
	file_size = file_size + count ;
	
	if(feof(fs)) 
		{
			sprintf(t,"%06d ",0);		
			writeBlock(k,t,0,7);	
			sprintf(t,"%06d ",p);	
			writeBlock(k,t,7,7);
			return -1;
		}	
	else return count;
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
	if(inode!=-1)
	{
		int tmp = inode,k,i;
		int t = size;
		int length;
		if(t > 4082) length = 4082;
		else length = t;			
		readBlock(tmp,14,length);
		t = t-4082;	
		while(1)
		{
		k=noOfBlock(tmp);
		
		for(i=1;i<k;i++)
		{
			if(t > 4096) length = 4096;
			else length = t;
					
			readBlock(tmp+i,0,length);
			t = t-4096;			
		}
		tmp=readNextBlockNo(tmp);
		if(tmp==0)	break;
	
		if(t > 4082) length = 4082;
		else length = t;
		readBlock(tmp,14,length);
		}
	}
	else
        	printf("No such file exists");
}
	

int deleteFileByName(char *filename)
{
	FILE *p,*q;
	p = fopen("./storage/allocation.txt","r");
	q =fopen("./storage/temp.txt","w");
	char temp[50];
	int inode,size,found=0;	

	while(!feof(p))
	{
		fscanf(p,"%s",temp);
		fscanf(p,"%d",&inode);	
		fscanf(p,"%d",&size);
		
		if(strcmp(temp,filename)==0)
		{
								
			deleteFileByInode(inode);
			found=1;
			
		}
		else if(strcmp(temp,filename)!=0)
                {	
			fprintf(q,"%s ",temp);
			fprintf(q,"%d ",inode);		
			fprintf(q,"%d\n",size);
		}
	}

	if(found==0)	printf("\nFILE NOT FOUND...!!!\n");
	fclose(p);
	fclose(q);
	/*p= fopen("./storage/allocation.txt","w");
	q=fopen("./storage/temp.txt","r");
	while(!feof(q))
	{		
			fscanf(q,"%s",temp);
			fscanf(q,"%d",&inode);	
			fscanf(q,"%d",&size);				
			fprintf(p,"%s ",temp);
			fprintf(p,"%d ",inode);		
			fprintf(p,"%d\n",size);
	}
	fclose(p);
	fclose(q);*/
	return 1;

}

int deleteFileByInode(int inode)
{    	
	int k=inode;
	int i, x,a,b;
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
		b=noOfBlock(k);  
		
	
		for(a=1;a<b;a++)
		{
			p=fopen("./storage/free.txt","rb+");
			i=0;
			x=0;
         		while((c=fgetc(p)) != EOF)
			{  
                		x++;
				if(x==(k+a))				
        	        	{ 
    				   fseek(p,i,SEEK_SET);	
                		   fputc('1',p);
				   	break;
				}
               			i=ftell(p);
			}
        
		fclose(p);  
        } 
	k=readNextBlockNo(k);
	}
	printf("\n\nSuccessfully deleted");
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
		printf("\n\nOperations menu:\n");
		printf("1. Store a file\n");
		printf("2. Delete a file\n");
		printf("3. Read a file\n");
		printf("4. Exit.\n");
		printf("Enter your choice..: ");
		scanf("%d",&choice);
		switch(choice) 
		{

			case 1 	:  	prevBlock = 0;
					flag = 0;
					file_size = 0;
					p = 1;
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
					printf("\n");
					break;
			
			case 4	:	break;

			default :	printf("Please enter a valid choice !!!\n\n");
					break;
		}
	}
	while (choice != 4);
}
