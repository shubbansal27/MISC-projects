#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<pthread.h>

int totalBlocks;
int prevBlock;
int flag;
int file_size;
int m;
int contig = 0;

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

int readBlock(int blockNum,int offset,int length,FILE *rf)
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
		putc(c,rf);
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

int readContigNo(int blockNum)
{
        int pos = (blockNum-1)*4096;
	FILE *fs = fopen("./storage/disk.vs","r+");
	int next;
	fseek(fs,pos,SEEK_SET);
	fscanf(fs,"%d",&next);
	fscanf(fs,"%d",&next);
        fclose(fs);

	return next;
}

int freeBlocks()
{
	int x=0;
	FILE *p;
	char c;
 
 	p=fopen("./storage/free.txt","rb+");
        while((c=fgetc(p)) != EOF)
	{  
		if(c=='1')							//1=free 0=used
                   x++;
                
	}
        
	fclose(p);
	return x;                 
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
	 FILE *p = fopen("./storage/allocation.txt","w");
         int i=1;
         while(i!=totalBlocks)
         {
		fprintf(q,"1");
                i++;
	 }
        fclose(q);
	fclose(p);	        
}


int storeFile(FILE *fs)
{
	
        int count,i,length,chk;
	char buff[4096],t[6];
	char c;
	
	count = 0;
	
	if((i=search_free()) == prevBlock+1  && prevBlock !=0) 
	{
		length = 4096;
		chk = 1;
		contig++;	
	}
	else 
	{
		length = 4084;
		chk = 0;
	} 

	while(count != length)
	{
		c = getc(fs);
		if(feof(fs)) break;
	
		buff[count] = c;
		count ++ ;
	}

	

	if(flag == 0)  flag = i;   

	if(chk == 0)
	{
		sprintf(t,"%05d ",0);
		writeBlock(i,t,0,6);
		sprintf(t,"%05d ",0);
		writeBlock(i,t,6,6);
		writeBlock(i,buff,12,4084);
		if(m != 0)
		{
			sprintf(t,"%05d ",i);   
			writeBlock(m,t,0,6);
			sprintf(t,"%05d ",contig);
			writeBlock(m,t,6,6);
		}
		m = i;	
	}
	else
		writeBlock(i,buff,0,4096);


	prevBlock = i;

	file_size = file_size + count ;

	if(feof(fs)) 
	{
		sprintf(t,"%05d ",contig);
		writeBlock(m,t,6,6);		
		return -1;
	}      
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

int readFileByInode(int inode,int size,char *filename)
{	
	int tmp = inode;
	int t = size;
	int length;
	int num,j;
	char buff[75];
	sprintf(buff,"./storage/buffer/%s",filename);
	FILE *rf = fopen(buff,"w");

	while(1)
	{
		if(t >= 4084)		
			length = 4084;
		else
			length = t;
 
		readBlock(tmp,12,length,rf);
		t = t-4084;
		num = readContigNo(tmp);							
		
		for(j=1;j<=num;j++)
		{
			if(t >= 4096)
			length = 4096;
			else
			length = t;

			readBlock(tmp+j,0,length,rf);
			t = t-4096;
		}
		tmp=readNextBlockNo(tmp);       						
		
		if(tmp==0)	break;
		
	}
	fclose(rf);

}


int readFileByName(char *filename)
{
	FILE *p= fopen("./storage/allocation.txt", "r");
	char temp[50];
	int inode,size,found=0;	
 	char buff[75];
	
	while(!feof(p))
	{
		fscanf(p,"%s",temp);
		fscanf(p,"%d",&inode);
		fscanf(p,"%d",&size);
			
		if(strcmp(temp,filename)==0)
		{
			readFileByInode(inode, size,filename);
			found=1;
			break;
		}

	}

	if(found==0)	printf("\nFILE NOT FOUND...!!!\n");

	fclose(p);		
	return 1;
}

void deleteBlk(int k)
{
	FILE *p=fopen("./storage/free.txt","rb+");
	int i=0;
	int x=0;
	char c;
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
}



int deleteFileByInode(int inode)
{    	
	int tmp = inode;
	int num,j;
	while(1)
	{

		deleteBlk(tmp);		
		num = readContigNo(tmp);							
		
		for(j=1;j<=num;j++)
			deleteBlk(tmp+j);

		tmp=readNextBlockNo(tmp);       					
		
		if(tmp==0)	break;
		
	}
	printf("\n\nSuccessfully deleted\n");
}

	

int deleteFileByName(char *filename)
{
	FILE *p,*q;
	p = fopen("./storage/allocation.txt","r");
	q=fopen("./storage/temp.txt","w");
	char temp[50];
	int inode,size,found=0;	

	while(fscanf(p,"%s %d %d",temp,&inode,&size) == 3)
	{
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

	if(found==0)  
	{
		printf("\nFILE NOT FOUND...!!!\n");
		remove("./storage/temp.txt");
	}
	else
	{
		remove("./storage/allocation.txt");	
		rename("./storage/temp.txt","./storage/allocation.txt");
	}
	fclose(p);
	fclose(q);
	return 1;

}

void* displayImage(void* t)
{
	  
	char img[100];	
	sprintf(img,"gnome-open %s",(char *)t);
	system(img);
  	
	
}


//---------------------------------------------------------------------Main---------------------------------------------------------------------------

int main(int argc,char *argv[])
{
	int choice,inode,fs_size,f,u;
	char path[50],name[50],file[50],dd[100],logo;
	FILE *tb;
	pthread_t thread;	
	tb = fopen("./storage/fs-detail","r");
	fscanf(tb,"%d %d ",&totalBlocks,&fs_size);
	fclose(tb);

	printf("\n");
	tb = fopen("logo","r");
	while((logo = fgetc(tb)) != EOF)
		printf("%c",logo);
	fclose(tb);

	printf("\n");

	do
	{
		printf("\nOperations menu:\n-----------------\n");
		printf("1. Store a file\n");
		printf("2. Delete a file\n");
		printf("3. Read a file\n");
		printf("4. Format\n");
		printf("5. FS Details\n");
		printf("6. Exit\n");
		printf("Enter your choice..: ");
		scanf("%d",&choice);
		switch(choice) 
		{

			case 1 	:  	prevBlock = 0;
					flag = 0;
					file_size = 0;
					contig = 0;
					m = 0;
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
					
					sprintf(dd,"./storage/buffer/%s",file); 
					pthread_create(&thread,NULL,displayImage,(void*)dd);
					pthread_join(thread,NULL);
					
					break;

			
			case 4	:	remove("./storage/disk.vs");
					system("rm ./storage/buffer/*.* ");
					printf("\nEnter size in MB[min-1mb] : ");
					scanf("%d",&fs_size);
					sprintf(dd,"dd if=/dev/zero of=./storage/disk.vs bs=1048576 count=%d",fs_size);
					system(dd);

					totalBlocks = (fs_size*1024)/4 ;					
					tb = fopen("./storage/fs-detail","w");
					fprintf(tb,"%d %d ",totalBlocks,fs_size);
					fclose(tb);
					initialise_free(); 
					printf("\n\nformatting done...\n\n"); 	
					break;

			case 5  :       f = freeBlocks();
					u = totalBlocks - f;
					printf("\n\nTotal disk size: %d MB\n",fs_size);
					printf("Used space: %f %%\n",(float)u*100/totalBlocks);	
					printf("Free space: %f %%\n\n",(float)f*100/totalBlocks);	
					break;

			case 6  :       exit(0);
					break;

			default :	printf("Please enter a valid choice !!!\n\n");
					break;
		}
	}
	while (choice != 6);
}
