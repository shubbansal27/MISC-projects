000007 000002 #include<stdio.h>
#include<string.h>
#include<stdlib.h>
#define hash_size 64


struct node
{
	char fname[50];
	int size;
	struct node* next;
};

// Hash Generator
int hashGen(char *str1, int size)
{
	int i=0, sum=0;;
	while(str1[i]!='\0')
	{
		sum=sum+ (int)str1[i];
		i++;
	}
	return (sum % size);
}

//Creating node
struct node* create_node()
{
	struct node* block=(struct node*)malloc(sizeof(struct node));
	return block;
}


//main starts
int main()
{
	char name[25];
	struct node *table[hash_size]={NULL,NULL};
	struct node* temp;
	
	while(1)
	{
		printf("Enter file name:  ");	
		scanf("%s", name);
		
		int hash= hashGen(name, hash_size);
		printf("hash index: %d\n",hash);

		if(table[hash] == NULL)
		{	 
			table[hash] = create_node();		
			strcpy((table[hash])->fname,name);
			table[hash]->size=0;
			table[hash]->next=NULL;
			printf("file entry created sfs!!\n\n");
		}
		else 
		{
			temp=table[hash]->next;
			while(temp!=NULL)
				temp=temp->next;

			temp=create_node();
		
			strcpy(temp->fname,name);
			temp->size=0;
			temp->next=NULL;
			printf("file entry created !!\n\n");
		}
	}

}// end of main#include<stdio.h>
#include<stdlib.h>
#include <stdio.h>
#include <sys/stat.h>

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


int find300kb_free()
{
	FILE *p;
	char c;
	int count = 0,num=1;
 
 	p=fopen("./storage/free.txt","rb+");
        while((c=fgetc(p)) != EOF)
	{  
                  if(c=='1')
		  {								
                    count ++;
		    if(count == 3) break;	
		  }	
		  else
		    count = 0;
	
               num++ ;
	}
        
	fclose(p);
	return num-2;  

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


int storeFile_4k(FILE *fs)
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

	//file_size = file_size + count ;

	if(feof(fs)) return -1;      
	return count;
	
}


int storeFile_300k(FILE *fs)
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

	
	
	
	return 1;
	
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
		printf("4. Exit.\n");
		printf("Enter your choice..: ");
		scanf("%d",&choice);
		switch(choice)
		{

			case 1 	:  	prevBlock = 0;
					flag = 0;
					file_size = 0;
					printf("\nEnter the source file path:  ");
					scanf("%s",path);

					struct stat filestatus;
					stat( path, &filestatus );
					file_size = (int)filestatus.st_size;

					printf("%d \n",find300kb_free());

					printf("\nEnter name of file:  ");
					scanf("%s",name);
					
					if(checkFileExist(name))
					{
 						FILE *fs = fopen(path,"r");
                                        
						while(storeFile_4k(fs) != -1) ;		
						
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
					scanf("%s", fil000000 000002 This was the time of day when I wished I were able to sleep.
High school.
Or was purgatory the right word? If there was any way to atone for my sins, this
ought to count toward the tally in some measure. The tedium was not something I grew
used to; every day seemed more impossibly monotonous than the last.
I suppose this was my form of sleep—if sleep was defined as the inert state
between active periods.
I stared at the cracks running through the plaster in the far corner of the cafeteria,
imagining patterns into them that were not there. It was one way to tune out the voices
that babbled like the gush of a river inside my head.
Several hundred of these voices I ignored out of boredom.
When it came to the human mind, I’d heard it all before and then some. Today,
all thoughts were consumed with the trivial drama of a new addition to the small student
body here. It took so little to work them all up. I’d seen the new face repeated in thought
after thought from every angle. Just an ordinary human girl. The excitement over her
arrival was tiresomely predictable—like flashing a shiny object at a child. Half the
sheep-like males were already imagining themselves in love with her, just because she
was something new to look at. I tried harder to tune them out.
Only four voices did I block out of courtesy rather than distaste: my family, my
two brothers and two sisters, who were so used to the lack of privacy in my presence that
they rarely gave it a thought. I gave them what privacy I could. I tried not to listen if I
could help it.
Try as I may, still...I knew.
Rosalie was thinking, as usual, about herself. She’d caught sight of her profile in
the reflection off someone’s glasses, and she was mulling over her own perfection.
Rosalie’s mind was a shallow pool with few surprises.
© 2008 Stephenie Meyer
2
Emmett was fuming over a wrestling match he’d lost to Jasper during the night. It
would take all his limited patience to make it to the end of the school day to orchestrate a
rematch. I never really felt intrusive hearing Emmett’s thoughts, because he never
thought one thing that he would not say aloud or put into action. Perhaps I only felt
guilty reading the others’ minds because I knew there were things there that they
wouldn’t want me to know. If Rosalie’s mind was a shallow pool, then Emmett’s was a
lake with no shadows, glass clear.
And Jasper was...suffering. I suppressed a sigh.
Edward. Alice called my name in her head, and had my attention at once.
It was just the same as having my name called aloud. I was glad my given name
had fallen out of style lately—it had been annoying; anytime anyone thought of any
Edward, my head would turn automatically...
My head didn’t turn now. Alice and I were good at these private conversations.
It was rare that anyone caught us. I kept my eyes on the lines in the plaster.
How is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
Alice’s mental tone was alarmed now, and I saw in her mind that she was
watching Jasper in her peripheral vision. Is there any danger? She searched ahead, into
the immediate future, skimming through visions of monotony for the source behind my
frown.
I turned my head slowly to the left, as if looking at the bricks of the wall, sighed,
and then to the right, back to the cracks in the ceiling. Only Alice knew I was shaking
my head.
She relaxed. Let me know if it gets too bad.
I moved only my eyes, up to the ceiling above, and back down.
Thanks for doing this.
I was glad I couldn’t answer her aloud. What would I say? ‘My pleasure’? It
was hardly that. I didn’t enjoy listening to Jasper’s struggles. Was it really necessary to
experiment like this? Wouldn’t the safer path be to just admit that he might never be able
© 2008 Stephenie Meyer

It had been two weeks since our last hunting trip. That was not an immensely
difficult time span for the rest of us. A little uncomfortable occasionally—if a human
walked too close, if the wind blew the wrong way. But humans rarely walked too close.
Their instincts told them what their conscious minds would never understand: we were
dangerous.
Jasper was very dangerous right now.
At that moment, a small girl paused at the end of the closest table to ours,
stopping to talk to a friend. She tossed her short, sandy hair, running her fingers through
it. The heaters blew her scent in our direction. I was used to the way that scent made me
feel—the dry ache in my throat, the hollow yearn in my stomach, the automatic
tightening of my muscles, the excess flow of venom in my mouth...
This was all quite normal, usually easy to ignore. It was harder just now, with the
feelings stronger, doubled, as I monitored Jasper’s reaction. Twin thirsts, rather than just
mine.
Jasper was letting his imagination get away from him. He was picturing it—
picturing himself getting up from his seat next to Alice and going to stand beside the little
girl. Thinking of leaning down and in, as if he were going to whisper in her ear, and
letting his lips touch the arch of her throat. Imagining how the hot flow of her pulse
beneath the fine skin would feel under his mouth...
I kicked his chair.
He met my gaze for a minute, and then looked down. I could hear shame and
rebellion war in his head.
“Sorry,” Jasper muttered.
I shrugged.
“You weren’t going to do anything,” Alice murmured to him, soothing his
chagrin. “I could see that.”
I fought back the grimace that would give her lie away. We had to stick together,
Alice and I. It wasn’t easy, hearing voices or seeing visions of the future. Both freaks
among those who were already freaks. We protected each other’s secrets.
© 2008 Stephenie Meyer
4
“It helps a little if you think of them as people,” Alice suggested, her high,
musical voice too fast foHow is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
---------------------------------------------------------------------------

thing that he would not say aloud or put into action. Perhaps I only felt
guilty reading the others’ minds because I knew there were things there that they
wouldn’t want me to know. If Rosalie’s mind was a shallow pool, then Emmett’s was a
lake with no shadows, glass clear.
And Jasper was...suffering. I suppressed a sigh.
Edward. Alice called my name in her head, and had my attention at once.
It was just the same as having my name called aloud. I was glad my given name
had fallen out of style lately—it had been annoying; anytime anyone thought of any
Edward, my head would turn automatically...
My head didn’t turn now. Alice and I were good at these private conversations.
It was rare that anyone caught us. I kept my eyes on the lines in the plaster.
How is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
Alice’s mental tone was alarmed now, and I saw in her mind that she was
watching Jasper in her peripheral vision. Is there any danger? She searched ahead, into
the immediate future, skimming through visions of monotony for the source behind my
frown.
I turned my head slowly to the left, as if looking at the bricks of the wall, sighed,
and then to the right, back to the cracks in the ceiling. Only Alice knew I was shaking
my head.
She relaxed. Let me know if it gets too bad.
I moved only my eyes, up to the ceiling above, and back down.
Thanks for doing this.
I was glad I couldn’t answer her aloud. What would I say? ‘My pleasure’? It
was hardly that. I didn’t enjoy listening to Jasper’s struggles. Was it really necessary to
experiment like this? Wouldn’t the safer path be to just admit that he might never be able
© 2008 Stephenie Meyer

It had been two weeks since our last hunting trip. That was not an immensely
difficult time span for the rest of us. A little uncomfortable occasionally—if a @     �l  000000 000002 This was the time of day when I wished I were able to sleep.
High school.
Or was purgatory the right word? If there was any way to atone for my sins, this
ought to count toward the tally in some measure. The tedium was not something I grew
used to; every day seemed more impossibly monotonous than the last.
I suppose this was my form of sleep—if sleep was defined as the inert state
between active periods.
I stared at the cracks running through the plaster in the far corner of the cafeteria,
imagining patterns into them that were not there. It was one way to tune out the voices
that babbled like the gush of a river inside my head.
Several hundred of these voices I ignored out of boredom.
When it came to the human mind, I’d heard it all before and then some. Today,
all thoughts were consumed with the trivial drama of a new addition to the small student
body here. It took so little to work them all up. I’d seen the new face repeated in thought
after thought from every angle. Just an ordinary human girl. The excitement over her
arrival was tiresomely predictable—like flashing a shiny object at a child. Half the
sheep-like males were already imagining themselves in love with her, just because she
was something new to look at. I tried harder to tune them out.
Only four voices did I block out of courtesy rather than distaste: my family, my
two brothers and two sisters, who were so used to the lack of privacy in my presence that
they rarely gave it a thought. I gave them what privacy I could. I tried not to listen if I
could help it.
Try as I may, still...I knew.
Rosalie was thinking, as usual, about herself. She’d caught sight of her profile in
the reflection off someone’s glasses, and she was mulling over her own perfection.
Rosalie’s mind was a shallow pool with few surprises.
© 2008 Stephenie Meyer
2
Emmett was fuming over a wrestling match he’d lost to Jasper during the night. It
would take all his limited patience to make it to the end of the school day to orchestrate a
rematch. I never really felt intrusive hearing Emmett’s thoughts, because he never
thought one thing that he would not say aloud or put into action. Perhaps I only felt
guilty reading the others’ minds because I knew there were things there that they
wouldn’t want me to know. If Rosalie’s mind was a shallow pool, then Emmett’s was a
lake with no shadows, glass clear.
And Jasper was...suffering. I suppressed a sigh.
Edward. Alice called my name in her head, and had my attention at once.
It was just the same as having my name called aloud. I was glad my given name
had fallen out of style lately—it had been annoying; anytime anyone thought of any
Edward, my head would turn automatically...
My head didn’t turn now. Alice and I were good at these private conversations.
It was rare that anyone caught us. I kept my eyes on the lines in the plaster.
How is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
Alice’s mental tone was alarmed now, and I saw in her mind that she was
watching Jasper in her peripheral vision. Is there any danger? She searched ahead, into
the immediate future, skimming through visions of monotony for the source behind my
frown.
I turned my head slowly to the left, as if looking at the bricks of the wall, sighed,
and then to the right, back to the cracks in the ceiling. Only Alice knew I was shaking
my head.
She relaxed. Let me know if it gets too bad.
I moved only my eyes, up to the ceiling above, and back down.
Thanks for doing this.
I was glad I couldn’t answer her aloud. What would I say? ‘My pleasure’? It
was hardly that. I didn’t enjoy listening to Jasper’s struggles. Was it really necessary to
experiment like this? Wouldn’t the safer path be to just admit that he might never be able
© 2008 Stephenie Meyer

It had been two weeks since our last hunting trip. That was not an immensely
difficult time span for the rest of us. A little uncomfortable occasionally—if a human
walked too close, if the wind blew the wrong way. But humans rarely walked too close.
Their instincts told them what their conscious minds would never understand: we were
dangerous.
Jasper was very dangerous right now.
At that moment, a small girl paused at the end of the closest table to ours,
stopping to talk to a friend. She tossed her short, sandy hair, running her fingers through
it. The heaters blew her scent in our direction. I was used to the way that scent made me
feel—the dry ache in my throat, the hollow yearn in my stomach, the automatic
tightening of my muscles, the excess flow of venom in my mouth...
This was all quite normal, usually easy to ignore. It was harder just now, with the
feelings stronger, doubled, as I monitored Jasper’s reaction. Twin thirsts, rather than just
mine.
Jasper was letting his imagination get away from him. He was picturing it—
picturing himself getting up from his seat next to Alice and going to stand beside the little
girl. Thinking of leaning down and in, as if he were going to whisper in her ear, and
letting his lips touch the arch of her throat. Imagining how the hot flow of her pulse
beneath the fine skin would feel under his mouth...
I kicked his chair.
He met my gaze for a minute, and then looked down. I could hear shame and
rebellion war in his head.
“Sorry,” Jasper muttered.
I shrugged.
“You weren’t going to do anything,” Alice murmured to him, soothing his
chagrin. “I could see that.”
I fought back the grimace that would give her lie away. We had to stick together,
Alice and I. It wasn’t easy, hearing voices or seeing visions of the future. Both freaks
among those who were already freaks. We protected each other’s secrets.
© 2008 Stephenie Meyer
4
“It helps a little if you think of them as people,” Alice suggested, her high,
musical voice too fast foHow is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
---------------------------------------------------------------------------

thing that he would not say aloud or put into action. Perhaps I only felt
guilty reading the others’ minds because I knew there were things there that they
wouldn’t want me to know. If Rosalie’s mind was a shallow pool, then Emmett’s was a
lake with no shadows, glass clear.
And Jasper was...suffering. I suppressed a sigh.
Edward. Alice called my name in her head, and had my attention at once.
It was just the same as having my name called aloud. I was glad my given name
had fallen out of style lately—it had been annoying; anytime anyone thought of any
Edward, my head would turn automatically...
My head didn’t turn now. Alice and I were good at these private conversations.
It was rare that anyone caught us. I kept my eyes on the lines in the plaster.
How is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
Alice’s mental tone was alarmed now, and I saw in her mind that she was
watching Jasper in her peripheral vision. Is there any danger? She searched ahead, into
the immediate future, skimming through visions of monotony for the source behind my
frown.
I turned my head slowly to the left, as if looking at the bricks of the wall, sighed,
and then to the right, back to the cracks in the ceiling. Only Alice knew I was shaking
my head.
She relaxed. Let me know if it gets too bad.
I moved only my eyes, up to the ceiling above, and back down.
Thanks for doing this.
I was glad I couldn’t answer her aloud. What would I say? ‘My pleasure’? It
was hardly that. I didn’t enjoy listening to Jasper’s struggles. Was it really necessary to
experiment like this? Wouldn’t the safer path be to just admit that he might never be able
© 2008 Stephenie Meyer

It had been two weeks since our last hunting trip. That was not an immensely
difficult time span for the rest of us. A little uncomfortable occasionally—if a @     �����  000000 000001 e);
					readFileByName(file);		
					
					//checkDiskSpace();	
					//printf("\n");
					break;
			
			case 4	:	break;

			default :	printf("Please enter a valid choice !!!\n\n");
					break;
		}
	}
	while (choice != 4);
}
----------------------User-level implementation----------------------------------------------------------------

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
		printf("4. Exit.\n");
		printf("Enter your choice..: ");
		scanf("%d",&choice);
		switch(choice)
		{

			case 1 	:  	prevBlock = 0;
					flag = 0;
					file_size = 0;
					printf("\nEnter the source file path:  ");
					scanf("%s",path);

					struct stat filestatus;
					stat( path, &filestatus );
					file_size = (int)filestatus.st_size;

					printf("%d \n",find300kb_free());

					printf("\nEnter name of file:  ");
					scanf("%s",name);
					
					if(checkFileExist(name))
					{
 						FILE *fs = fopen(path,"r");
                                        
						while(storeFile_4k(fs) != -1) ;		
						
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
					s@     ��(F  �             YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ~�[F                                                                           �     �     �                     �8      �8      �8     �49      �                                                                                                                                                                                                                                    �t}F  /       �2\F          0y}F  �@                            0Ğo�  i/\F  �}F  �t}F  0Ğo�  ��[F                                                          Dz\F          sg)F          �[F  �[F   P}F         �[F  �@     ��)F         �[F                        be)F         �[F  0ʞo�  ����    @ʞo�  �@     ����������&F         �M�O    3#�9    I�M            yO    ���                                    �@     �}F         @�}F                  � \F          �Ǟo�                                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  �    ޒD��8�W;��v�;��AMA����K������d���	$$�N.�359\��i�����i<�Z�Lg�Ƥ�'$��xI�e����c������3:�Ge�+����$����UE2�_L�m�IiL�~X�6Ы������5k�$��*=��F8kRU$SN6v�)2vma?�M���;�s�檛y|۹l-ʖ�8Zk'��9��cS!մgIZ���g�CI~��:�y|/'S���I�
ঔ�53�i�A���NN� ��Yo��VES���r�jv9�ڪ��J�-^�4����>� ���Kj��JVs�Dz��0�sa_@���L�y�g
KT�k|�׼�ʓ��2CX�������t�s3JT����s���I���jӐr����Ֆy�?�nE������B�s��7+Â��jp�[)A�d�⬶���:�9B���j3�.KYPGѮ��E=�D��VS�+N�.Ţ�Mh�K��D�fS�h���@�5*�����^�P����v���f�f���;
�e3A�0KS�
�CCd1D5��3[�L���^�F��F���T$8KPNP����sk�'w���40w��q�4���\���T,�k�;FF�[QW0_Ѝ��$�ќ������*�5Z�+�5�@Y
�7��u��y��y�2IZ?�G�У�u2w404F�0�G:4h<�������βg1_6��28��g=L���r��i)
�i�{���q�4��\	�ck%��3,�|7mM�ģS�ӏ$�Yi'H�s>w���"O=�E6t0�f
ҵc�Uv�B�1qM.c�K��t�RR���)��9zr�.V;V�fiu����Z�,QW:կ;����p4Ɇр���ӘM#�6s��n�;�W��zI�������m�҄��4^w� M�y&my�t�%E e���㻹���S�
��>�'9�j�tZ�\�:=nؼjh��k6�x��r�kנ�>0�J��ȣq��T�E���{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   A���B[��s��$���H^����+�CN7/l
��;��e�t������a�qK�_��;BUދݻ
.kY�����d�;�z�4/+}%��N��ҷ�tB.h"m�j��[״8Iؒs��:�\j����AB�.��H6ق��V-9�ZЕܩhL���C��Y���#-%|S)V꼿*�v�Xw%yJ4��ٚ
�:��8��֬�\�8�c��1~N���JL�>�|�D��Rꞎ~����z���k�d���rj3�	[Iq�t<�����t:�|Kv��Q�?�u�s�y�ʼ���0�ز�5�U�c3o
�n�x���s����MI$"���i��wC�и��x�@)�P�������;�'`y!$�䄤����-.ԝ�NI��I�$��HrHvHS�r���{'I$��%I!$�$��D��Gd�$�����b�m���-':I^���!'�&K8�o��n��V�S!�i �v_D��l�$�$���,�,��������҂�q��u������=gd����E��r�ݬ�VצY�
�7��u��y��y�2IZ?�G�У�u2w404F�0�G:4h<�������βg1_6��28��g=L���r��i)
�i�{���q�4��\	�ck%��3,�|7mM�ģS�ӏ$�Yi'H�s>w���"O=�E6t0�f
ҵc�Uv�B�1qM.c�K��t�RR���)��9zr�.V;V�fiu����Z�,QW:կ;����p4Ɇр���ӘM#�6s��n�;�W��zI�������m�҄��4^w� M�y&my�t�%E e���㻹���S�
��>�'9�j�tZ�\�:=nؼjh��k6�x��r�kנ�>0�J��ȣq��T�E���{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  � (       !"# 0123AB$i$�$������ty�79U���\S9�}CQz�ܒ���BN+�Qa�d�f�G;��T�~�����lA߬윩$����%S��X;��pM}�����iM25z��M��w��&o#yݞ:�xm@fn�'\��'q� E�u�L�Nntw��)��x�Y#���3XE����1�E���j��)oF{9P�����Z5!��wt6��N�z������I��.._��y�6�3��z←pw��yg����/u��Ԕ��.p$�9��׵U0D�p�\���[��,�����Neo.#O���K�@ء���EE�Si!-����z2�-���.l�m��=���9j�-ȕ�C.�c�#�j�����}�qz��D�NޥjQU��
��;��e�t������a�qK�_��;BUދݻ
.kY�����d�;�z�4/+}%��N��ҷ�tB.h"m�j��[״8Iؒs��:�\j����AB�.��H6ق��V-9�ZЕܩhL���C��Y���#-%|S)V꼿*�v�Xw%yJ4��ٚ
�:��8��֬�\�8�c��1~N���JL�>�|�D��Rꞎ~����z���k�d���rj3�	[Iq�t<�����t:�|Kv��Q�?�u�s�y�ʼ���0�ز�5�U�c3o
�n�x���s����MI$"���i��wC�и��x�@)�P�������;�'`y!$�䄤����-.ԝ�NI��I�$��HrHvHS�r���{'I$��%I!$�$��D��Gd�$�����b�m���-':I^���!'�&K8�o��n��V�S!�i �v_D��l�$�$���,�,��������҂�q��u������=gd����E��r�ݬ�VצY�
�7��u��y��y�2IZ?�G�У�u2w404F�0�G:4h<�������βg1_6��28��g=L���r��i)
�i�{���q�4��\	�ck%��3,�|7mM�ģS�ӏ$�Yi'H�s>w���"O=�E6t0�f
ҵc�Uv�B�1qM.c�K��t�RR���)��9zr�.V;V�fiu����Z�,QW:կ;����p4Ɇр���ӘM#�6s��n�;�W��zI�������m�҄��4^w� M�y&my�t�%E e���㻹���S�
��>�'9�j�tZ�\�:=nؼjh��k6�x��r�kנ�>0�J��ȣq��T�E���{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  �  �I�7J��p�`���p��Qss���h�q��w��~&`��	��dW;z�{��ͧf$0?��+�sǍv�)��l��7:�T��E�,��	�<��+��0��֏����x����� ��7�fƉ|�'<o��L�0�ݹy�5���8 ���(5S�xˎ++}�Σ��0�:�Z�^�EVV��]1Au�;r'ڔ���j�[li���,�k)O�Xr��}շ%<�譌���)ؤ��n�גUP_D������Q�ڳ$��VjEЮx���'���kq�Λ�l�s\�N���ǀ�Iخ\_����~3�dA@��e�u^�yl��'IWc���hp����!�4e�^O:�)|N*�w^�̈1����<�≣$η�x����s�U5��r�44�{�`�T���韬��_]�t�/�
?Iw�&�G�Ox�&�Ӂ9T����7U9L=Y����oH�QK!�~[t|!
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �MC�Ȗ��pV�9Q�u��'5��*���qڈ�	�"����"ƹ~EwVIp�hnȼe��MP8}s�N¬�0L
�v�mW�ˎ����IK�%�V�yv���yҕ�`͏3�4Y2�Lh�5�+����G�K�����$Q�E}j�4�[�Jں,�6<�YV}X)���Q���u��̼e������7g"����\4`�.�\z��~j���H�A6�?Z&��*�"z\��Br��*2��g����2������1AI��u:}Xi���Lp��N@Η,R+��0�0N���1�A���\���D�-:�;�CL��!~:�m����S?�G�W�5�6�x��#�� ��͖�Lc��:�8<gV����y�A���R՞�L�;y���J�O��& 
>��>KiՏ8��� �P�/�
?Iw�&�G�Ox�&�Ӂ9T����7U9L=Y����oH�QK!�~[t|!
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   `���E��q/�����x؈�צ��|���xy�u�
�����:B���V��if�r>�����d�W�Ǘ��[݂
>��>KiՏ8��� �P�/�
?Iw�&�G�Ox�&�Ӂ9T����7U9L=Y����oH�QK!�~[t|!
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ���*e�xh�$%��yq<g��$ߜ�y�3�0���{����,����vve՞Q�<i�}xYp6�8[Q�&���I����v��q��e�����F ���j���B�ӬR�����mM2et:�n���,�Թ��Dj����UCq�y��&7�U�@�:o�]t�ʟ��g�2i��'J*�]>�G��^�.�iE�TJg���"��o�3QPv*�7�r�wB[��*�"z\��Br��*2��g����2������1AI��u:}Xi���Lp��N@Η,R+��0�0N���1�A���\���D�-:�;�CL��!~:�m����S?�G�W�5�6�x��#�� ��͖�Lc��:�8<gV����y�A���R՞�L�;y���J�O��& 
>��>KiՏ8��� �P�/�
?Iw�&�G�Ox�&�Ӂ9T����7U9L=Y����oH�QK!�~[t|!
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �mDE5�O�_�E�gA�>��Kh��݂�jU9Y�9�W9�&��j�j�w9��s�T��|���J���+L���7e�O�gYS����e��&���_���oK(`��ZJ���P�&���{�t:�n���,�Թ��Dj����UCq�y��&7�U�@�:o�]t�ʟ��g�2i��'J*�]>�G��^�.�iE�TJg���"��o�3QPv*�7�r�wB[��*�"z\��Br��*2��g����2������1AI��u:}Xi���Lp��N@Η,R+��0�0N���1�A���\���D�-:�;�CL��!~:�m����S?�G�W�5�6�x��#�� ��͖�Lc��:�8<gV����y�A���R՞�L�;y���J�O��& 
>��>KiՏ8��� �P�/�
?Iw�&�G�Ox�&�Ӂ9T����7U9L=Y����oH�QK!�~[t|!
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   T�u4�g7�~+������)΀�_`V�
����w��(.��+��9H�T���L�<�'�ڌ�F�f6� ����Z�@쭢�zSɫ.O~\1�.2{��@�vQ�J)e�R9Vͨ�.4�Q�廽F�{�:Md�ځ�ǁ�t;�tQ�.ڤ��{�~1n8zc�Q&�bDTL���(�&�֢\*���G����?K���6
�U�U�h�r�ӒaD�d�r�Q�OK/�&\ǔ�\&N�AV�է��9�V�n[�1����P	�9�p@h���p���5Fx���P�˜A⻲H��J#(���O�J/fLS
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��{��2����(���&q��jr>�$�1״O�8�id�вU�Fq�s�}s�e�n��j���G
�*��W������r�=r���J���Q�/�	����*V�v�)i48Ihb3�����W$}��d\�!X�r.�-�W��*�@�"��w��� Kv�{]�c�;57��V�*�i�-=a���Z��:����*F��#&݋�J�Q�#'\z�$	w��R{�FG�;'�̹up�w��<�{'O�9���l���ovN{S�Cz�����9����
M�x�Qx��v�s�t��m=�x�8 
J�JZ�ƀ*�SR%��+A�=�0�i��B�<x���9{��esM�@��UJE�҄-��y�����V*H5�F�'[ItB9~��ֹ7��()��k���T�^h<j�Y�f4YQYW���L�0�}@�զ�6��(D~kDv�&�7�kʬXQ4�^���|�^�<�;$�D�T���a���u��a�N�(�JT����Y�gOzR���C#J��f�y+��ǥUh�8���5�|A�
�-�u ݸF�#�[�\�uw\�<A�q�بP�����?uMZJݼs��G��R%r~0��ʞ�<�^e_��L��� �~��$璮m���W��ѽU�_	��G�k����S�gε��#��*Qg��K;4Vg� �g�Y"�3����),�@uc�`�~F�6u*E��&)��݊ss�j�.���FK�y��0Waj����Z�*T��)���$o#��P�U��b��������Kq��9Gti���}A�	f�H3����U|c\R������HLM�7Z-Rv-7NZ�s���*f��p~��G^P��{�٭9��N\)
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   o!�e�7���a���V�d�_�M��_⣀�ҷ�3�b�q���Za1@KCOZA5�}Q��W������r�=r���J���Q�/�	����*V�v�)i48Ihb3�����W$}��d\�!X�r.�-�W��*�@�"��w��� Kv�{]�c�;57��V�*�i�-=a���Z��:����*F��#&݋�J�Q�#'\z�$	w��R{�FG�;'�̹up�w��<�{'O�9���l���ovN{S�Cz�����9����
M�x�Qx��v�s�t��m=�x�8 
J�JZ�ƀ*�SR%��+A�=�0�i��B�<x���9{��esM�@��UJE�҄-��y�����V*H5�F�'[ItB9~��ֹ7��()��k���T�^h<j�Y�f4YQYW���L�0�}@�զ�6��(D~kDv�&�7�kʬXQ4�^���|�^�<�;$�D�T���a���u��a�N�(�JT����Y�gOzR���C#J��f�y+��ǥUh�8���5�|A�
�-�u ݸF�#�[�\�uw\�<A�q�بP�����?uMZJݼs��G��R%r~0��ʞ�<�^e_��L��� �~��$璮m���W��ѽU�_	��G�k����S�gε��#��*Qg��K;4Vg� �g�Y"�3����),�@uc�`�~F�6u*E��&)��݊ss�j�.���FK�y��0Waj����Z�*T��)���$o#��P�U��b��������Kq��9Gti���}A�	f�H3����U|c\R������HLM�7Z-Rv-7NZ�s���*f��p~��G^P��{�٭9��N\)
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��E�^��
�G��@vJa��U���4�_S6�2�tKW���?k0E�5(��O`^�6P������ʂ��ÝD�<�����u�9y��5�憋��`�� ��.�i�;�B5���I4f�I�ES=�6�7d(��դ�3��P��`���*[l�L�PP��}�T��~/$mX�p��'��֩�3m��O֮j�<WWv|��ϞG�O��� +Ns�^� 8.�&�7��00嵠Y�z���;P�+B(ˢ-;GNΡ@�v��lXx���g:r�6��WJI�
{_��D@�.�?I�e	�g��]�)o�S6�S�#^�C�։�}��-J#׎�8�!�r��]u�����EX�O��j*�l��tj�vN����=�m�"�1[|�
��p�X�}�h���3s�9Hi�.�{*v���}.�ͦuӂQ�Z|1ܤ]��)W�m|b�8K\TB� ��9�m)��$S)�%��V� iʫ����/y�v.����( �w�;`i�����R5U��0���A�)d�J�Z:����J�m�#�.6e��f�������tP�t/R27؇AB��������٤��99 �v�؃�_��'�9]��w�x�ړE~��3�?���b�t���,=�d9f�2��;��Mf��AC��[����r��j�J��r�	���OK^��O�ǎ�50Y�i�L ���>B�ќ�Q3ʿ
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   A�p��Ù��אf��*�$U�e��c��*+�+}T���������Q+d|��)㜚�ڜ<��OX��,�
SD7J�� ��T�ҁ^�a��	���
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �a�u�lB���C\�]�Wg�s<�U�~?��;L�r!����S���9��v�p�0L�j�qֈ�]�Q-�T���S��R��e�<�NMN,�+�ح�EI�#�K�U�����.>�9�̫x���˴W�����G�$�X8��a������L�h�)��f,�^fX�F�-=��l���x�� �0ӣp�e �7�X�|~G�!8�g�_��Y9����z����λ#%$�ăd���gLvBFy��u�Bz#nȾ8� �Z�h6�,��dh�.ps������W8�8�U����9���VΤ��s��9�s��9�s��9�s���9�s��?K �pݽe��t�Eb���y���31(�~��FL
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  �            01A!@q��;L�r!����S���9��v�p�0L�j�qֈ�]�Q-�T���S��R��e�<�NMN,�+�ح�EI�#�K�U�����.>�9�̫x���˴W�����G�$�X8��a������L�h�)��f,�^fX�F�-=��l���x�� �0ӣp�e �7�X�|~G�!8�g�_��Y9����z����λ#%$�ăd���gLvBFy��u�Bz#nȾ8� �Z�h6�,��dh�.ps������W8�8�U����9���VΤ��s��9�s��9�s��9�s���9�s��?K �pݽe��t�Eb���y���31(�~��FL
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  � ?��Ya�Wbÿ2����9UvF;d@����"#O���F��胇tΈ���>+1�V���	�H�9�x�H�U��qӚ9���3����C��0��<�3&�����������	�����4F���I'	�xğb�Ĉ����E8v�#����X�,;Ny�a��g�ub��~�!�:z@��:r���a3堍����?��4I$��?�v�1xڑ8yd��[���M|�>Ya�G��u�Bz#nȾ8� �Z�h6�,��dh�.ps������W8�8�U����9���VΤ��s��9�s��9�s��9�s���9�s��?K �pݽe��t�Eb���y���31(�~��FL
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  � +       !1"A 2QaqB�0�3Rr胇tΈ���>+1�V���	�H�9�x�H�U��qӚ9���3����C��0��<�3&�����������	�����4F���I'	�xğb�Ĉ����E8v�#����X�,;Ny�a��g�ub��~�!�:z@��:r���a3堍����?��4I$��?�v�1xڑ8yd��[���M|�>Ya�G��u�Bz#nȾ8� �Z�h6�,��dh�.ps������W8�8�U����9���VΤ��s��9�s��9�s��9�s���9�s��?K �pݽe��t�Eb���y���31(�~��FL
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  � ?��NYSd���M���wL����&��٪Drc�J�}���%��u��!6��
U��syޙ��Bև*~"w�����F܇I.	F����gM�}]�,F�������AE��9.H�.HI����N^(r��ϧ�Oɣ�VO|�Ӥf�����m��ѯhk�J�3^Μ�Dғؔ��R�ȝ��a3堍����?��4I$��?�v�1xڑ8yd��[���M|�>Ya�G��u�Bz#nȾ8� �Z�h6�,��dh�.ps������W8�8�U����9���VΤ��s��9�s��9�s��9�s���9�s��?K �pݽe��t�Eb���y���31(�~��FL
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   E}�H�VΜ�]�Q{�#|�W�bF*����,�FߏÍ���YYt˜W_���w��3���7��"�"��9�gO�;�G/˴��z�^\1Ʒc��Jir^�>;.��j������[eڤ�v�K���d'f	픠���4(�C�D��^^4c�I�s����cj�g�9SƄ�>�il��j�J):�X�C�{-�F�����'O�Gnƥ�"��j�����eW�5���J?�F�m�Ʊ�Gq��$�J5����:Qw�Σ������\�j2�D���T�j���
�+%U�t�t��$��$Uwq�O�b�Dcj�J2�"���q�#ip��>�F+�<"5�rN��M>>,��$b����Df���X�2�Xڌ�D�i�x���NЧ\�'9��FMGe��%��!���]��"�S�v��2[3���9b�����r�*�i�U�Ym�y�|u���yW�rUC�QmQ��qKg�Q�싲rihSUO�%-�\6����d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  � 8    !1A"Q2aq �0B���#Rb3�$���@r�3���7��"�"��9�gO�;�G/˴��z�^\1Ʒc��Jir^�>;.��j������[eڤ�v�K���d'f	픠���4(�C�D��^^4c�I�s����cj�g�9SƄ�>�il��j�J):�X�C�{-�F�����'O�Gnƥ�"��j�����eW�5���J?�F�m�Ʊ�Gq��$�J5����:Qw�Σ������\�j2�D���T�j���
�+%U�t�t��$��$Uwq�O�b�Dcj�J2�"���q�#ip��>�F+�<"5�rN��M>>,��$b����Df���X�2�Xڌ�D�i�x���NЧ\�'9��FMGe��%��!���]��"�S�v��2[3���9b�����r�*�i�U�Ym�y�|u���yW�rUC�QmQ��qKg�Q�싲rihSUO�%-�\6����d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  �  ?�s�ҋt\Ze�fc��ʻ~�Zu?r��қ���~L����E/��j����^�2�?��_q�憥_+���|�Wr�o��U��"ߧ�O������Ze<K�0j���E�G�\#����S-m���+��m�^��5g����I�a$8rʼ��{�T�_ѫ�iԑUTS�ri�v=M�:i����md�J�'��{��T6�(��(id�ܩ�ѹ�Ζt�|�-�����i����l1'*���J1d\����I��E���%hͷ���ҟ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   C�2���kR����U�����Jά�o:�]�f��N�&���\cg�%*�q�}�x��EK=�Y����:��%ǚKc�[�qFK#wo�%��2���~&�B�kBbҺ������=���2�ϕ���}GU�_��!~"I�������Kar�.���.JP��%KvΤ빪r��-P��ǺLL�E�1�`�Qo��3�[ӡ8gP�Q�R���I���f]����~M�m��X�����ni�S[>�K������>c7�/;odW����:���Uԫ�Nܛ�}��rKtќJ����u=�y���:n�4��Ѥ��q���v4G��$��H����Z�%,!v����ҝY��r��,Ԛ)Ei5E�F�%�j���؍�QɿV���c���SCЮF�$j�5i�8�	
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   M>G��l�m�M�K�|��V˃i{vW�48Uw&�H5D����S���M�Ö���WcNe޸5U��򤮌��ĵ`��EE��ERu�}I���,ga�Uj&�Oٳ�;���)JwF�檈�t'm�Β�~K�m8v-�v��Ԭ����Kar�.���.JP��%KvΤ빪r��-P��ǺLL�E�1�`�Qo��3�[ӡ8gP�Q�R���I���f]����~M�m��X�����ni�S[>�K������>c7�/;odW����:���Uԫ�Nܛ�}��rKtќJ����u=�y���:n�4��Ѥ��q���v4G��$��H����Z�%,!v����ҝY��r��,Ԛ)Ei5E�F�%�j���؍�QɿV���c���SCЮF�$j�5i�8�	
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   Vj��Fu�
N]#���#�	�:v�m�����Uh���ru�.%�_qRZ^���t�R������}�zs�?�P�S�(��[x�T%Wɯ^K��e�fF���-�Y[�%҄�O�:����K�E
0���{�6�+B��G�-�+O��Q��P��{�5�U�p��LL�E�1�`�Qo��3�[ӡ8gP�Q�R���I���f]����~M�m��X�����ni�S[>�K������>c7�/;odW����:���Uԫ�Nܛ�}��rKtќJ����u=�y���:n�4��Ѥ��q���v4G��$��H����Z�%,!v����ҝY��r��,Ԛ)Ei5E�F�%�j���؍�QɿV���c���SCЮF�$j�5i�8�	
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ǖ_�?̿�3�I��sD�T5�Eh�4��Η�p��R�j:�!�b���t����Ѯ2��ǧ����$W���>,��)�H֚4A׹���.G���cL��U�7F�����T��}z��f�F��r��e-6z�7ɘ�ŧo-�ɬ}��P�q��?r�:�-�
?ϒ��{H�?�������,����ԥ�S����,�j��QN+W����s�zW�7)��������KL�Պjkކ��ZՏOKb�Z.����*)3��y��49W�F*��\�i�Te���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ���eZ��ݙ����n��=�����d�I��'�I�e�'���i��ڇ-+S./<��Vi����OG����W
��ǭ�1n������E�Ėk4j�;!�qɩl���z��w{�2m1w~Z��f<��Q�Q����j8��z�4EP�Y%Fs[�S~�k~­�ܦ��-�YseB-��I��Y��E�ܟ=���å�)+N,�9t�c.Ս�GRZ^���s�zW�7)��������KL�Պjkކ��ZՏOKb�Z.����*)3��y��49W�F*��\�i�Te���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��u�����4�9BK���Q\�R������I��8m��ҷ͗���{4%,�ظ�,Z�"����J.���M���\�̽���Э%��=���G�+�t��-R|�j���b^t��Tm�teS|�b=++vBi��,�O�_��St���>'�i䤑qv\�RU���m�r]/b���r�24�5U����Ē�qE]���l��.�`�ֽ�..Ս�GRZ^���s�zW�7)��������KL�Պjkކ��ZՏOKb�Z.����*)3��y��49W�F*��\�i�Te���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   G�56�!4j���gS�r��lZzhKY%����T{?+�-z�O�K�zc��$�:4��\$�������E���a���Ž�G�U���.����i�R�
+u��Q-R|�j���b^t��Tm�teS|�b=++vBi��,�O�_��St���>'�i䤑qv\�RU���m�r]/b���r�24�5U����Ē�qE]���l��.�`�ֽ�..Ս�GRZ^���s�zW�7)��������KL�Պjkކ��ZՏOKb�Z.����*)3��y��49W�F*��\�i�Te���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   .���@���K�k�ɦΜ���eIlgn>�e#LVkr�eK�lвEKoGR۹{��L�wK�F��(�l_�&��:�;�Jt-Uj���NB{�QM'�M<.J[}U��7�9����h�VV��B�uح��J;���Ko��c�;�-���˧cS���Eߖ�{����bFc��-�6ǔ��lK�pi�Qk��4ʖbTG�Or/m��B�s�E�[3�.#[Y��d��T�;����/���Ín?s����������-4θ:�)*H�B�6V�������F�t��nie���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   >��8�8䷢&b�����̿�i
�Kf����08VӹO?���vn)-��>�،[0���)��MCQu�'d�m��I��M<.J[}U��7�9����h�VV��B�uح��J;���Ko��c�;�-���˧cS���Eߖ�{����bFc��-�6ǔ��lK�pi�Qk��4ʖbTG�Or/m��B�s�E�[3�.#[Y��d��T�;����/���Ín?s����������-4θ:�)*H�B�6V�������F�t��nie���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   I�����[߂�bхԼ�X���)�/��*$��BX}�}�=ΟO��m�F�>Sӷr�O�u,�B�E%����KR����hm&e�J;!%�w�Is��K�;|�d�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ���*Xhp~���rt�8"�<A+��Kc�n(��ߋ����൷юs�����Kd8��[4������	��{x4?��Dt���s�L��{����9E��
rU�i�rH~"����|�[F%ni|y��5/Q���%��%&��n/M��uɇ�c[�7����΅�r�6ǔ��lK�pi�Qk��4ʖbTG�Or/m��B�s�E�[3�.#[Y��d��T�;����/���Ín?s����������-4θ:�)*H�B�6V�������F�t��nie���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ����6���/��.N��۬
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   n���??�Z�h�X|��t�h�{#J��rcm��:K��+�*�c'Tr+���tR��շa�_��Hq�v[�oc�1����c���{�R)�w:^���n\���!:s�W�p�,_��]�Ǝ�\_O4-R����/�I3��5�X��:�n/M��uɇ�c[�7����΅�r�6ǔ��lK�pi�Qk��4ʖbTG�Or/m��B�s�E�[3�.#[Y��d��T�;����/���Ín?s����������-4θ:�)*H�B�6V�������F�t��nie���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �]�:w�if�Ǔ4���]V��*�A�H�7:��vB�_Ͳ�}��5�I2�Q��-VfV��kbT�Z�5�{�q�=د�Rx���Wh���˔���mĸ��N���縷L�^?�4���J�[�R����/�I3��5�X��:�n/M��uɇ�c[�7����΅�r�6ǔ��lK�pi�Qk��4ʖbTG�Or/m��B�s�E�[3�.#[Y��d��T�;����/���Ín?s����������-4θ:�)*H�B�6V�������F�t��nie���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ����ļ+�ވ'4٣iܶ\_K�3��ґ��R��g�椟�K�Ů����E����T�!T�/Q�/
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ������q���3ῲ�-_��M{�^c���I�/�آ�N�KĔe��~#�T�*�O��Lt�%�l_��N|��Tuw:-?�p�$��?	���g�S��(�?
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   s�_�r���A-Y+B����i|��CROڅ/���%�E7=Q�����=��Z&�cܤ�-�X�-v5i�u:4��ݙY�)�r�}]��K��?	���g�S��(�?
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   c�Q��,��M��߽yp�Ysi�~�ӧٔ��Q(�:{��
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ]�﷕U��5C��ىǥ�LJv�RW����Q(�:{��
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ѵ
/q�F�{P��ݑ�eUے��͋\h�צ(�Ҹ]������S����
pY�u�ًn�3������\�fC��r�)'E5qC��zH��E��4�q�/7��Iƽ�ٴcr�Ne`���)X�T���r����x�5?z3Ֆ�5�[��N���긲)��5S�B�x\��Y}���ŷ[��J#&�P�R���Ы$\�*�pr[3�.#[Y��d��T�;����/���Ín?s����������-4θ:�)*H�B�6V�������F�t��nie���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   $���]�GR4���6�˩>M/+��Z�!��r�G/�Z��=u��GX��JY䄰�i�3f34��5��*�s�HS����/���/�y���b/J�ޖ��%���(A$~}K�Ŀ�FP�^�N�Y'Zh�-��7hY�К������5�[��N���긲)��5S�B�x\��Y}���ŷ[��J#&�P�R���Ы$\�*�pr[3�.#[Y��d��T�;����/���Ín?s����������-4θ:�)*H�B�6V�������F�t��nie���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �Vτ��o�S��c�hs�cڌ��q4��3��]	�M8�������c��׉���=$�=���c��˪,�^wJ��cM&Tp�zF���/��
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��Ҫ?~MI$�Χ�j~�K],{�Ew:d��6���Tj�z�Y�V��#G�#?M7Q:W�{��ˋ+�ԑ�$(�7�İ(4���{���rr�f���p_������\|y���Fs"�$�|=����Ӫf����ƭ4��Y��R+��~z��������v$I<�^��OV�	,!��h����*GM��E=��c���m�#E[
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   o��eJ-�fP�Ŷ�x6�������_c��o�.)ٓ&1�����ݱ4��[���$�;0uYS�`��8�fYiQrϖ��Vj���o˶��_q+�25����!���ߕs�:[H�{��W�o��N��0T�_��EQ�n�cb�&בyUY{��q��b�/��Cw������L~ߑ��:o�4���1l�Upj�QXW�w�lrc�$�}��fv+t����q6ɪQ��>G~�ӣq���GO�K�a�[yF��gV��J�8���D�%���c���a�ǩ<yi�c�(���2���q��RNĶ�%AnZ-}��Z�EK�t���ʼ�N��"����[�_,�&�_E���mY۰�n��S�l���iO��a)f̞�U叮���j�tY6�$�K�;�\rdI*_�pfNk��>W����迱տ��X~N<��l�^�E"�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   H��Qا�b��wV�x3��"�}V5e�r��-k�C�iI�qj����>Yձq��磒���ؽ�o�٧u�J��J�#|�%�X:��4�Z���K��c	x��;2��/'�5WS3��d�s��UiUp{pZ�2e:��>0jUh��{23�Gs)ܹ6�&{���ꬕ���{��;�x���/������ɳW'Ti�*���~Q��?�V�����}�)?��I�(N,¢�j���f.�ӣ���FcRwٛ簕شz�X��&��<��<e����.�n�Z�K|��*Uo��g�b�*f�>����G)?�*��*�r'$��Ex+R=�CqX�z�F��Z�Of%�Jr��;��)-��9Mu.?�D��\��ݍQX*�Klk��2�"Ru�-J�kK6ߞ4�b_�U�qyod_�M��/�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �kKR:�
�:�&��;��W�EG&c�Du�՝"�[p�OKG�m<�5r�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   cJٚhr�{"�f��|��9w���u��VR��f�i!Cïl�T���/����
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   .�\�b:LDW�qL��|��9w���u��VR��f�i!Cïl�T���/����
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   "����(-��]ߗr�c�O�BqO;���/��W�����,�|
>_�o�q��qon�NIIv4���Kt�lϒ֗K��h��n-[4��P^��%�: �f���p��������k�GR��1۸�q�|�������K�p��N��AG��Pڪ�vE��
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �j��JTj�Dߊ���,-�XԤ�"p�Y�;F���>����M�~UTE��m����Ȼ�ﱩ��6�Q-MI�/�����T~�_��|��-Ew)Fĩ�|����;��m���Enѩ�	j�qؓOR*C�WؼهhJ8)�)yP���Ō���R)-7�Z�P�]���Q�j�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   "m�\�U��i���S�e2���$����#L�6{!���Iɬ������kq����_q�~�V�/�������|˰�����T~�_��|��-Ew)Fĩ�|����;��m���Enѩ�	j�qؓOR*C�WؼهhJ8)�)yP���Ō���R)-7�Z�P�]���Q�j�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   M��B���-<ph�/ܩQ��W�Il��jˏ����Ɣ�qF�H��i�L��r:��Hr�Hm���/H��Zz{��Z]c������]����&]��]ˏ/���(�F�_sO����i�ɒ���Gcܽ��Qݘ�!4������'����j0�8K�Y�)�)n�{�vR^�D�#�mW&���S��N���]dNT�=����I�5M<mc5%�:}LIm��F�ptu>�T�-qɫtZ�i��яR��)F�ԩ���Zwc�S4ѝ���?eb�J��Ӭ�ۑjy�Q��h���$�5���?O����Ie����[���Ŋを�L�v~](����_�Id_�^̩Y�Ū�.؛�h�f�o����r��&��9iػb"�K�;}te}�'�,���c}�[���^Q[�E�̯$�mc��妾����77��6�M�.��M��o�\��I�܂�b���/:},�5M�M�h�ye鿹��6�f2�K�i�ǖ�N�R�ԣ���FXj���7�<7��Z�W,"0P�rTn�J.�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �Ӂ�y`���0+���{���W�Il��jˏ����Ɣ�qF�H��i�L��r:��Hr�Hm���/H��Zz{��Z]c������]����&]��]ˏ/���(�F�_sO����i�ɒ���Gcܽ��Qݘ�!4������'����j0�8K�Y�)�)n�{�vR^�D�#�mW&���S��N���]dNT�=����I�5M<mc5%�:}LIm��F�ptu>�T�-qɫtZ�i��яR��)F�ԩ���Zwc�S4ѝ���?eb�J��Ӭ�ۑjy�Q��h���$�5���?O����Ie����[���Ŋを�L�v~](����_�Id_�^̩Y�Ū�.؛�h�f�o����r��&��9iػb"�K�;}te}�'�,���c}�[���^Q[�E�̯$�mc��妾����77��6�M�.��M��o�\��I�܂�b���/:},�5M�M�h�ye鿹��6�f2�K�i�ǖ�N�R�ԣ���FXj���7�<7��Z�W,"0P�rTn�J.�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ����N�/��Փ�ޕ�4��w�ӧ���aW��(ǖ����62�I��r:��Hr�Hm���/H��Zz{��Z]c������]����&]��]ˏ/���(�F�_sO����i�ɒ���Gcܽ��Qݘ�!4������'����j0�8K�Y�)�)n�{�vR^�D�#�mW&���S��N���]dNT�=����I�5M<mc5%�:}LIm��F�ptu>�T�-qɫtZ�i��яR��)F�ԩ���Zwc�S4ѝ���?eb�J��Ӭ�ۑjy�Q��h���$�5���?O����Ie����[���Ŋを�L�v~](����_�Id_�^̩Y�Ū�.؛�h�f�o����r��&��9iػb"�K�;}te}�'�,���c}�[���^Q[�E�̯$�mc��妾����77��6�M�.��M��o�\��I�܂�b���/:},�5M�M�h�ye鿹��6�f2�K�i�ǖ�N�R�ԣ���FXj���7�<7��Z�W,"0P�rTn�J.�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   僥�N�/��Փ�ޕ�4��w�ӧ���aW��(ǖ����62�I��r:��Hr�Hm���/H��Zz{��Z]c������]����&]��]ˏ/���(�F�_sO����i�ɒ���Gcܽ��Qݘ�!4������'����j0�8K�Y�)�)n�{�vR^�D�#�mW&���S��N���]dNT�=����I�5M<mc5%�:}LIm��F�ptu>�T�-qɫtZ�i��яR��)F�ԩ���Zwc�S4ѝ���?eb�J��Ӭ�ۑjy�Q��h���$�5���?O����Ie����[���Ŋを�L�v~](����_�Id_�^̩Y�Ū�.؛�h�f�o����r��&��9iػb"�K�;}te}�'�,���c}�[���^Q[�E�̯$�mc��妾����77��6�M�.��M��o�\��I�܂�b���/:},�5M�M�h�ye鿹��6�f2�K�i�ǖ�N�R�ԣ���FXj���7�<7��Z�W,"0P�rTn�J.�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   僥�N�/��Փ�ޕ�4��w�ӧ���aW��(ǖ����62�I��r:��Hr�Hm���/H��Zz{��Z]c������]����&]��]ˏ/���(�F�_sO����i�ɒ���Gcܽ��Qݘ�!4������'����j0�8K�Y�)�)n�{�vR^�D�#�mW&���S��N���]dNT�=����I�5M<mc5%�:}LIm��F�ptu>�T�-qɫtZ�i��яR��)F�ԩ���Zwc�S4ѝ���?eb�J��Ӭ�ۑjy�Q��h���$�5���?O����Ie����[���Ŋを�L�v~](����_�Id_�^̩Y�Ū�.؛�h�f�o����r��&��9iػb"�K�;}te}�'�,���c}�[���^Q[�E�̯$�mc��妾����77��6�M�.��M��o�\��I�܂�b���/:},�5M�M�h�ye鿹��6�f2�K�i�ǖ�N�R�ԣ���FXj���7�<7��Z�W,"0P�rTn�J.�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  � (      !1AQaq� ��0������62�I��r:��Hr�Hm���/H��Zz{��Z]c������]����&]��]ˏ/���(�F�_sO����i�ɒ���Gcܽ��Qݘ�!4������'����j0�8K�Y�)�)n�{�vR^�D�#�mW&���S��N���]dNT�=����I�5M<mc5%�:}LIm��F�ptu>�T�-qɫtZ�i��яR��)F�ԩ���Zwc�S4ѝ���?eb�J��Ӭ�ۑjy�Q��h���$�5���?O����Ie����[���Ŋを�L�v~](����_�Id_�^̩Y�Ū�.؛�h�f�o����r��&��9iػb"�K�;}te}�'�,���c}�[���^Q[�E�̯$�mc��妾����77��6�M�.��M��o�\��I�܂�b���/:},�5M�M�h�ye鿹��6�f2�K�i�ǖ�N�R�ԣ���FXj���7�<7��Z�W,"0P�rTn�J.�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  �  ?!�C$���#��DC��cQ�#� ��0������62�I��r:��Hr�Hm���/H��Zz{��Z]c������]����&]��]ˏ/���(�F�_sO����i�ɒ���Gcܽ��Qݘ�!4������'����j0�8K�Y�)�)n�{�vR^�D�#�mW&���S��N���]dNT�=����I�5M<mc5%�:}LIm��F�ptu>�T�-qɫtZ�i��яR��)F�ԩ���Zwc�S4ѝ���?eb�J��Ӭ�ۑjy�Q��h���$�5���?O����Ie����[���Ŋを�L�v~](����_�Id_�^̩Y�Ū�.؛�h�f�o����r��&��9iػb"�K�;}te}�'�,���c}�[���^Q[�E�̯$�mc��妾����77��6�M�.��M��o�\��I�܂�b���/:},�5M�M�h�ye鿹��6�f2�K�i�ǖ�N�R�ԣ���FXj���7�<7��Z�W,"0P�rTn�J.�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   n���q��@<�2�%ENU�\�[���6��*[PG_�������M���mY����1��Z�K�3����ڀ߄�K��]
���qb��xuQ��1]�&*��6�_���\����n��HIZ�� ����Y��W�)2�����I^X{�&OO���d�I��p�3ȋ���6"==��05]�r�zE�`���K}��ڍh��90-xe�~�}L�Vŧ̾��y+����cVۄS �M�/�	H�F�����,
�=���
�e	a�@�ǘ�"�(z_-���
�wA\GXW��?9�,D�@�s���B�#	�ܻ,�~��� W�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   c�bB��*�7�@�źe��P���Z|KTK���͌"�F����|L�7�m�'�eS+��@�A�U�>���V.3.��T�����l<�J_ux�B0�8o�+�*�p%��j�?�ж���R۹�)�6wc��),�����"[�ur���W�sX�@�H�sn8 �vr��QC�ႁ�;H��ʅ��n��#����N�. ��>4L�0 �c3�_��d;u��&�Sr�Ii˙������b�b�N$���-�<�y�Dm++���U�ģ��RG��)4͈n
�L���̢�pq3բ��|�-�Py л�M�iXbmaE�q]��X%�,5Z�.�^��ǉ�w��Zu�ਥ�7���D�b
�ь��uN=�"�Mu�7���1���,~�hn�6�,�5T>�g
�-".��:1�b��K0��D���8����_�,�1ܤ�2�ᠠ���T&G���dNn:�)�8�5��6�)I�Rp\�G�>%Z����ES��	OP���qEi���r��s�/��l'Q�{��B�#	�ܻ,�~��� W�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ؜��b�m�k9�s)�?��ǃ���T��,1�i�- �2J��i������<�n�[�����B?s��i)0a��'
�ʣr�Dz�������^���Բ�3E�f1���M44Y�l�"0���A�f^!Zh�ǻF����5,�|'^�AL:���sX�@�H�sn8 �vr��QC�ႁ�;H��ʅ��n��#����N�. ��>4L�0 �c3�_��d;u��&�Sr�Ii˙������b�b�N$���-�<�y�Dm++���U�ģ��RG��)4͈n
�L���̢�pq3բ��|�-�Py л�M�iXbmaE�q]��X%�,5Z�.�^��ǉ�w��Zu�ਥ�7���D�b
�ь��uN=�"�Mu�7���1���,~�hn�6�,�5T>�g
�-".��:1�b��K0��D���8����_�,�1ܤ�2�ᠠ���T&G���dNn:�)�8�5��6�)I�Rp\�G�>%Z����ES��	OP���qEi���r��s�/��l'Q�{��B�#	�ܻ,�~��� W�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ���&���4q�|
�f:@�=�bTm���H/��;I�W2�K�<�:��1�=���2�N
�"<s�^M�F��i-��RF[��PTѕ���4Nl�/i��F�=��lю��[F-�C!j�����٩������s	b����l��0��Y��w��vϕ���PC>�mY�A�51Λ���OpɅ����9BT����kb�:'�è�swV(�i��ttz��º��68�dӆ��lY�C{>!i�I��q0FV{����<� p�%S�q}G(S�^�:9f+��*�f�an�ێ�e��LE��fp��S���r�=�	G�5��YG�ʮ��g��+)�K-
���Q]%@TLB�/qaI�5�0F�Xǔ�hb���ψ�da�%7A�ܲ���0Djqʺ�Z��FP%R�א��;�@���f���^�p[pvx��+VB0f�Ι���_�\'[4��E�W�N\�a,-v��̨E��,���q��S%�V�,��ꦁ�g��3(�|��[�9k8�
�@�b1ٴ%R��	E�<�,��.�gL��r�8G)����'j�K�j�!�p]S�0ҩ(w=%.e[�~-.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �I�Yn�-�Dm��d�ͅ��NKY3�����Qys��5�F:X�� �.��
m�Z��M�`4^���E]w2��|O?-������h��(6F�=K7ʃ�Pq38�T�P�0�|GCrj,�T�nF�����<#��?����Ģ��9�`Z.U�
�
S*x����vQ�D�Mn���GV�ܤ��������hj&�|�MMS�q��mI|�	aq�B aK�\MJ��5:~ae�D��T��4�fؔP�����=ʃ��F���+���<�_C*L%��8"��:��L�g�
���4����A��CwB��k���^بl��P�\z�D�°��o����S��s
�f:@�=�bTm���H/��;I�W2�K�<�:��1�=���2�N
�"<s�^M�F��i-��RF[��PTѕ���4Nl�/i��F�=��lю��[F-�C!j�����٩������s	b����l��0��Y��w��vϕ���PC>�mY�A�51Λ���OpɅ����9BT����kb�:'�è�swV(�i��ttz��º��68�dӆ��lY�C{>!i�I��q0FV{����<� p�%S�q}G(S�^�:9f+��*�f�an�ێ�e��LE��fp��S���r�=�	G�5��YG�ʮ��g��+)�K-
���Q]%@TLB�/qaI�5�0F�Xǔ�hb���ψ�da�%7A�ܲ���0Djqʺ�Z��FP%R�א��;�@���f���^�p[pvx��+VB0f�Ι���_�\'[4��E�W�N\�a,-v��̨E��,���q��S%�V�,��ꦁ�g��3(�|��[�9k8�
�@�b1ٴ%R��	E�<�,��.�gL��r�8G)����'j�K�j�!�p]S�0ҩ(w=%.e[�~-.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ������v(;��̴��F)���"1���!rkKn2�7iqZgwn��{�\Ib��e���������\�	�Tu.Ⱥ��f�	��r�J`��~)�����9l�7[�!�5W�R�u��e����	��z��y%���� ]U�"O�����jPp������a��21����[�J���Σn�<|��bK�/l�)�DɀPe̱��~
"��r����%�ܦ��P_����&N��^�7��L��j
*RՅ��,
;�g���-�7U�h�8�7�dd1u���Z�w� �X[�	���ars1�ۀ y�:���R�sn\O2ڮl�F�ߡ;8a��)��0LD�).�pi�
�*�0�m��UP��W��� G����:�\O�øJ^���&e5�Q�+��':e�[8�.�+���v#��K�ֿQ�)X�p
�"<s�^M�F��i-��RF[��PTѕ���4Nl�/i��F�=��lю��[F-�C!j�����٩������s	b����l��0��Y��w��vϕ���PC>�mY�A�51Λ���OpɅ����9BT����kb�:'�è�swV(�i��ttz��º��68�dӆ��lY�C{>!i�I��q0FV{����<� p�%S�q}G(S�^�:9f+��*�f�an�ێ�e��LE��fp��S���r�=�	G�5��YG�ʮ��g��+)�K-
���Q]%@TLB�/qaI�5�0F�Xǔ�hb���ψ�da�%7A�ܲ���0Djqʺ�Z��FP%R�א��;�@���f���^�p[pvx��+VB0f�Ι���_�\'[4��E�W�N\�a,-v��̨E��,���q��S%�V�,��ꦁ�g��3(�|��[�9k8�
�@�b1ٴ%R��	E�<�,��.�gL��r�8G)����'j�K�j�!�p]S�0ҩ(w=%.e[�~-.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �n��S����bNV�S�Y�x��q,���ᬥ?P���X>KC�H �<�y�ʐ�W��e���ܟ5�:YU_J^�+3Q�-F���UF*��~�Tl
E��a)��B�{�Ua�%��S0��3,=+�x-��GG��˃�LS`��;2���Q�����#B������?����4�O��:(�/@�n��ŉ�+���-���+��@�����K��w U֠B�R�:P������j�$:A����U�ܬ�|��s||���R%�	�Q��`��꺋	-E^ś��+���AvlOJ귉i �Z�Cp�#����lP�E�.��ͷ �A�!e P�i���{�Z�	r��vƬ��KAIys:��qH�5K��b-i�Ը�d�E{/�+�����4�����
�"<s�^M�F��i-��RF[��PTѕ���4Nl�/i��F�=��lю��[F-�C!j�����٩������s	b����l��0��Y��w��vϕ���PC>�mY�A�51Λ���OpɅ����9BT����kb�:'�è�swV(�i��ttz��º��68�dӆ��lY�C{>!i�I��q0FV{����<� p�%S�q}G(S�^�:9f+��*�f�an�ێ�e��LE��fp��S���r�=�	G�5��YG�ʮ��g��+)�K-
���Q]%@TLB�/qaI�5�0F�Xǔ�hb���ψ�da�%7A�ܲ���0Djqʺ�Z��FP%R�א��;�@���f���^�p[pvx��+VB0f�Ι���_�\'[4��E�W�N\�a,-v��̨E��,���q��S%�V�,��ꦁ�g��3(�|��[�9k8�
�@�b1ٴ%R��	E�<�,��.�gL��r�8G)����'j�K�j�!�p]S�0ҩ(w=%.e[�~-.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��M.'<�ڃ����(fԿRЃ��7h�[�3��.b�{��`�� ��e]|{�#k��EMr%�Adu�?)�D;� sE�8�����Vr)9��W'������������
\�+�1xD�K�bd�Cл�\��M���,W����c�U��e���Z�"k��G�q5B����r�U�{�f����2-�֤̈́_�,K8��)����U��2��j�@�#w[�1v��`�1�8t,x�2��@
�ȶaj��3����)���ID�R3(fhZ
4^���4���Wl+��J�]Eq���R��(kQ��:� �jp�'hCm�hw	�@�r���
���*-_D�}�f
󙻚�]��q3�+p��ZG(Tn�j���6~�&W0�ZH�k�$���q. �40v���JÖt:�Z�%�Z�1&��0�.0j� p:����V�p���C��;��һ/Hȴ�	w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   3��qs' �@���~�p�"�5�/�i|\��=���A��s�<�0A�p����e�Z�!t��q��@׸%�|�[�[���
�o"�!II���������T��w����#IƠ������4�)���Z�<Ǚ�� RcT���R���ѡ�P �6%�t��GL2�M��k�$��J�TR�l��G���R�D�+��A���i�C�����,v�U�k�@�:Ta��w��W�����Z��]���31�[R���>SV#� �K�Ol�g��ׁ��~A'�h��x�jp�'hCm�hw	�@�r���
���*-_D�}�f
󙻚�]��q3�+p��ZG(Tn�j���6~�&W0�ZH�k�$���q. �40v���JÖt:�Z�%�Z�1&��0�.0j� p:����V�p���C��;��һ/Hȴ�	w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �/r`��C]���D�p�"�5�/�i|\��=���A��s�<�0A�p����e�Z�!t��q��@׸%�|�[�[���
�o"�!II���������T��w����#IƠ������4�)���Z�<Ǚ�� RcT���R���ѡ�P �6%�t��GL2�M��k�$��J�TR�l��G���R�D�+��A���i�C�����,v�U�k�@�:Ta��w��W�����Z��]���31�[R���>SV#� �K�Ol�g��ׁ��~A'�h��x�jp�'hCm�hw	�@�r���
���*-_D�}�f
󙻚�]��q3�+p��ZG(Tn�j���6~�&W0�ZH�k�$���q. �40v���JÖt:�Z�%�Z�1&��0�.0j� p:����V�p���C��;��һ/Hȴ�	w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �8R���Ej�/r�q�-�*���/ϧG�a6jt�LTYY����8�5@�i^vC�{��,)�a����<�ܼ+�\�Ļ��~O�px���Ŧ���W�2�}'\T�52�x6�D:G%<9aR�d)*����RԵb�<Fx���A���Jy�|Dq�b�J
*x�4�rK�È����r	�VD��a�>b簦��v3{�mKK+���u�Ss��jy2���16�6�&��6���;��M!A�%+�ƽKt�X�"��5�$�W�+)��n���t�[���q�0`
�&���°ω�i��5*Mn���i���pYF��Q�h�
<�8ͩ����xJ-�b#�� �B��6�a<����
�6$1y}^��8%����(�����Lɉ�p)���W>$��N�(k�+�eW�q���xf�]��(����s>>��?2��yb��Dnp|����P���͖�7��5b��ºIz�`9�X�P
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   "���N���F����)�#*���+���*3/�@s/V�<�����D�x��O(-�#��=��+{��#]�C+�	�t�!��������a80L cw0yMTI�j�3�6�Y~�Kж�����"�2u=�y����Lh��r���3�>��Cv�`�
���9j�{`&�k8YL�%K��4X�5�f�1k��D�2����S	K�X@���{X6r4ʇ��Mn�l3�-K{���^2�H�4̭WB�0=Ss��jy2���16�6�&��6���;��M!A�%+�ƽKt�X�"��5�$�W�+)��n���t�[���q�0`
�&���°ω�i��5*Mn���i���pYF��Q�h�
<�8ͩ����xJ-�b#�� �B��6�a<����
�6$1y}^��8%����(�����Lɉ�p)���W>$��N�(k�+�eW�q���xf�]��(����s>>��?2��yb��Dnp|����P���͖�7��5b��ºIz�`9�X�P
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   0 ���/e�ɸ��P�kN4E�R����k��� �_��sbR��Tƥ W�Fl�o�Hv��>d�,�׳cP7Mbv*dUiׂ�!f��ɂ�z�G�I�^��1��ľ5(�Z]>c���n�d� �q�����UN*�ּD {Mv�=@o~>`u�D[�76�����_��%0��j_�y�~���M�֡ɼK1X��ft�?�
�p�5
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   )���_{`q�(�f��eL���hu��=�0AT�#B�5c�+�H�@</�Y����qX���+�ȋ�&�|Kc�p���3T�F�6zN2��h�M`�A��
�~ڛ�79kX"�S���	�s�ax�09�1�""ߩT09(]F��㨌�v�
6KR�i��J�>J�E�0�;a6��3�y�~���M�֡ɼK1X��ft�?�
�p�5
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   r�Ynf��.l���tv�������壔׎J�������kԬ��8DsN *��R'ɊS��p��Yf���a��64�U����j�|?� /��"���(C)� ���� �+�s]�J����+bR]���]�pB�¥FG��IM��J�2[��ko��Fϧ�%oc���T����^f�#.T���J�����)�!
bk����]>c�C�<O-�,5<U~e� �Ǒc��ʣ�� #;
�p�5
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �:!
�쯗"��W������[.Z.%_�%Z������$n�����~���.�ks��rÂq i,���nZ�W�xLU�ܗ��i?02�0a[A��_�7"�CF�,�/�ơ�x���]�r Tҍ���>:�EG�i���J���0Y�˽%��5�{�נ�;�s^&�.�|z.��D�eb�(e�{����;"����u���x�
��q��g=�@��/	]�泎W��]��R�{>r����J�w\'�h��+[s(�	�/&�W�T��\W�J�E2"�&�9W��'���?&=B���Sy��-5�Xbɏ6��QPj췘X5�jj�[���.-#JX�۰c�p�);�2Ǡ��ƫ���(����s>>��?2��yb��Dnp|����P���͖�7��5b��ºIz�`9�X�P
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   Q���*�y�8���J�pdSl�`�F^�+[4�@�$�Nc���
�쯗"��W������[.Z.%_�%Z������$n�����~���.�ks��rÂq i,���nZ�W�xLU�ܗ��i?02�0a[A��_�7"�CF�,�/�ơ�x���]�r Tҍ���>:�EG�i���J���0Y�˽%��5�{�נ�;�s^&�.�|z.��D�eb�(e�{����;"����u���x�
��q��g=�@��/	]�泎W��]��R�{>r����J�w\'�h��+[s(�	�/&�W�T��\W�J�E2"�&�9W��'���?&=B���Sy��-5�Xbɏ6��QPj췘X5�jj�[���.-#JX�۰c�p�);�2Ǡ��ƫ���(����s>>��?2��yb��Dnp|����P���͖�7��5b��ºIz�`9�X�P
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��P��"�GR���/<(�k]L��){#���N�uњ`>
���6�Y�1�Tҗy�&��2Ԟ��%*5S5<C	�Irm�,�(�ݏ��,�$$Zဉ��D�S���(9��r9y�A���Ku�*<��?�f1<�3�V�2â�-�c�����b��LV3^�+��R��|ܼ᫮Q`h�S�;��eÞ���6v`��-��R���?ܪ�)�
lq�N�����.�c[�����Y�C���J�&���dZ��'+�!�y3�Ub��-צ	��N=?�cna�
t��Bzl>"y�E�M��=��q��A�&pُ���7�7�ǴIp肨.(�,˦����&�P\�%����E�ť��s�p��łr�̣Q�G*A������M���� N�A�7�o� �týL���f08�� X鹂�N�O����.Xk"���4�	n;ʵ,��JV�93sM�u����U�l#�8
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �5�%���J�{n*i���YT!�u�.k�j�w�Kq�t��A.B�c���w�Z��ܺ����tf
��g%��-��WV��Ɠ	ъ�k̾�S�VX��F���#���<ȍ� 㙽�'\B���n%�:n �<HtH���5�/�#�?�����әz�4_�#,ѩA y���7
���6�Y�1�Tҗy�&��2Ԟ��%*5S5<C	�Irm�,�(�ݏ��,�$$Zဉ��D�S���(9��r9y�A���Ku�*<��?�f1<�3�V�2â�-�c�����b��LV3^�+��R��|ܼ᫮Q`h�S�;��eÞ���6v`��-��R���?ܪ�)�
lq�N�����.�c[�����Y�C���J�&���dZ��'+�!�y3�Ub��-צ	��N=?�cna�
t��Bzl>"y�E�M��=��q��A�&pُ���7�7�ǴIp肨.(�,˦����&�P\�%����E�ť��s�p��łr�̣Q�G*A������M���� N�A�7�o� �týL���f08�� X鹂�N�O����.Xk"���4�	n;ʵ,��JV�93sM�u����U�l#�8
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �D��)s�g,*]#)׷�K�WX�i�r�������s(
GD d�h/�ı�^ �1Pw/�>�Y&z���èFЋ�
��Z��5�V�'��x�/�_W_�s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   O�`ܠ+��\\A��5��9�ZS��`�L�W9�w�k��(肸G5S�A��rm�Q��1�YbB�u-&���e� |��ݛ���e\�Cȇ�q�  Pq.����&�Ǫ���(dɽ�Qj+aYl��T#���ۡ3}��r�P:�*�R���_����q^��j8��&��8\c�̷�xgJ�|F�ĭldJ2�����7Jݐ�M�x+��0"/I�v��/�]&�i�i(��7ˣ�2�۸��l�]����	���sY^y�������`�z�j�j��҉�ʾ���C��ѿ�[1��/j���G3R�+q�[��U�̡�V�p��R~'�{�;��5/��	�r����rf̪Ә�����;�a���2d�j0@
��Z��5�V�'��x�/�_W_�s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   *n#��@ő�s�=�������	M$�T-9j��Ɂ�_��+I�����s�*�r�Ѩ 
:���<VB�#��e��Ye��
�%J��Wҥ}v��P�������k�h���\�E�nA��C�}---/�_Ŀ�yyyyyyy�yin廖�[ܿ���8\c�̷�xgJ�|F�ĭldJ2�����7Jݐ�M�x+��0"/I�v��/�]&�i�i(��7ˣ�2�۸��l�]����	���sY^y�������`�z�j�j��҉�ʾ���C��ѿ�[1��/j���G3R�+q�[��U�̡�V�p��R~'�{�;��5/��	�r����rf̪Ә�����;�a���2d�j0@
��Z��5�V�'��x�/�_W_�s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  �      �|����~�R��?}���˫W�����}^������F=Z>�ƽ�����y��
�ݤg�~��;+n��W8Q�r���?Ctq�-�|��7��w�xc#�c��gx��s����{�x�����fs�
DEY�_m���=��˕]��U���,2��X9��:�f.:я\�+�}9��{�.1t�5ŗ��b�I�E�b8 �6���7���O"}�~�i����ah�xD�tk)j���3�����4�V.|CqO�#6a;���>�@U��u���|�|><�w_�j9���A������3��7s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   _�`�C?AW��(�)�t��,9����g��'�����hte�7��.�*͈��E�P*������Ï ܋��r�PS���
p�j,ؒopTrW������Og�� /��=l��7���T���d��.?ÑY�u�c�η�Ei��u�1��M�����Q�b~�뽵;.�{G��٧���]
�ݤg�~��;+n��W8Q�r���?Ctq�-�|��7��w�xc#�c��gx��s����{�x�����fs�
DEY�_m���=��˕]��U���,2��X9��:�f.:я\�+�}9��{�.1t�5ŗ��b�I�E�b8 �6���7���O"}�~�i����ah�xD�tk)j���3�����4�V.|CqO�#6a;���>�@U��u���|�|><�w_�j9���A������3��7s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��k�,!<|N�`1�s��(o'����%v��X��U���-����R ������������+,Bc]��	Z���Vs�B[�S�j,ؒopTrW������Og�� /��=l��7���T���d��.?ÑY�u�c�η�Ei��u�1��M�����Q�b~�뽵;.�{G��٧���]
�ݤg�~��;+n��W8Q�r���?Ctq�-�|��7��w�xc#�c��gx��s����{�x�����fs�
DEY�_m���=��˕]��U���,2��X9��:�f.:я\�+�}9��{�.1t�5ŗ��b�I�E�b8 �6���7���O"}�~�i����ah�xD�tk)j���3�����4�V.|CqO�#6a;���>�@U��u���|�|><�w_�j9���A������3��7s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �>1A�7�	����=��A��_�7a%v��X��U���-����R ������������+,Bc]��	Z���Vs�B[�S�j,ؒopTrW������Og�� /��=l��7���T���d��.?ÑY�u�c�η�Ei��u�1��M�����Q�b~�뽵;.�{G��٧���]
�ݤg�~��;+n��W8Q�r���?Ctq�-�|��7��w�xc#�c��gx��s����{�x�����fs�
DEY�_m���=��˕]��U���,2��X9��:�f.:я\�+�}9��{�.1t�5ŗ��b�I�E�b8 �6���7���O"}�~�i����ah�xD�tk)j���3�����4�V.|CqO�#6a;���>�@U��u���|�|><�w_�j9���A������3��7s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  �            !1A aqQ�@X��U���-����R ������������+,Bc]��	Z���Vs�B[�S�j,ؒopTrW������Og�� /��=l��7���T���d��.?ÑY�u�c�η�Ei��u�1��M�����Q�b~�뽵;.�{G��٧���]
�ݤg�~��;+n��W8Q�r���?Ctq�-�|��7��w�xc#�c��gx��s����{�x�����fs�
DEY�_m���=��˕]��U���,2��X9��:�f.:я\�+�}9��{�.1t�5ŗ��b�I�E�b8 �6���7���O"}�~�i����ah�xD�tk)j���3�����4�V.|CqO�#6a;���>�@U��u���|�|><�w_�j9���A������3��7s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  � ??�JTi��~3�(���S��M�3�GS�"]|S�WQbj1�4,i�	�bSD跱?�E�	R�(�N��M��9d�OF�GѧkF�EAP���8��P�M����Һ}�Ѧ��D�����Z6�^�iW�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �O��70b{��3Bui����pJ�ESi�\{E;OX�cLV��}�������펵pU������(�r��zg|A�� ��ma������i�7����<ѡ���c?K�ۊV�}'�1���!�V���gB1�����n���lm�{�k
�1=�'���y�֑`j

l�U��;bn�]p���Gm���\�'��%Zv�&C�1!�+��h��51�zi�����-��t��N|T��_��_�P�]J�)S�w	VG��CA4��N��8�b�Z����Md'�C������Rp��]����<Vb𰫰�BŜ��	���Q�f�yD����	�Z��>ŃM�'�IB	)���h�}���*~��}"2��s��vD�����!�t�&��ޏ�|$�6Rp��LlQS{1��1�Q*��&e]#:>���%;"쭖|�]�2��ӣ"><2�'F^#���M�GP�i*�H�M$'^���Z~
t$���h4�1�CI�ZeN"oG
��H]Qb�%���D��lJ1[���FHw��kA�GN��ًq�0�/���
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  � '        !1AQa q�����������}�������펵pU������(�r��zg|A�� ��ma������i�7����<ѡ���c?K�ۊV�}'�1���!�V���gB1�����n���lm�{�k
�1=�'���y�֑`j

l�U��;bn�]p���Gm���\�'��%Zv�&C�1!�+��h��51�zi�����-��t��N|T��_��_�P�]J�)S�w	VG��CA4��N��8�b�Z����Md'�C������Rp��]����<Vb𰫰�BŜ��	���Q�f�yD����	�Z��>ŃM�'�IB	)���h�}���*~��}"2��s��vD�����!�t�&��ޏ�|$�6Rp��LlQS{1��1�Q*��&e]#:>���%;"쭖|�]�2��ӣ"><2�'F^#���M�GP�i*�H�M$'^���Z~
t$���h4�1�CI�ZeN"oG
��H]Qb�%���D��lJ1[���FHw��kA�GN��ًq�0�/���
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  � ?�\��iae��Z�L�>�Q�b)Psq^�]��^��\P�2��0�6������-f��-%�"p�p���rʣOr���$B��ܷ\PM�E�����s�uAu�Yb�\K�d��� ѰWR��U�6]�wm�{�k
�1=�'���y�֑`j

l�U��;bn�]p���Gm���\�'��%Zv�&C�1!�+��h��51�zi�����-��t��N|T��_��_�P�]J�)S�w	VG��CA4��N��8�b�Z����Md'�C������Rp��]����<Vb𰫰�BŜ��	���Q�f�yD����	�Z��>ŃM�'�IB	)���h�}���*~��}"2��s��vD�����!�t�&��ޏ�|$�6Rp��LlQS{1��1�Q*��&e]#:>���%;"쭖|�]�2��ӣ"><2�'F^#���M�GP�i*�H�M$'^���Z~
t$���h4�1�CI�ZeN"oG
��H]Qb�%���D��lJ1[���FHw��kA�GN��ًq�0�/���
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   	F�`�͈����~��a��PH�*��h
Q� u�]L���k��[*X�o�(!��Z�U�
`�y����D-٦*,,��������&�C�����-�ɭ�%�ىm�E�0V�%�2���A�����b�R�K'�n*\Q����[��b43
�Th
J�j4,*,qL�3���*9��*>-���9n�10j�~�TP�����an��H��J*�a@Z�qu�q��+ڄ4�1�ޠ���)R����J�~ɠ/�VG��g�x۰�#k*�K����������B��SYa�K��BТQPJ�EZa�����JWh5%J��Oq+�KR����,� 	D�������E�]��
�8q W�5���#{өD0��~Ai�H\��B�M�*�+�J:����i��ƌ ���ߨh����b���I���0���􍜱<u	8 ��P)( ����"5^҂<2�0��d����5ry��Qc��T�E�'d�7�1�Q��=���]�Y��7�[�9s�Y��|��R�\Z�ڙ=?��H`M�ܑ<W1!J�PU9�T��ɔ�*<B�4�\�?�.�����-C��]�#O�xP@Kg��?=FԷ����*_�{x{��~l�r�j����ǸqK=J: W�D���˄[.:WYp鄺o_�+��h�:N���%j�l�4nLF �K��PQ�;�����
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ܦV61�{E/��*��Ә�M�*��f#��P�{�����Eo����f�'QY̍`�~cx;6*ip��P���и&Ȫ�;��}��X��ͿH1�5{�TAv|q8��f1W��pkWr��9��t�)�F-F*Ѫ�!�.������rp,��qj�������&�C�����-�ɭ�%�ىm�E�0V�%�2���A�����b�R�K'�n*\Q����[��b43
�Th
J�j4,*,qL�3���*9��*>-���9n�10j�~�TP�����an��H��J*�a@Z�qu�q��+ڄ4�1�ޠ���)R����J�~ɠ/�VG��g�x۰�#k*�K����������B��SYa�K��BТQPJ�EZa�����JWh5%J��Oq+�KR����,� 	D�������E�]��
�8q W�5���#{өD0��~Ai�H\��B�M�*�+�J:����i��ƌ ���ߨh����b���I���0���􍜱<u	8 ��P)( ����"5^҂<2�0��d����5ry��Qc��T�E�'d�7�1�Q��=���]�Y��7�[�9s�Y��|��R�\Z�ڙ=?��H`M�ܑ<W1!J�PU9�T��ɔ�*<B�4�\�?�.�����-C��]�#O�xP@Kg��?=FԷ����*_�{x{��~l�r�j����ǸqK=J: W�D���˄[.:WYp鄺o_�+��h�:N���%j�l�4nLF �K��PQ�;�����
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   h����� �V(��?��^�������r���9�Q��AQ�dM%��,��])��N�s0��Dy�ar�>��a���1�-�U��5�K*�G��q�=A�J�`	Oi���0�:�/��~ �2�z���
��mع�LG�҃eS9�����a�� W�jo%���S��g�(V�v����J`i }�bYħ5r�u�d+�6�Jn�^���n��v�cɑ��Ń�`mUa���J�
-�1AA[�p�S�0i(�`�I�s@ש�S�ن��.Q.
4S�P[�_A�(7 [
1��f��)Md��P������
�w Ռ��"P��m�PQ��u(`v7B^����#�@��]��%3��)��U/ǈR��Sߛ�-n]0G��2�0H(�.r�"�	M�
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  � '      !1AQaq��������� dM%��,��])��N�s0��Dy�ar�>��a���1�-�U��5�K*�G��q�=A�J�`	Oi���0�:�/��~ �2�z���
��mع�LG�҃eS9�����a�� W�jo%���S��g�(V�v����J`i }�bYħ5r�u�d+�6�Jn�^���n��v�cɑ��Ń�`mUa���J�
-�1AA[�p�S�0i(�`�I�s@ש�S�ن��.Q.
4S�P[�_A�(7 [
1��f��)Md��P������
�w Ռ��"P��m�PQ��u(`v7B^����#�@��]��%3��)��U/ǈR��Sߛ�-n]0G��2�0H(�.r�"�	M�
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  �  ?��ϟ�P2�ª�Mq�@l/ �ū����U
�#�G*;�����a��\\�^y�ar�>��a���1�-�U��5�K*�G��q�=A�J�`	Oi���0�:�/��~ �2�z���
��mع�LG�҃eS9�����a�� W�jo%���S��g�(V�v����J`i }�bYħ5r�u�d+�6�Jn�^���n��v�cɑ��Ń�`mUa���J�
-�1AA[�p�S�0i(�`�I�s@ש�S�ن��.Q.
4S�P[�_A�(7 [
1��f��)Md��P������
�w Ռ��"P��m�PQ��u(`v7B^����#�@��]��%3��)��U/ǈR��Sߛ�-n]0G��2�0H(�.r�"�	M�
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ���>c3�ʱ���QF� ��9h��.;Q�������ؠ���fjGW�U�u�� U��X~���ʹ��/qq���hղ�6��E�>��^�q�dN��Z��Ʈ��+��W1�fه�fR���(*���=n0R�?�b�T.�՚X�x i�+O���ΟԼ	J�E���V�;�錿q���R�U.�R� +UR��~�h+�
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   Q�a�%FU�C�|�Z��������Zj�������E6� L5-���Vz�m��[�/���A1�+��T���˗�u7��(PLؙ�g��ʯ�źee�(Z�|b5�7E޲�&K���WN��E�`�?|��><K������x�bZ�,������<F8����A�1�hy�]��㸶!���`?�ڨ�qs-���y�Zց�m<5jP�@veH[��r�I���aB@��E۱��a�eM��z���G�P��"��;=�����vlX=�ʹ�fl0x�5�:`���H��[)�~�p%���=��8q���:V�GB�/S}Fw�d���
��W?��qo"u1�@�Xh�E~a�ٵ�|�g�p��� a�v����U��T �;qY�%�Q`p�H�,�K���ǙYF��&^0<�~"Ń�8�F|�js��2�C��v`')߉1k���:k.�>[���/d���̴Os����%E���kvY(�\m|zpa��Z{�R��k:�Q����)�e�x'l&YJ	@jS��DV��m�Ng��Z
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F    R"�QL̚P�P@հ������Zj�������E6� L5-���Vz�m��[�/���A1�+��T���˗�u7��(PLؙ�g��ʯ�źee�(Z�|b5�7E޲�&K���WN��E�`�?|��><K������x�bZ�,������<F8����A�1�hy�]��㸶!���`?�ڨ�qs-���y�Zց�m<5jP�@veH[��r�I���aB@��E۱��a�eM��z���G�P��"��;=�����vlX=�ʹ�fl0x�5�:`���H��[)�~�p%���=��8q���:V�GB�/S}Fw�d���
��W?��qo"u1�@�Xh�E~a�ٵ�|�g�p��� a�v����U��T �;qY�%�Q`p�H�,�K���ǙYF��&^0<�~"Ń�8�F|�js��2�C��v`')߉1k���:k.�>[���/d���̴Os����%E���kvY(�\m|zpa��Z{�R��k:�Q����)�e�x'l&YJ	@jS��DV��m�Ng��Z
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   P%9�(\�Ĥ�{�Y��KN����>��	D*����A�|�(&�B#D[���A���X�l����G������x�X����*�g����t��>*��^+�c���h� X�d����c�PH����ʽi'���4f��ՠx�|��5�+#]��A�^�O��X����Q!,i@�|�KH�K���s���2��pD�J��q2�U�� p�=�r��N�-g(s�!J�8Y�����A�R�y0�V������E@[¯݃p1l��Ĩ�4/]@�]_ ���6u�'A)�;~�B�?�a�J~	Uw�1������j6��Ƃ��q*�o~�]P��=K�[vH:��h�s�],��n%bg��G�h7����V
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   Q%���C�R�X�S��w\ʏ\����^y�a|b����7ia)E6�{"dQR��>KK{�ځ���u���BrJj��&��u�bIS`�^&:*�3U�V��4���bDZg8��#����W8 r���2bo����j���/�:�4}e
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �)�h����4j���j�w�R�Xu���X���@��,�.��-*����r�G^<C��A�9�؉�5����07�Y�f�^e�'���{M�a�$4Bu=��R	pr��:��m,�o�������fŗ�1�؋���a�L���R��p���`�Z
�G:G3ұ0�L��0[����b��y����^1 �Ȧ�׸��6����|����	ߘ�PU^q̱1V�P�;�v��Ke]�,-�����q�x@E��1�@�R�p�WV�����#(ե� |֌�������W���Q��
̲G,(�)�N��j���z����H�@�y�JF�[S�0F8o"�^���H#�f�� ,
�9�<wp�AՎ�_�P�f �C����_OQ��{�z����͚�9�(��#��|���(8J�~#Ľf�\�@=���T����B���}f8�#ޣ:ڼ�a�9�� ϹU�MT7��<T�)I�?s4�����ϑ�F�Qx����_d.Q����#2���edU��M�ij��l\g/���"ظ��;6��XBꝚ�l�+��S�&7,ݠQ�)�����<.�����!|_oe�LX�h>g�{v��t^�&�`pb[�������N	�Y����6p����+{�U���5a� ��:��z��lI}�xAv�,�XO��5��{�����@��]��I���X�F�[�<* G"���q�4Q�{��&�K�y����xY�<��l�a59K
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   X ��)8}�
U��+F.��UE%�K@��E�u+0�����~߀�+$֑s��m�����[-�z/�(D8)q�Q����gO���������+��꓈�.�e�%*O�� 쑣�n��JC�w4��KW�m���¥�k��0�yxc7�p���G'~#�� �c�@D�vDu��wN��׸��6����|����	ߘ�PU^q̱1V�P�;�v��Ke]�,-�����q�x@E��1�@�R�p�WV�����#(ե� |֌�������W���Q��
̲G,(�)�N��j���z����H�@�y�JF�[S�0F8o"�^���H#�f�� ,
�9�<wp�AՎ�_�P�f �C����_OQ��{�z����͚�9�(��#��|���(8J�~#Ľf�\�@=���T����B���}f8�#ޣ:ڼ�a�9�� ϹU�MT7��<T�)I�?s4�����ϑ�F�Qx����_d.Q����#2���edU��M�ij��l\g/���"ظ��;6��XBꝚ�l�+��S�&7,ݠQ�)�����<.�����!|_oe�LX�h>g�{v��t^�&�`pb[�������N	�Y����6p����+{�U���5a� ��:��z��lI}�xAv�,�XO��5��{�����@��]��I���X�F�[�<* G"���q�4Q�{��&�K�y����xY�<��l�a59K
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �<EK"�]�uS��<�Eޠł��'��Q��p40�虴�y8��>!�Q?k.��)��9!�����`��8�)�j�at
]��5��!`�������&��G��խU�Gdc�����3�"�O2� ބ+�>����#d%i<����&wZ]1�)�r����+%��� #�?������>��H  b_ �6P�,�7�1��	��qd�Z�5��e��ʥ�,G8gr��� ���p.��4s]D�Vi�x|J�Wa�E��%�T!Ez�fGq�����]��Q<���E`�8W�\�����{�\J
+�l�p_W8��~�X�H�պ��	�i�oE|�*�/�����;�n�uA�Nb(��r�`k��  6%�^FT�Gl�X,7g2�Z%������@�ҹ̲��~��0Z�_�
�k;D(�vP���X��}b�⁧�,\�klSa�osdZ0.�)���`k 1�opF׋r�����a���խ
�y�A)�=`�
-����g"�\���a�dٸQn|�WI�z3p@(�Υ�]��wG�<��,!�������߂k��S�
M+C�^f�����>Xt�����䇟��p.��m��^�#���ՙP�*���54��F+'�8#�;6y�,���U'��Y��l���v��]���4fTm�e,`<5���XU������_�@cmց}��v���itz�<w������C����TlU���/̻�� �����}g0~�ip@��wPT7�g��꡴H�
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��w:M3���Ā(����U~�\�84/%^7�Z} ��%��F��ѯ�B9<��Rƣ!cAD�;e�k��,�Xh��}./��7���2X6���V
N�XZH��1�=��*Ń�y\��E��g�Y](9d�%�<��F��-����w����@P5�cř4�kG�ƒ���.����ks���S��˗e��8�X���&�<QWa�*�o�>�"[VZ�4U�[n����L��7����h�y!��y�^f"OJ�G0�S��,l��Ń}*T�bǍ��in1v���e������ש~���a(S]Y�PLwD@C�����j��R�*��}B��euS �G'���R�~~ ��$|��E�a��,��5󊨉Ge�k<K�+C�=�)�[0W̾�j��#9����ړ#W��"�������� �ClU����^��
���C��0����ԛ�t�"��hm�5��|�}����]a,�"*�N����[	��L[ �[wY���! >�3o�JJE���j���#)��C׸@�U�c���gw��_ :�b�s��&qkA�	�
-����g"�\���a�dٸQn|�WI�z3p@(�Υ�]��wG�<��,!�������߂k��S�
M+C�^f�����>Xt�����䇟��p.��m��^�#���ՙP�*���54��F+'�8#�;6y�,���U'��Y��l���v��]���4fTm�e,`<5���XU������_�@cmց}��v���itz�<w������C����TlU���/̻�� �����}g0~�ip@��wPT7�g��꡴H�
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �	Wm��1�U����@ @Ptq*��Ħ����奌j-�o��]̒�����
�N~�B��
X&�
6?q*����ĕ
���C��0����ԛ�t�"��hm�5��|�}����]a,�"*�N����[	��L[ �[wY���! >�3o�JJE���j���#)��C׸@�U�c���gw��_ :�b�s��&qkA�	�
-����g"�\���a�dٸQn|�WI�z3p@(�Υ�]��wG�<��,!�������߂k��S�
M+C�^f�����>Xt�����䇟��p.��m��^�#���ՙP�*���54��F+'�8#�;6y�,���U'��Y��l���v��]���4fTm�e,`<5���XU������_�@cmց}��v���itz�<w������C����TlU���/̻�� �����}g0~�ip@��wPT7�g��꡴H�
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �(�ˎb`/���K�'i� 47�/=E[�)��0i#et�x�(�@oBu��++���q�ӳ�r\�H�y��ώ�R����%��O#�0�Q��IνC?�b����=���R:Ώe6���L6k��4ڰ��X��+#
ۢ�X:����#���"�����D4C��?2����(ה82���P��
��3�y�d���1N�0J�Y�O�:��,����<�� �ȇ_h���(�dH  ���T��h���Vݾ��^U�_ܧ�}]�������X��\v��z���O�t�B R��.1�%]�����'�8[eEF
(�NH���BϹ
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��$Ʒ镡M�~eM@��4���.Z�z�˫��E����m��L+�,Q:a�m_��F1V�```L��-w��N����V�vj�na� �νC?�b����=���R:Ώe6���L6k��4ڰ��X��+#
ۢ�X:����#���"�����D4C��?2����(ה82���P��
��3�y�d���1N�0J�Y�O�:��,����<�� �ȇ_h���(�dH  ���T��h���Vݾ��^U�_ܧ�}]�������X��\v��z���O�t�B R��.1�%]�����'�8[eEF
(�NH���BϹ
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ���y9b%�q�@�7���/�7�o�Sc���<K���?�B��%`�2\��b�7x���4���E���2�����K<��'�]eY�r�R��Y2��)�\�1�3�:�b\�Ha��J�L���7�N�0b�.��ܤp�ű>z��q�onHV�AP;���jÃ�A��˯l  ��G�G���_�@:x��Szx��[Ә{ƘjCW
Fl���,��H;WW_�-�Z�"be��L��=ʿ���>]C�x5ᵁ@��+Lb���g�@��PQ��\G�O���R�" �J
ۢ�X:����#���"�����D4C��?2����(ה82���P��
��3�y�d���1N�0J�Y�O�:��,����<�� �ȇ_h���(�dH  ���T��h���Vݾ��^U�_ܧ�}]�������X��\v��z���O�t�B R��.1�%]�����'�8[eEF
(�NH���BϹ
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �|��Gs8��E7+��Σ_id�h�Q�+��ez9.=�Vs�?�`�PK�����\s����Mz���,ټ�>+Ռ�� �A"L�Bo��@T��}CT=�}��V��8�q����i��_�}f(%@W��>�󊾗QM#�L;]�GJ�c-�W"̗���A�DO�z��_�7�����؉:����4V<"����wdٻ;���g���dk�'"�gy/�e��NzIkS���,����qs�*��Tz6�dC	U�s_T]���h�J�Ac�!�)�Ǧ�e��ն�w�/�ů���/R�Ϙ�m�pr����?#<-����g�^��� d>3����*^�Y�l~��ĭ!����S���>7�%?́}�L�,�G��^b��)�#���
(�NH���BϹ
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��a��?���u���s������k��J�xk0��7(c5F\�R�j��^!���
E�
p�̹�r��Pk��ۥ� �tSG`�J8��Xt�*Y
����xa�#��>kN����l
E�(��g��
�U���g�^��� d>3����*^�Y�l~��ĭ!����S���>7�%?́}�L�,�G��^b��)�#���
(�NH���BϹ
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   r�
�k��eaTl�ۜˠڟ��Vc%G�a�uC&�~�J��C¿R���(���v��֜���N�Y� ଅQ��� ���4@�� �যZ��G��5����1�H���8:�N�J�A�=U
�������@d�>�������'���䌐MS��)3��9�1X,�V�`$�)��O@_Υ�Ȑ������y������!{�9�{��zy�eGeנ�,lDo��$@���ϩx�6�H��D" ����b���#Ϸ��*0�Q���%<*,t�8��wn^�<����"&E2/�,	��]Cvf����W�8���zz��\�������ς=-C��E��(U\S�$@,�m���@uN%��
���1?)kΤJ�0c�N/�VqΔ���ѱ��h�>�g.�g�5D081�y X,���k\j+��&~:�-sN�'����Ɯ�����`}2��p�B*��1�.J)\/R����5O�pp�j��cP���f�a�t>�f���^bp!�
�1 ������X��0��b��Pp/}�	�\���:����<KއF��P��G���=�\B�[
�nZK�lci^�;Ħ,����|>op�9
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��'�2�k̲����V',	
�4�;=���R�^y��L�����{�/j�Q)��v��?d3ג#��
�T�����
�/�h�Ӗ�N`�L�:��Y�����g�9� �P�;8��*�-�9��$E�4�p��H�M=.�w~��ڋ��0)
�);XX�� ��DD#,=��ֹ��-]�aB�=_�/F�`n)<�xH����8�A��՛��2ͯG��[%k�eNs�d�~L#��0���{������k\j+��&~:�-sN�'����Ɯ�����`}2��p�B*��1�.J)\/R����5O�pp�j��cP���f�a�t>�f���^bp!�
�1 ������X��0��b��Pp/}�	�\���:����<KއF��P��G���=�\B�[
�nZK�lci^�;Ħ,����|>op�9
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   e�\����(����-<ER�\Di�zF��r2�-!8� >T@��ɝ'�#Ҡ�*����.��@j���	Y>^H*�WGcƝ�V��UީEo��-n+ʴx�MՆG����6S������H%h�wv��YmA������}�о`n��k�?69�>��)�y��δz���p]ʦb6Հ�vJ<7�{et~'��ڞ`g|:.�1^�J˚��M1*�OM�����a��!���v�&_S��Dc���r�2���fɭ� #'�=¸AM�v4`��fz7�0����M@`C���D��#�Q*��~���� &^
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   X�&�\g��(�tW���M�q1,�Z��!Ht��z�|�b� fV�Ju�
P��
�b8=�	.
BY�G4=�-�^_������:�����"�҃Tuв���'�R�-[�8e.;�x��rX^�0J�}�p���+2ޱ��q���{�(��Ը�p`48����W��Խe��
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �����ss#J�R*}��N����&T�-p�eEX��!���z
O��=��^[���`�<K+���1�梢�����9�=�l�i�}%����ec%�]@x�S8�;�S̓��xnQR�v���0X��3Z1*��n���3�uQ�&=E@���
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �By�逭}�)/8���O5x�gm}
�b;����Zɬ
�T�ғź�X�.�eR���7
�G�M�3����b�ƫy}E�7����۷�'��i���<^b܃Bv�uQ 71(���R�0N<��B�Yq�r�[](.��/�r�y�G��n���zkG��p����`r5�%�R��Xs�i/p���.�kF�h��-x嚨Շwqp���~`�h-���"]����1�꼡�?� �K,��u�(�L0,�%Y�HŸ�Q6���s�-�a�v��K���!�X����V�0�ۓe�$+؀�yr�9���
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ���MJ��.�#�q3�P\���P'��~(Ϝ6җ��v�����+����l�D�'��Y�Uŵ|�TK
a�z���)A:�tp�-�M��#Y
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ض����
|2��Y���B����*@֧Ql�����T�������V�Xsgv�!� � k/�����4��/(��tp�-�M��#Y
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F    �|��߉�v��O����,��������]��T`'u�����zr<'w(u.~X��( ���L�.^����4��/(��tp�-�M��#Y
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �=�<k���
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   3�iU����F���@3��X��N7$z�������7�=C�����r��
�8Hbl*��$0�J�O�؊�JA>%�s#J�a*�bҬ���W�{��l�w��Z9V`Im};_Ԩ���7�wET��]EF��e�@�~`) '���4�{����OR�5"�r��	�`*�]�%j������\32[���7]�Y��>D�&�Uy(���R�0N<��B�Yq�r�[](.��/�r�y�G��n���zkG��p����`r5�%�R��Xs�i/p���.�kF�h��-x嚨Շwqp���~`�h-���"]����1�꼡�?� �K,��u�(�L0,�%Y�HŸ�Q6���s�-�a�v��K���!�X����V�0�ۓe�$+؀�yr�9���
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �`�,s�1mtGb��؃b��������Ħeb�p�J�����d5SpZ��#�O{�8!��y�Y�>�K���K�:��l�<��.⬺���)q-q�a��ݘIΞ�2+ i��b��.e_�1 x�|3���;/F��;����
���D,W_�h�#�1n����=�;�d%俴����z��Z�iY@z�"J�r�	�ߏ��Eu��8�U �ef�T!P^R�+���~����F!ow�| �� �	 ևwǉO�O�Fƃ�
��G��In�JEO�Ur�k���RI�ʇ�]���!�ք��Ob&��nWx(9�ԸPt^X�����j1wl�OQd�����h����I\��OF�:���
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ,��a6��8�1ڋP�uqp�y������P�j�l����JUv�b%�W�'��V-����w�z����)�t�M4����l*�7���=u,]f���L��Zq���+��(�M���}�Pz@x�(>��j�X�6^�>b�i� �0���O���l1G�������ym��@ �����ihϤ>Û�t��x���R�Kp�JX���ҵ���ܑW!P^R�+���~����F!ow�| �� �	 ևwǉO�O�Fƃ�
��G��In�JEO�Ur�k���RI�ʇ�]���!�ք��Ob&��nWx(9�ԸPt^X�����j1wl�OQd�����h����I\��OF�:���
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   (�g
d��[
)�y�ˉྡ��Z�k���+VF���{��c��;���!�rK�RP�c�XR��^��W/����K���B�č����yJAU�R�s}q��r"
��G��In�JEO�Ur�k���RI�ʇ�]���!�ք��Ob&��nWx(9�ԸPt^X�����j1wl�OQd�����h����I\��OF�:���
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   <��.!;�O#�97�}˝sǵr�P�ɵQ�!@����utg'̽��>"R�'w�qP��i�J�,�U�r�@�� f�\�eמ��yJAU�R�s}q��r"
��G��In�JEO�Ur�k���RI�ʇ�]���!�ք��Ob&��nWx(9�ԸPt^X�����j1wl�OQd�����h����I\��OF�:���
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   /�?H�	�T��~���_ܢD�eS]?O1�(-n��)^��qCki��r� ���;t-�Q���vp�߷EN/� �=Fi����;�˭4�"���0�|��qV���ہ�&	�x)m���
��G��In�JEO�Ur�k���RI�ʇ�]���!�ք��Ob&��nWx(9�ԸPt^X�����j1wl�OQd�����h����I\��OF�:���
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   'ԗ��n/�^bݑ��R�`�%>�i@�Tp�����787ĭ�bUV��7���Q����h��x�o�߷EN/� �=Fi����;�˭4�"���0�|��qV���ہ�&	�x)m���
��G��In�JEO�Ur�k���RI�ʇ�]���!�ք��Ob&��nWx(9�ԸPt^X�����j1wl�OQd�����h����I\��OF�:���
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �5�jpN��A�YU�R�`�%>�i@�Tp�����787ĭ�bUV��7���Q����h��x�o�߷EN/� �=Fi����;�˭4�"���0�|��qV���ہ�&	�x)m���
��G��In�JEO�Ur�k���RI�ʇ�]���!�ք��Ob&��nWx(9�ԸPt^X�����j1wl�OQd�����h����I\��OF�:���
i���BX���N���vD�9&�|f[43ùCn&�����13��r�3�A�=!�i8L�X
i�4<��������uG�	D�
�.TlUMń~�&Eq��/��r�Z��g#
(:?���n��X���a1E,A\3���	�V����`5�,>5��'���5��0�L5+�x��]�����CY�Ė87l��c��+<+��ø&��qĖm�L4crȆ��q����������}	�}��רJ��p����(PQ������>Od(OI���N��~bw�w��|��V�pmB�g�+M'�I��]T��O�Ā����XȤ>+�Y���<�QZ,��x�ƞ"�m�Mw�՚��m '�J�Z"�kc-�{�4l�^4�����鸽��!z���d)!=Cv��<˼�T1�u X/ݪK
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ���\���?)��B�[��0(�n�h��?�7[����(���,�N?����s�~"_E�6��k�*���א<�yEn�GJ�7c��+Ø�,���o]��b�>��-% ڴ.���� %��a�� x���J��j\�:U�1��I�$��A�qCsSuܼn����gSn7@LǤ�/5��V�U��R�!n
�/�-��a���4�a�F������/�bWd؜Dx���4Z���y�GZ��}�\ G�B6���sԤj�8T�F���u�~Q��M|EH����i�n�o�n(��ަ�ˣ�����:�K�nq�C���@uQ�*����ۀ��Sy���ӓ c��d߲�ZH\���Kj����5��i��{\���ܡ�ܿ��ce�ǁ"˗.,a�+���+�}=G�Z+h�b��z���Z��0�N���� F{��wV��%�h�ט�M�]x ���J�U�����,�1���e�/�m��A|;P��1�
bf�q]'���q9���N(��\�J�嗰�:S���m�f�U�>�T���p�B���r��.�2�S���0~!46� �-���96��uA�k{��#o4���-��*b�U�=A�P�`�EhT�&�c���l���>%]gg>���/��"��-���d��]O�X��o�q����$ʡ�2b���B�����:0����߸���vL�nZw�Lmr����	�)w�D"���H
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   \6b�tl#lܝ�I��*�ae�{��Fk��k%��	S�c�2��_(�C���4�>�� �q�a�
���c�[Z���T]��/�;!���� 9�)�QJzz��O�zӪ�{�U`����@���#􊊍�n���Ci�<ܫ�8s.���$���B���qu��x�����O�����.k��r˶�lꂳ��4W�G����FǂQט�M�6���m�#)5���'3t8�<9/dn�H�p�)��Z�YK���^wf��P�	U8�oJ�f0�L`��>�����qlL3�]Ҿ2���Z�����"�6�Aiiy�{�Y�/}�[�A��R�P�/�؇�G�Vn;���AՉo�׆0,��T��<���`����r��8��:�,��k3�"[�iH�m��,�+5Ϩ0~r+|'Fȟa�)>��\X���`G#K���.��ݜ|ET�\���^�ѧ�z_�
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �Y�����unƮ/��< �� 2K@�&4 �o�]�j���GP?/1�J|M������LV��
V�����ཬUg�^���tP.�޽K����l�Ѣd���P��N�U׼��W4Z�=g�z�4�a���)c���%���6���Bi%��}j3	~+��fQ7C��&�T\�\�k��]bT0Iˍ@(\+��0+@k�T㡪8��
׸��}T�2���ĩ@nX�u~�t��'��W�`��ɐ@��Q3�/�J�խ�EX����	=��FQ������XK�I8 Y��	w�i���>��8�+Ί7p�Q��17&��r��'#Vo.��z�%.�-�+s��o�׆0,��T��<���`����r��8��:�,��k3�"[�iH�m��,�+5Ϩ0~r+|'Fȟa�)>��\X���`G#K���.��ݜ|ET�\���^�ѧ�z_�
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   r͖S�7�s�6��`�6�W�� S^9�2��l� G�G�ύ�9*ЫZ�n���%>�t���B�w��b�e���Qrn��z�Ǆ�)��x���Q����LlN(0�c%T�3��z�Z|�"i�P,!0jY�E+���cټ���/ve¦2S6�>eCP4����j����-�h�O�V.a�Kv�1��
�.�?�C�!Vwo��feA�,p�����P��`�/��AH�/�B�U��lt3�V:��o>��0�:�n�t�����O�=!�*ykQf���[�}i���
Ih^FRrFr��F/`�����bJ}]����:��E-F6�
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   e.����N7w'U�ٞ/�6��^>�,R�Md��:X�x�F�g�w��l���|y��)x��S�����a-�m�t�����He9�dS� 'BB�Eحc1YU�?<���/Fx v�����i�Ͳ�8!:�SD��Ǩ����!CE�@��U4=,5!7����l�+�ϸ�@| �T���a�l9�ގ��G%�⠼�W��Py���feA�,p�����P��`�/��AH�/�B�U��lt3�V:��o>��0�:�n�t�����O�=!�*ykQf���[�}i���
Ih^FRrFr��F/`�����bJ}]����:��E-F6�
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   � s/M�hL�{����z��C/C//F�v��ƴ���Z���l��N���(Q|�&HC���(�Vj�61Av^
Ih^FRrFr��F/`�����bJ}]����:��E-F6�
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   X"
�Y�Ō(���PY �8�/w�tvG,��!��7��Nġg���Hz��Ӯ&HC���(�Vj�61Av^
Ih^FRrFr��F/`�����bJ}]����:��E-F6�
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   A�>�*��,y	r�D�7�7�U]�-�aN0(b4�K�l�+�WJ���!drz?0-�x;t~�r���|�H9�C8!��r��aA�C��s5�g�Samm�jV�:;��,�jV,l|@*أ]� �o��-��Wr�5s�#��.�{��_�ʒ�@r��D��d+5:unwA: ����B9¡�8��u�A�>��L=�x�x7J���&B���Y�����XZ�ug��9
���uⲸ>�e�l�;J�I�1M��f,�R��U��蕏�s���>aR�e�RڼG5,��v�-�N̷̫��^L��턛��4�_U�G�Ǌ�I@���%e�&��q�^��b�<ǝ�^���%�_5�����W�J�<���8���S/]E��K����\?yh�u>�Yz0
Ih^FRrFr��F/`�����bJ}]����:��E-F6�
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �:`�#�+��0�1��.�T~ �\���Q�j��i�8>eD�ON��r����2ъ�>=B��!��@�WSq�XA��+t�{�τwJO�bɖ�,X؝�.+�M���8�g!�s쁫�=�k0�0b�OGh��W��$�V:cǡ�^<�0,�z<�q����g�w0�
���d��VK"��/N��x��Ha��!uR��f �:�&�dG�R�#o��l�����h�J��8� +/OS�Q��A�@�^���cu|z���5��U��$���.r���f�[Y�cC�VL0M+�3w("���1K��-�.��#L���v���ƪc��ls�T���)T���0�
��,.�(p��Z��z�Ͱs K����*y������W#��
�}� �-�G�*K�*;�n8�1,DdL10���0J��
y⚍��������h��t���B� �1�9<� ����s�m�D��'�	���2���"M�[���^���;8��x�ׇ7�W�e���M6_>%���W� uh[�9:/����jFA�!N�:6��uA�k{��#o4���-��*b�U�=A�P�`�EhT�&�c���l���>%]gg>���/��"��-���d��]O�X��o�q����$ʡ�2b���B�����:0����߸���vL�nZw�Lmr����	�)w�D"���H
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   �fT@z1NIZ�1��.�T~ �\���Q�j��i�8>eD�ON��r����2ъ�>=B��!��@�WSq�XA��+t�{�τwJO�bɖ�,X؝�.+�M���8�g!�s쁫�=�k0�0b�OGh��W��$�V:cǡ�^<�0,�z<�q����g�w0�
���d��VK"��/N��x��Ha��!uR��f �:�&�dG�R�#o��l�����h�J��8� +/OS�Q��A�@�^���cu|z���5��U��$���.r���f�[Y�cC�VL0M+�3w("���1K��-�.��#L���v���ƪc��ls�T���)T���0�
��,.�(p��Z��z�Ͱs K����*y������W#��
�}� �-�G�*K�*;�n8�1,DdL10���0J��
y⚍��������h��t���B� �1�9<� ����s�m�D��'�	���2���"M�[���^���;8��x�ׇ7�W�e���M6_>%���W� uh[�9:/����jFA�!N�:6��uA�k{��#o4���-��*b�U�=A�P�`�EhT�&�c���l���>%]gg>���/��"��-���d��]O�X��o�q����$ʡ�2b���B�����:0����߸���vL�nZw�Lmr����	�)w�D"���H
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��j�G����'B몏��H���;�4/����=OxU�@ƃr����2ъ�>=B��!��@�WSq�XA��+t�{�τwJO�bɖ�,X؝�.+�M���8�g!�s쁫�=�k0�0b�OGh��W��$�V:cǡ�^<�0,�z<�q����g�w0�
���d��VK"��/N��x��Ha��!uR��f �:�&�dG�R�#o��l�����h�J��8� +/OS�Q��A�@�^���cu|z���5��U��$���.r���f�[Y�cC�VL0M+�3w("���1K��-�.��#L���v���ƪc��ls�T���)T���0�
��,.�(p��Z��z�Ͱs K����*y������W#��
�}� �-�G�*K�*;�n8�1,DdL10���0J��
y⚍��������h��t���B� �1�9<� ����s�m�D��'�	���2���"M�[���^���;8��x�ׇ7�W�e���M6_>%���W� uh[�9:/����jFA�!N�:6��uA�k{��#o4���-��*b�U�=A�P�`�EhT�&�c���l���>%]gg>���/��"��-���d��]O�X��o�q����$ʡ�2b���B�����:0����߸���vL�nZw�Lmr����	�)w�D"���H
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ��JJ���bW�V��d^Qr�ºb(�θ/O�g�k���]N7�@ƃr����2ъ�>=B��!��@�WSq�XA��+t�{�τwJO�bɖ�,X؝�.+�M���8�g!�s쁫�=�k0�0b�OGh��W��$�V:cǡ�^<�0,�z<�q����g�w0�
���d��VK"��/N��x��Ha��!uR��f �:�&�dG�R�#o��l�����h�J��8� +/OS�Q��A�@�^���cu|z���5��U��$���.r���f�[Y�cC�VL0M+�3w("���1K��-�.��#L���v���ƪc��ls�T���)T���0�
��,.�(p��Z��z�Ͱs K����*y������W#��
�}� �-�G�*K�*;�n8�1,DdL10���0J��
y⚍��������h��t���B� �1�9<� ����s�m�D��'�	���2���"M�[���^���;8��x�ׇ7�W�e���M6_>%���W� uh[�9:/����jFA�!N�:6��uA�k{��#o4���-��*b�U�=A�P�`�EhT�&�c���l���>%]gg>���/��"��-���d��]O�X��o�q����$ʡ�2b���B�����:0����߸���vL�nZw�Lmr����	�)w�D"���H
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F   ����6�f	q�1�Q�mؒ�������r�/�V`Q�'���<��'�螏��}'��=I��O_�yϤ+��+~���'��?؏j[�]��-��_�,X؝�.+�M���8�g!�s쁫�=�k0�0b�OGh��W��$�V:cǡ�^<�0,�z<�q����g�w0�
���d��VK"��/N��x��Ha��!uR��f �:�&�dG�R�#o��l�����h�J��8� +/OS�Q��A�@�^���cu|z���5��U��$���.r���f�[Y�cC�VL0M+�3w("���1K��-�.��#L���v���ƪc��ls�T���)T���0�
��,.�(p��Z��z�Ͱs K����*y������W#��
�}� �-�G�*K�*;�n8�1,DdL10���0J��
y⚍��������h��t���B� �1�9<� ����s�m�D��'�	���2���"M�[���^���;8��x�ׇ7�W�e���M6_>%���W� uh[�9:/����jFA�!N�:6��uA�k{��#o4���-��*b�U�=A�P�`�EhT�&�c���l���>%]gg>���/��"��-���d��]O�X��o�q����$ʡ�2b���B�����:0����߸���vL�nZw�Lmr����	�)w�D"���H
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  �����6�f	q�1�Q�mؒ�������r�/�V`Q�'���<��'�螏��}'��=I��O_�yϤ+��+~���'��?؏j[�]��-��_�,X؝�.+�M���8�g!�s쁫�=�k0�0b�OGh��W��$�V:cǡ�^<�0,�z<�q����g�w0�
���d��VK"��/N��x��Ha��!uR��f �:�&�dG�R�#o��l�����h�J��8� +/OS�Q��A�@�^���cu|z���5��U��$���.r���f�[Y�cC�VL0M+�3w("���1K��-�.��#L���v���ƪc��ls�T���)T���0�
��,.�(p��Z��z�Ͱs K����*y������W#��
�}� �-�G�*K�*;�n8�1,DdL10���0J��
y⚍��������h��t���B� �1�9<� ����s�m�D��'�	���2���"M�[���^���;8��x�ׇ7�W�e���M6_>%���W� uh[�9:/����jFA�!N�:6��uA�k{��#o4���-��*b�U�=A�P�`�EhT�&�c���l���>%]gg>���/��"��-���d��]O�X��o�q����$ʡ�2b���B�����:0����߸���vL�nZw�Lmr����	�)w�D"���H
��-�~��d��pT��Zk�/�^Pi�d�UK�:���7 ���Gp���v)w�DRӣ��ٶ�>��@��k l�=�����
	aφ_�ك��֛,X���.�y;m�֍�̲��w�n8��3�*�ьJ��[=Ck-��������^^�Imu2�^�Vy`(���Mjq���dCIT���ˊ�/��~~"#Tz�@Ö�Wو޾�9O0 �#U�2|tHG�L\�:��qx/%��%�TD*�s$
� g.�&T^[�����q�'�̪ӓ�u�y��9iR���(�*�ɿ���F��%�0µfB���w�P����8���ٷ� ��� j�����|����s��u}F�+���$��d��"��� y:�S��S&�oP�[�I�*����(5_�}�fj����o��p�����z�$6��J��)���!e
��_k�R���'�Zs�����K�a� ���kH���(e�8���ɬ��V#�Z�T����ƪ;�N�Fq1�fx*.����Q��j�
{�
�!�����,l;&zi��)�v��Z�Y�e�O��7�]��f�~�~fo3�m��7���@Rמ lAH[٠�X�x����भ9��"��C5pK�KQ��@�K�h;.Y8��!fw���`��e�Z	m���KSK<pW0�P�0z�,ES4w��s�                                � }F  
                       @      ELF          >    �     @       (�         @ 8 
 @ G F       �@             @       0      0                   0�     0�     �y           `�(F         -�            ��  �  �                                     p�O    ~�
                             �y}F  ��|    K\F         �[�           �ɞo�  ,|"F  `|"F  !   P X�F#F  �k"F  `|"F       ��"F  �t}F          �t}F          �z}F  �t}F  �#F   H#F  �F#F         o      H#F  h@     x}F  �ɞo�  �z}F   ʞo�  �t}F  ��|    �\F          �z}F                        �t}F                     �}F          x}F          x}F        �ʞo�          �#F  @     �1[F  2[F  ;@     8      ��)F  U�q    �\F         Uu�    ��"F  (2[F  �F#F  �t}F        �y    ����    �t}F          �y    H�8                              @"F  $]\F                 �F#F  `      $       Pʞo�  @ʞo�  �1[F          0	@     �̞o�                  �y    �ʞo�         �@                     gs)F  �)F          0	@     W@     �˞o�  �y           �˞o�                  �@     ��(F  This was the time of day when I wished I were able to sleep.
High school.
Or was purgatory the right word? If there was any way to atone for my sins, this
ought to count toward the tally in some measure. The tedium was not something I grew
used to; every day seemed more impossibly monotonous than the last.
I suppose this was my form of sleep—if sleep was defined as the inert state
between active periods.
I stared at the cracks running through the plaster in the far corner of the cafeteria,
imagining patterns into them that were not there. It was one way to tune out the voices
that babbled like the gush of a river inside my head.
Several hundred of these voices I ignored out of boredom.
When it came to the human mind, I’d heard it all before and then some. Today,
all thoughts were consumed with the trivial drama of a new addition to the small student
body here. It took so little to work them all up. I’d seen the new face repeated in thought
after thought from every angle. Just an ordinary human girl. The excitement over her
arrival was tiresomely predictable—like flashing a shiny object at a child. Half the
sheep-like males were already imagining themselves in love with her, just because she
was something new to look at. I tried harder to tune them out.
Only four voices did I block out of courtesy rather than distaste: my family, my
two brothers and two sisters, who were so used to the lack of privacy in my presence that
they rarely gave it a thought. I gave them what privacy I could. I tried not to listen if I
could help it.
Try as I may, still...I knew.
Rosalie was thinking, as usual, about herself. She’d caught sight of her profile in
the reflection off someone’s glasses, and she was mulling over her own perfection.
Rosalie’s mind was a shallow pool with few surprises.
© 2008 Stephenie Meyer
2
Emmett was fuming over a wrestling match he’d lost to Jasper during the night. It
would take all his limited patience to make it to the end of the school day to orchestrate a
rematch. I never really felt intrusive hearing Emmett’s thoughts, because he never
thought one thing that he would not say aloud or put into action. Perhaps I only felt
guilty reading the others’ minds because I knew there were things there that they
wouldn’t want me to know. If Rosalie’s mind was a shallow pool, then Emmett’s was a
lake with no shadows, glass clear.
And Jasper was...suffering. I suppressed a sigh.
Edward. Alice called my name in her head, and had my attention at once.
It was just the same as having my name called aloud. I was glad my given name
had fallen out of style lately—it had been annoying; anytime anyone thought of any
Edward, my head would turn automatically...
My head didn’t turn now. Alice and I were good at these private conversations.
It was rare that anyone caught us. I kept my eyes on the lines in the plaster.
How is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
Alice’s mental tone was alarmed now, and I saw in her mind that she was
watching Jasper in her peripheral vision. Is there any danger? She searched ahead, into
the immediate future, skimming through visions of monotony for the source behind my
frown.
I turned my head slowly to the left, as if looking at the bricks of the wall, sighed,
and then to the right, back to the cracks in the ceiling. Only Alice knew I was shaking
my head.
She relaxed. Let me know if it gets too bad.
I moved only my eyes, up to the ceiling above, and back down.
Thanks for doing this.
I was glad I couldn’t answer her aloud. What would I say? ‘My pleasure’? It
was hardly that. I didn’t enjoy listening to Jasper’s struggles. Was it really necessary to
experiment like this? Wouldn’t the safer path be to just admit that he might never be able
© 2008 Stephenie Meyer

It had been two weeks since our last hunting trip. That was not an immensely
difficult time span for the rest of us. A little uncomfortable occasionally—if a 000000 000001 human
walked too close, if the wind blew the wrong way. But humans rarely walked too close.
Their instincts told them what their conscious minds would never understand: we were
dangerous.
Jasper was very dangerous right now.
At that moment, a small girl paused at the end of the closest table to ours,
stopping to talk to a friend. She tossed her short, sandy hair, running her fingers through
it. The heaters blew her scent in our direction. I was used to the way that scent made me
feel—the dry ache in my throat, the hollow yearn in my stomach, the automatic
tightening of my muscles, the excess flow of venom in my mouth...
This was all quite normal, usually easy to ignore. It was harder just now, with the
feelings stronger, doubled, as I monitored Jasper’s reaction. Twin thirsts, rather than just
mine.
Jasper was letting his imagination get away from him. He was picturing it—
picturing himself getting up from his seat next to Alice and going to stand beside the little
girl. Thinking of leaning down and in, as if he were going to whisper in her ear, and
letting his lips touch the arch of her throat. Imagining how the hot flow of her pulse
beneath the fine skin would feel under his mouth...
I kicked his chair.
He met my gaze for a minute, and then looked down. I could hear shame and
rebellion war in his head.
“Sorry,” Jasper muttered.
I shrugged.
“You weren’t going to do anything,” Alice murmured to him, soothing his
chagrin. “I could see that.”
I fought back the grimace that would give her lie away. We had to stick together,
Alice and I. It wasn’t easy, hearing voices or seeing visions of the future. Both freaks
among those who were already freaks. We protected each other’s secrets.
© 2008 Stephenie Meyer
4
“It helps a little if you think of them as people,” Alice suggested, her high,
musical voice too fast foHow is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
---------------------------------------------------------------------------

thing that he would not say aloud or put into action. Perhaps I only felt
guilty reading the others’ minds because I knew there were things there that they
wouldn’t want me to know. If Rosalie’s mind was a shallow pool, then Emmett’s was a
lake with no shadows, glass clear.
And Jasper was...suffering. I suppressed a sigh.
Edward. Alice called my name in her head, and had my attention at once.
It was just the same as having my name called aloud. I was glad my given name
had fallen out of style lately—it had been annoying; anytime anyone thought of any
Edward, my head would turn automatically...
My head didn’t turn now. Alice and I were good at these private conversations.
It was rare that anyone caught us. I kept my eyes on the lines in the plaster.
How is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
Alice’s mental tone was alarmed now, and I saw in her mind that she was
watching Jasper in her peripheral vision. Is there any danger? She searched ahead, into
the immediate future, skimming through visions of monotony for the source behind my
frown.
I turned my head slowly to the left, as if looking at the bricks of the wall, sighed,
and then to the right, back to the cracks in the ceiling. Only Alice knew I was shaking
my head.
She relaxed. Let me know if it gets too bad.
I moved only my eyes, up to the ceiling above, and back down.
Thanks for doing this.
I was glad I couldn’t answer her aloud. What would I say? ‘My pleasure’? It
was hardly that. I didn’t enjoy listening to Jasper’s struggles. Was it really necessary to
experiment like this? Wouldn’t the safer path be to just admit that he might never be able
© 2008 Stephenie Meyer

It had been two weeks since our last hunting trip. That was not an immensely
difficult time span for the rest of us. A little uncomfortable occasionally—if a 000000 000001 This was the time of day when I wished I were able to sleep.
High school.
Or was purgatory the right word? If there was any way to atone for my sins, this
ought to count toward the tally in some measure. The tedium was not something I grew
used to; every day seemed more impossibly monotonous than the last.
I suppose this was my form of sleep—if sleep was defined as the inert state
between active periods.
I stared at the cracks running through the plaster in the far corner of the cafeteria,
imagining patterns into them that were not there. It was one way to tune out the voices
that babbled like the gush of a river inside my head.
Several hundred of these voices I ignored out of boredom.
When it came to the human mind, I’d heard it all before and then some. Today,
all thoughts were consumed with the trivial drama of a new addition to the small student
body here. It took so little to work them all up. I’d seen the new face repeated in thought
after thought from every angle. Just an ordinary human girl. The excitement over her
arrival was tiresomely predictable—like flashing a shiny object at a child. Half the
sheep-like males were already imagining themselves in love with her, just because she
was something new to look at. I tried harder to tune them out.
Only four voices did I block out of courtesy rather than distaste: my family, my
two brothers and two sisters, who were so used to the lack of privacy in my presence that
they rarely gave it a thought. I gave them what privacy I could. I tried not to listen if I
could help it.
Try as I may, still...I knew.
Rosalie was thinking, as usual, about herself. She’d caught sight of her profile in
the reflection off someone’s glasses, and she was mulling over her own perfection.
Rosalie’s mind was a shallow pool with few surprises.
© 2008 Stephenie Meyer
2
Emmett was fuming over a wrestling match he’d lost to Jasper during the night. It
would take all his limited patience to make it to the end of the school day to orchestrate a
rematch. I never really felt intrusive hearing Emmett’s thoughts, because he never
thought one thing that he would not say aloud or put into action. Perhaps I only felt
guilty reading the others’ minds because I knew there were things there that they
wouldn’t want me to know. If Rosalie’s mind was a shallow pool, then Emmett’s was a
lake with no shadows, glass clear.
And Jasper was...suffering. I suppressed a sigh.
Edward. Alice called my name in her head, and had my attention at once.
It was just the same as having my name called aloud. I was glad my given name
had fallen out of style lately—it had been annoying; anytime anyone thought of any
Edward, my head would turn automatically...
My head didn’t turn now. Alice and I were good at these private conversations.
It was rare that anyone caught us. I kept my eyes on the lines in the plaster.
How is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
Alice’s mental tone was alarmed now, and I saw in her mind that she was
watching Jasper in her peripheral vision. Is there any danger? She searched ahead, into
the immediate future, skimming through visions of monotony for the source behind my
frown.
I turned my head slowly to the left, as if looking at the bricks of the wall, sighed,
and then to the right, back to the cracks in the ceiling. Only Alice knew I was shaking
my head.
She relaxed. Let me know if it gets too bad.
I moved only my eyes, up to the ceiling above, and back down.
Thanks for doing this.
I was glad I couldn’t answer her aloud. What would I say? ‘My pleasure’? It
was hardly that. I didn’t enjoy listening to Jasper’s struggles. Was it really necessary to
experiment like this? Wouldn’t the safer path be to just admit that he might never be able
© 2008 Stephenie Meyer

It had been two weeks since our last hunting trip. That was not an immensely
difficult time span for the rest of us. A little uncomfortable occasionally—if a 000000 000001 human
walked too close, if the wind blew the wrong way. But humans rarely walked too close.
Their instincts told them what their conscious minds would never understand: we were
dangerous.
Jasper was very dangerous right now.
At that moment, a small girl paused at the end of the closest table to ours,
stopping to talk to a friend. She tossed her short, sandy hair, running her fingers through
it. The heaters blew her scent in our direction. I was used to the way that scent made me
feel—the dry ache in my throat, the hollow yearn in my stomach, the automatic
tightening of my muscles, the excess flow of venom in my mouth...
This was all quite normal, usually easy to ignore. It was harder just now, with the
feelings stronger, doubled, as I monitored Jasper’s reaction. Twin thirsts, rather than just
mine.
Jasper was letting his imagination get away from him. He was picturing it—
picturing himself getting up from his seat next to Alice and going to stand beside the little
girl. Thinking of leaning down and in, as if he were going to whisper in her ear, and
letting his lips touch the arch of her throat. Imagining how the hot flow of her pulse
beneath the fine skin would feel under his mouth...
I kicked his chair.
He met my gaze for a minute, and then looked down. I could hear shame and
rebellion war in his head.
“Sorry,” Jasper muttered.
I shrugged.
“You weren’t going to do anything,” Alice murmured to him, soothing his
chagrin. “I could see that.”
I fought back the grimace that would give her lie away. We had to stick together,
Alice and I. It wasn’t easy, hearing voices or seeing visions of the future. Both freaks
among those who were already freaks. We protected each other’s secrets.
© 2008 Stephenie Meyer
4
“It helps a little if you think of them as people,” Alice suggested, her high,
musical voice too fast foHow is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
---------------------------------------------------------------------------

thing that he would not say aloud or put into action. Perhaps I only felt
guilty reading the others’ minds because I knew there were things there that they
wouldn’t want me to know. If Rosalie’s mind was a shallow pool, then Emmett’s was a
lake with no shadows, glass clear.
And Jasper was...suffering. I suppressed a sigh.
Edward. Alice called my name in her head, and had my attention at once.
It was just the same as having my name called aloud. I was glad my given name
had fallen out of style lately—it had been annoying; anytime anyone thought of any
Edward, my head would turn automatically...
My head didn’t turn now. Alice and I were good at these private conversations.
It was rare that anyone caught us. I kept my eyes on the lines in the plaster.
How is he holding up? she asked me.
I frowned, just a small change in the set of my mouth. Nothing that would tip the
others off. I could easily be frowning out of boredom.
Alice’s mental tone was alarmed now, and I saw in her mind that she was
watching Jasper in her peripheral vision. Is there any danger? She searched ahead, into
the immediate future, skimming through visions of monotony for the source behind my
frown.
I turned my head slowly to the left, as if looking at the bricks of the wall, sighed,
and then to the right, back to the cracks in the ceiling. Only Alice knew I was shaking
my head.
She relaxed. Let me know if it gets too bad.
I moved only my eyes, up to the ceiling above, and back down.
Thanks for doing this.
I was glad I couldn’t answer her aloud. What would I say? ‘My pleasure’? It
was hardly that. I didn’t enjoy listening to Jasper’s struggles. Was it really necessary to
experiment like this? Wouldn’t the safer path be to just admit that he might never be able
© 2008 Stephenie Meyer

It had been two weeks since our last hunting trip. That was not an immensely
difficult time span for the rest of us. A little uncomfortable occasionally—if a @     ��YT�  YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            �               YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            �             YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            �    ޒD��8�W;��v�;��AMA����K������d���	$$�N.�359\��i�����i<�Z�Lg�Ƥ�'$��xI�e����c������3:�Ge�+����$����UE2�_L�m�IiL�~X�6Ы������5k�$��*=��F8kRU$SN6v�)2vma?�M���;�s�檛y|۹l-ʖ�8Zk'��9��cS!մgIZ���g�CI~��:�y|/'S���I�
ঔ�53�i�A���NN� ��Yo��VES���r�jv9�ڪ��J�-^�4����>� ���Kj��JVs�Dz��0�sa_@���L�y�g
KT�k|�׼�ʓ��2CX�������t�s3JT����s���I���jӐr����Ֆy�?�nE������B�s��7+Â��jp�[)A�d�⬶���:�9B���j3�.KYPGѮ��E=�D��VS�+N�.Ţ�Mh�K��D�fS�h���@�5*�����^�P����v���f�f���;
�e3A�0KS�
�CCd1D5��3[�L���^�F��F���T$8KPNP����sk�'w���40w��q�4���\���T,�k�;FF�[QW0_Ѝ��$�ќ������*�5Z�+�5�@Y
�7��u��y��y�2IZ?�G�У�u2w404F�0�G:4h<�������βg1_6��28��g=L���r��i)
�i�{���q�4��\	�ck%��3,�|7mM�ģS�ӏ$�Yi'H�s>w���"O=�E6t0�f
ҵc�Uv�B�1qM.c�K��t�RR���)��9zr�.V;V�fiu����Z�,QW:կ;����p4Ɇр���ӘM#�6s��n�;�W��zI�������m�҄��4^w� M�y&my�t�%E e���㻹���S�
��>�'9�j�tZ�\�:=nؼjh��k6�x��r�kנ�>0�J��ȣq��T�E���{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
��;��e�t������a�qK�_��;BUދݻ
.kY�����d�;�z�4/+}%��N��ҷ�tB.h"m�j��[״8Iؒs��:�\j����AB�.��H6ق��V-9�ZЕܩhL���C��Y���#-%|S)V꼿*�v�Xw%yJ4��ٚ
�:��8��֬�\�8�c��1~N���JL�>�|�D��Rꞎ~����z���k�d���rj3�	[Iq�t<�����t:�|Kv��Q�?�u�s�y�ʼ���0�ز�5�U�c3o
�n�x���s����MI$"���i��wC�и��x�@)�P�������;�'`y!$�䄤����-.ԝ�NI��I�$��HrHvHS�r���{'I$��%I!$�$��D��Gd�$�����b�m���-':I^���!'�&K8�o��n��V�S!�i �v_D��l�$�$���,�,��������҂�q��u������=gd����E��r�ݬ�VצY�
�7��u��y��y�2IZ?�G�У�u2w404F�0�G:4h<�������βg1_6��28��g=L���r��i)
�i�{���q�4��\	�ck%��3,�|7mM�ģS�ӏ$�Yi'H�s>w���"O=�E6t0�f
ҵc�Uv�B�1qM.c�K��t�RR���)��9zr�.V;V�fiu����Z�,QW:կ;����p4Ɇр���ӘM#�6s��n�;�W��zI�������m�҄��4^w� M�y&my�t�%E e���㻹���S�
��>�'9�j�tZ�\�:=nؼjh��k6�x��r�kנ�>0�J��ȣq��T�E���{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
��;��e�t������a�qK�_��;BUދݻ
.kY�����d�;�z�4/+}%��N��ҷ�tB.h"m�j��[״8Iؒs��:�\j����AB�.��H6ق��V-9�ZЕܩhL���C��Y���#-%|S)V꼿*�v�Xw%yJ4��ٚ
�:��8��֬�\�8�c��1~N���JL�>�|�D��Rꞎ~����z���k�d���rj3�	[Iq�t<�����t:�|Kv��Q�?�u�s�y�ʼ���0�ز�5�U�c3o
�n�x���s����MI$"���i��wC�и��x�@)�P�������;�'`y!$�䄤����-.ԝ�NI��I�$��HrHvHS�r���{'I$��%I!$�$��D��Gd�$�����b�m���-':I^���!'�&K8�o��n��V�S!�i �v_D��l�$�$���,�,��������҂�q��u������=gd����E��r�ݬ�VצY�
�7��u��y��y�2IZ?�G�У�u2w404F�0�G:4h<�������βg1_6��28��g=L���r��i)
�i�{���q�4��\	�ck%��3,�|7mM�ģS�ӏ$�Yi'H�s>w���"O=�E6t0�f
ҵc�Uv�B�1qM.c�K��t�RR���)��9zr�.V;V�fiu����Z�,QW:կ;����p4Ɇр���ӘM#�6s��n�;�W��zI�������m�҄��4^w� M�y&my�t�%E e���㻹���S�
��>�'9�j�tZ�\�:=nؼjh��k6�x��r�kנ�>0�J��ȣq��T�E���{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
?Iw�&�G�Ox�&�Ӂ9T����7U9L=Y����oH�QK!�~[t|!
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�v�mW�ˎ����IK�%�V�yv���yҕ�`͏3�4Y2�Lh�5�+����G�K�����$Q�E}j�4�[�Jں,�6<�YV}X)���Q���u��̼e������7g"����\4`�.�\z��~j���H�A6�?Z&��*�"z\��Br��*2��g����2������1AI��u:}Xi���Lp��N@Η,R+��0�0N���1�A���\���D�-:�;�CL��!~:�m����S?�G�W�5�6�x��#�� ��͖�Lc��:�8<gV����y�A���R՞�L�;y���J�O��& 
>��>KiՏ8��� �P�/�
?Iw�&�G�Ox�&�Ӂ9T����7U9L=Y����oH�QK!�~[t|!
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�����:B���V��if�r>�����d�W�Ǘ��[݂
>��>KiՏ8��� �P�/�
?Iw�&�G�Ox�&�Ӂ9T����7U9L=Y����oH�QK!�~[t|!
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
>��>KiՏ8��� �P�/�
?Iw�&�G�Ox�&�Ӂ9T����7U9L=Y����oH�QK!�~[t|!
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
>��>KiՏ8��� �P�/�
?Iw�&�G�Ox�&�Ӂ9T����7U9L=Y����oH�QK!�~[t|!
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
����w��(.��+��9H�T���L�<�'�ڌ�F�f6� ����Z�@쭢�zSɫ.O~\1�.2{��@�vQ�J)e�R9Vͨ�.4�Q�廽F�{�:Md�ځ�ǁ�t;�tQ�.ڤ��{�~1n8zc�Q&�bDTL���(�&�֢\*���G����?K���6
�U�U�h�r�ӒaD�d�r�Q�OK/�&\ǔ�\&N�AV�է��9�V�n[�1����P	�9�p@h���p���5Fx���P�˜A⻲H��J#(���O�J/fLS
�.�l�<�!M���w���(�;`V$x���%O'GJ�
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�*��W������r�=r���J���Q�/�	����*V�v�)i48Ihb3�����W$}��d\�!X�r.�-�W��*�@�"��w��� Kv�{]�c�;57��V�*�i�-=a���Z��:����*F��#&݋�J�Q�#'\z�$	w��R{�FG�;'�̹up�w��<�{'O�9���l���ovN{S�Cz�����9����
M�x�Qx��v�s�t��m=�x�8 
J�JZ�ƀ*�SR%��+A�=�0�i��B�<x���9{��esM�@��UJE�҄-��y�����V*H5�F�'[ItB9~��ֹ7��()��k���T�^h<j�Y�f4YQYW���L�0�}@�զ�6��(D~kDv�&�7�kʬXQ4�^���|�^�<�;$�D�T���a���u��a�N�(�JT����Y�gOzR���C#J��f�y+��ǥUh�8���5�|A�
�-�u ݸF�#�[�\�uw\�<A�q�بP�����?uMZJݼs��G��R%r~0��ʞ�<�^e_��L��� �~��$璮m���W��ѽU�_	��G�k����S�gε��#��*Qg��K;4Vg� �g�Y"�3����),�@uc�`�~F�6u*E��&)��݊ss�j�.���FK�y��0Waj����Z�*T��)���$o#��P�U��b��������Kq��9Gti���}A�	f�H3����U|c\R������HLM�7Z-Rv-7NZ�s���*f��p~��G^P��{�٭9��N\)
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
M�x�Qx��v�s�t��m=�x�8 
J�JZ�ƀ*�SR%��+A�=�0�i��B�<x���9{��esM�@��UJE�҄-��y�����V*H5�F�'[ItB9~��ֹ7��()��k���T�^h<j�Y�f4YQYW���L�0�}@�զ�6��(D~kDv�&�7�kʬXQ4�^���|�^�<�;$�D�T���a���u��a�N�(�JT����Y�gOzR���C#J��f�y+��ǥUh�8���5�|A�
�-�u ݸF�#�[�\�uw\�<A�q�بP�����?uMZJݼs��G��R%r~0��ʞ�<�^e_��L��� �~��$璮m���W��ѽU�_	��G�k����S�gε��#��*Qg��K;4Vg� �g�Y"�3����),�@uc�`�~F�6u*E��&)��݊ss�j�.���FK�y��0Waj����Z�*T��)���$o#��P�U��b��������Kq��9Gti���}A�	f�H3����U|c\R������HLM�7Z-Rv-7NZ�s���*f��p~��G^P��{�٭9��N\)
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�G��@vJa��U���4�_S6�2�tKW���?k0E�5(��O`^�6P������ʂ��ÝD�<�����u�9y��5�憋��`�� ��.�i�;�B5���I4f�I�ES=�6�7d(��դ�3��P��`���*[l�L�PP��}�T��~/$mX�p��'��֩�3m��O֮j�<WWv|��ϞG�O��� +Ns�^� 8.�&�7��00嵠Y�z���;P�+B(ˢ-;GNΡ@�v��lXx���g:r�6��WJI�
{_��D@�.�?I�e	�g��]�)o�S6�S�#^�C�։�}��-J#׎�8�!�r��]u�����EX�O��j*�l��tj�vN����=�m�"�1[|�
��p�X�}�h���3s�9Hi�.�{*v���}.�ͦuӂQ�Z|1ܤ]��)W�m|b�8K\TB� ��9�m)��$S)�%��V� iʫ����/y�v.����( �w�;`i�����R5U��0���A�)d�J�Z:����J�m�#�.6e��f�������tP�t/R27؇AB��������٤��99 �v�؃�_��'�9]��w�x�ړE~��3�?���b�t���,=�d9f�2��;��Mf��AC��[����r��j�J��r�	���OK^��O�ǎ�50Y�i�L ���>B�ќ�Q3ʿ
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
SD7J�� ��T�ҁ^�a��	���
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
U��syޙ��Bև*~"w�����F܇I.	F����gM�}]�,F�������AE��9.H�.HI����N^(r��ϧ�Oɣ�VO|�Ӥf�����m��ѯhk�J�3^Μ�Dғؔ��R�ȝ��a3堍����?��4I$��?�v�1xڑ8yd��[���M|�>Ya�G��u�Bz#nȾ8� �Z�h6�,��dh�.ps������W8�8�U����9���VΤ��s��9�s��9�s��9�s���9�s��?K �pݽe��t�Eb���y���31(�~��FL
|�Aȕ�ɒ�r+`(�VP��6�o�*( q�#�E3+$\nH�o&�T��W6���Y�c�+̣FZ�����G��:��x�䑲�fr�	I��
�rqѹ�3:����Ѹ�N���Db�sQ�Θ�$�ض�;7�Z`P����f�z��v=���8U���KES��׎��Bh����!|(����|dg)����_��7
������F�j[e矫͛:�����
k��徤�|y�����O���`rd}\p�������
�1����s�0�ǈ`���I=�4�a�䇺�G[���IW
�,�6eNg#Rx�� ;*)Rb��n1�n9��9f�'j�G\�{�,���	�TIU���~��������}*��|�j�*3M%�1��"���3�/�UP$��(�>���O�4\��j��(��x�Wr
z�	)%59٬gV-��y��������K+�0��;s5��� ��O��:��Hx��0l�	^�U�Q�yŕ����,��� ���s/����9S9��%]�5ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�+%U�t�t��$��$Uwq�O�b�Dcj�J2�"���q�#ip��>�F+�<"5�rN��M>>,��$b����Df���X�2�Xڌ�D�i�x���NЧ\�'9��FMGe��%��!���]��"�S�v��2[3���9b�����r�*�i�U�Ym�y�|u���yW�rUC�QmQ��qKg�Q�싲rihSUO�%-�\6����d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�+%U�t�t��$��$Uwq�O�b�Dcj�J2�"���q�#ip��>�F+�<"5�rN��M>>,��$b����Df���X�2�Xڌ�D�i�x���NЧ\�'9��FMGe��%��!���]��"�S�v��2[3���9b�����r�*�i�U�Ym�y�|u���yW�rUC�QmQ��qKg�Q�싲rihSUO�%-�\6����d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
N]#���#�	�:v�m�����Uh���ru�.%�_qRZ^���t�R������}�zs�?�P�S�(��[x�T%Wɯ^K��e�fF���-�Y[�%҄�O�:����K�E
0���{�6�+B��G�-�+O��Q��P��{�5�U�p��LL�E�1�`�Qo��3�[ӡ8gP�Q�R���I���f]����~M�m��X�����ni�S[>�K������>c7�/;odW����:���Uԫ�Nܛ�}��rKtќJ����u=�y���:n�4��Ѥ��q���v4G��$��H����Z�%,!v����ҝY��r��,Ԛ)Ei5E�F�%�j���؍�QɿV���c���SCЮF�$j�5i�8�	
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
?ϒ��{H�?�������,����ԥ�S����,�j��QN+W����s�zW�7)��������KL�Պjkކ��ZՏOKb�Z.����*)3��y��49W�F*��\�i�Te���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
��ǭ�1n������E�Ėk4j�;!�qɩl���z��w{�2m1w~Z��f<��Q�Q����j8��z�4EP�Y%Fs[�S~�k~­�ܦ��-�YseB-��I��Y��E�ܟ=���å�)+N,�9t�c.Ս�GRZ^���s�zW�7)��������KL�Պjkކ��ZՏOKb�Z.����*)3��y��49W�F*��\�i�Te���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
+u��Q-R|�j���b^t��Tm�teS|�b=++vBi��,�O�_��St���>'�i䤑qv\�RU���m�r]/b���r�24�5U����Ē�qE]���l��.�`�ֽ�..Ս�GRZ^���s�zW�7)��������KL�Պjkކ��ZՏOKb�Z.����*)3��y��49W�F*��\�i�Te���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�Kf����08VӹO?���vn)-��>�،[0���)��MCQu�'d�m��I��M<.J[}U��7�9����h�VV��B�uح��J;���Ko��c�;�-���˧cS���Eߖ�{����bFc��-�6ǔ��lK�pi�Qk��4ʖbTG�Or/m��B�s�E�[3�.#[Y��d��T�;����/���Ín?s����������-4θ:�)*H�B�6V�������F�t��nie���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
rU�i�rH~"����|�[F%ni|y��5/Q���%��%&��n/M��uɇ�c[�7����΅�r�6ǔ��lK�pi�Qk��4ʖbTG�Or/m��B�s�E�[3�.#[Y��d��T�;����/���Ín?s����������-4θ:�)*H�B�6V�������F�t��nie���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
/q�F�{P��ݑ�eUے��͋\h�צ(�Ҹ]������S����
pY�u�ًn�3������\�fC��r�)'E5qC��zH��E��4�q�/7��Iƽ�ٴcr�Ne`���)X�T���r����x�5?z3Ֆ�5�[��N���긲)��5S�B�x\��Y}���ŷ[��J#&�P�R���Ы$\�*�pr[3�.#[Y��d��T�;����/���Ín?s����������-4θ:�)*H�B�6V�������F�t��nie���D����t�cD�����kҎ��aQ�.��Kn�vo����j�S���V� ���9<���r�<M55x���Msظ��V$)(���e��d:U��n�Φ˒͊/ˁ���N��r2�*��9:����8q�8�\�\	��֭�A�R��I��������NJ����K�pR[rn�.�>?+�����Z��ܹ����tF_���P�,]���7n%+sex�'�ؤ�_���2�1�:]P��=�Qy�ǩt��d^��c��j��qg��y8�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�:�&��;��W�EG&c�Du�՝"�[p�OKG�m<�5r�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
>_�o�q��qon�NIIv4���Kt�lϒ֗K��h��n-[4��P^��%�: �f���p��������k�GR��1۸�q�|�������K�p��N��AG��Pڪ�vE��
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
���qb��xuQ��1]�&*��6�_���\����n��HIZ�� ����Y��W�)2�����I^X{�&OO���d�I��p�3ȋ���6"==��05]�r�zE�`���K}��ڍh��90-xe�~�}L�Vŧ̾��y+����cVۄS �M�/�	H�F�����,
�=���
�e	a�@�ǘ�"�(z_-���
�wA\GXW��?9�,D�@�s���B�#	�ܻ,�~��� W�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�L���̢�pq3բ��|�-�Py л�M�iXbmaE�q]��X%�,5Z�.�^��ǉ�w��Zu�ਥ�7���D�b
�ь��uN=�"�Mu�7���1���,~�hn�6�,�5T>�g
�-".��:1�b��K0��D���8����_�,�1ܤ�2�ᠠ���T&G���dNn:�)�8�5��6�)I�Rp\�G�>%Z����ES��	OP���qEi���r��s�/��l'Q�{��B�#	�ܻ,�~��� W�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�ʣr�Dz�������^���Բ�3E�f1���M44Y�l�"0���A�f^!Zh�ǻF����5,�|'^�AL:���sX�@�H�sn8 �vr��QC�ႁ�;H��ʅ��n��#����N�. ��>4L�0 �c3�_��d;u��&�Sr�Ii˙������b�b�N$���-�<�y�Dm++���U�ģ��RG��)4͈n
�L���̢�pq3բ��|�-�Py л�M�iXbmaE�q]��X%�,5Z�.�^��ǉ�w��Zu�ਥ�7���D�b
�ь��uN=�"�Mu�7���1���,~�hn�6�,�5T>�g
�-".��:1�b��K0��D���8����_�,�1ܤ�2�ᠠ���T&G���dNn:�)�8�5��6�)I�Rp\�G�>%Z����ES��	OP���qEi���r��s�/��l'Q�{��B�#	�ܻ,�~��� W�)�G�և:��J��5G﷪<���"q{-I���:l�v����E��	r�伅U]�d����e��R|�ɗ��R����דQz0�De��v�[쒡9WL�E\������b��!�hn��n����HK����KB�R�&�ٺ���Ej��\�K�)7ER��M����27����㪴k�<|ˑChm.H8�,l]��Uhp����-��k��)����bY�~����G�j2ٻѯ���Ѹ�	�gO{'vM,l�8��ȵɴ�4�0�vt����K���kк��5Dd��5D_������o�)V�6�Hʝ�:v/-��vĲ�w�O�IU�)D��G&�8* ܾ
:1��e?�ƫL[���m��?-��(���xUk���%��rE��OA�X��"���E����V.�r���Ѿ���v�JC�Huz7�ƲX�R���Y$�y"U�t�K!4���XӉ
��|�'D$�G�[��q�r�'X�I$F��\�%]�e�gM-��L�R�H�=��rHB_�ՙg;"�9�6�W��Is��T���[ �?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�f:@�=�bTm���H/��;I�W2�K�<�:��1�=���2�N
�"<s�^M�F��i-��RF[��PTѕ���4Nl�/i��F�=��lю��[F-�C!j�����٩������s	b����l��0��Y��w��vϕ���PC>�mY�A�51Λ���OpɅ����9BT����kb�:'�è�swV(�i��ttz��º��68�dӆ��lY�C{>!i�I��q0FV{����<� p�%S�q}G(S�^�:9f+��*�f�an�ێ�e��LE��fp��S���r�=�	G�5��YG�ʮ��g��+)�K-
���Q]%@TLB�/qaI�5�0F�Xǔ�hb���ψ�da�%7A�ܲ���0Djqʺ�Z��FP%R�א��;�@���f���^�p[pvx��+VB0f�Ι���_�\'[4��E�W�N\�a,-v��̨E��,���q��S%�V�,��ꦁ�g��3(�|��[�9k8�
�@�b1ٴ%R��	E�<�,��.�gL��r�8G)����'j�K�j�!�p]S�0ҩ(w=%.e[�~-.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
m�Z��M�`4^���E]w2��|O?-������h��(6F�=K7ʃ�Pq38�T�P�0�|GCrj,�T�nF�����<#��?����Ģ��9�`Z.U�
�
S*x����vQ�D�Mn���GV�ܤ��������hj&�|�MMS�q��mI|�	aq�B aK�\MJ��5:~ae�D��T��4�fؔP�����=ʃ��F���+���<�_C*L%��8"��:��L�g�
���4����A��CwB��k���^بl��P�\z�D�°��o����S��s
�f:@�=�bTm���H/��;I�W2�K�<�:��1�=���2�N
�"<s�^M�F��i-��RF[��PTѕ���4Nl�/i��F�=��lю��[F-�C!j�����٩������s	b����l��0��Y��w��vϕ���PC>�mY�A�51Λ���OpɅ����9BT����kb�:'�è�swV(�i��ttz��º��68�dӆ��lY�C{>!i�I��q0FV{����<� p�%S�q}G(S�^�:9f+��*�f�an�ێ�e��LE��fp��S���r�=�	G�5��YG�ʮ��g��+)�K-
���Q]%@TLB�/qaI�5�0F�Xǔ�hb���ψ�da�%7A�ܲ���0Djqʺ�Z��FP%R�א��;�@���f���^�p[pvx��+VB0f�Ι���_�\'[4��E�W�N\�a,-v��̨E��,���q��S%�V�,��ꦁ�g��3(�|��[�9k8�
�@�b1ٴ%R��	E�<�,��.�gL��r�8G)����'j�K�j�!�p]S�0ҩ(w=%.e[�~-.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
"��r����%�ܦ��P_����&N��^�7��L��j
*RՅ��,
;�g���-�7U�h�8�7�dd1u���Z�w� �X[�	���ars1�ۀ y�:���R�sn\O2ڮl�F�ߡ;8a��)��0LD�).�pi�
�*�0�m��UP��W��� G����:�\O�øJ^���&e5�Q�+��':e�[8�.�+���v#��K�ֿQ�)X�p
�"<s�^M�F��i-��RF[��PTѕ���4Nl�/i��F�=��lю��[F-�C!j�����٩������s	b����l��0��Y��w��vϕ���PC>�mY�A�51Λ���OpɅ����9BT����kb�:'�è�swV(�i��ttz��º��68�dӆ��lY�C{>!i�I��q0FV{����<� p�%S�q}G(S�^�:9f+��*�f�an�ێ�e��LE��fp��S���r�=�	G�5��YG�ʮ��g��+)�K-
���Q]%@TLB�/qaI�5�0F�Xǔ�hb���ψ�da�%7A�ܲ���0Djqʺ�Z��FP%R�א��;�@���f���^�p[pvx��+VB0f�Ι���_�\'[4��E�W�N\�a,-v��̨E��,���q��S%�V�,��ꦁ�g��3(�|��[�9k8�
�@�b1ٴ%R��	E�<�,��.�gL��r�8G)����'j�K�j�!�p]S�0ҩ(w=%.e[�~-.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
E��a)��B�{�Ua�%��S0��3,=+�x-��GG��˃�LS`��;2���Q�����#B������?����4�O��:(�/@�n��ŉ�+���-���+��@�����K��w U֠B�R�:P������j�$:A����U�ܬ�|��s||���R%�	�Q��`��꺋	-E^ś��+���AvlOJ귉i �Z�Cp�#����lP�E�.��ͷ �A�!e P�i���{�Z�	r��vƬ��KAIys:��qH�5K��b-i�Ը�d�E{/�+�����4�����
�"<s�^M�F��i-��RF[��PTѕ���4Nl�/i��F�=��lю��[F-�C!j�����٩������s	b����l��0��Y��w��vϕ���PC>�mY�A�51Λ���OpɅ����9BT����kb�:'�è�swV(�i��ttz��º��68�dӆ��lY�C{>!i�I��q0FV{����<� p�%S�q}G(S�^�:9f+��*�f�an�ێ�e��LE��fp��S���r�=�	G�5��YG�ʮ��g��+)�K-
���Q]%@TLB�/qaI�5�0F�Xǔ�hb���ψ�da�%7A�ܲ���0Djqʺ�Z��FP%R�א��;�@���f���^�p[pvx��+VB0f�Ι���_�\'[4��E�W�N\�a,-v��̨E��,���q��S%�V�,��ꦁ�g��3(�|��[�9k8�
�@�b1ٴ%R��	E�<�,��.�gL��r�8G)����'j�K�j�!�p]S�0ҩ(w=%.e[�~-.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
\�+�1xD�K�bd�Cл�\��M���,W����c�U��e���Z�"k��G�q5B����r�U�{�f����2-�֤̈́_�,K8��)����U��2��j�@�#w[�1v��`�1�8t,x�2��@
�ȶaj��3����)���ID�R3(fhZ
4^���4���Wl+��J�]Eq���R��(kQ��:� �jp�'hCm�hw	�@�r���
���*-_D�}�f
󙻚�]��q3�+p��ZG(Tn�j���6~�&W0�ZH�k�$���q. �40v���JÖt:�Z�%�Z�1&��0�.0j� p:����V�p���C��;��һ/Hȴ�	w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�o"�!II���������T��w����#IƠ������4�)���Z�<Ǚ�� RcT���R���ѡ�P �6%�t��GL2�M��k�$��J�TR�l��G���R�D�+��A���i�C�����,v�U�k�@�:Ta��w��W�����Z��]���31�[R���>SV#� �K�Ol�g��ׁ��~A'�h��x�jp�'hCm�hw	�@�r���
���*-_D�}�f
󙻚�]��q3�+p��ZG(Tn�j���6~�&W0�ZH�k�$���q. �40v���JÖt:�Z�%�Z�1&��0�.0j� p:����V�p���C��;��һ/Hȴ�	w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�o"�!II���������T��w����#IƠ������4�)���Z�<Ǚ�� RcT���R���ѡ�P �6%�t��GL2�M��k�$��J�TR�l��G���R�D�+��A���i�C�����,v�U�k�@�:Ta��w��W�����Z��]���31�[R���>SV#� �K�Ol�g��ׁ��~A'�h��x�jp�'hCm�hw	�@�r���
���*-_D�}�f
󙻚�]��q3�+p��ZG(Tn�j���6~�&W0�ZH�k�$���q. �40v���JÖt:�Z�%�Z�1&��0�.0j� p:����V�p���C��;��һ/Hȴ�	w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
*x�4�rK�È����r	�VD��a�>b簦��v3{�mKK+���u�Ss��jy2���16�6�&��6���;��M!A�%+�ƽKt�X�"��5�$�W�+)��n���t�[���q�0`
�&���°ω�i��5*Mn���i���pYF��Q�h�
<�8ͩ����xJ-�b#�� �B��6�a<����
�6$1y}^��8%����(�����Lɉ�p)���W>$��N�(k�+�eW�q���xf�]��(����s>>��?2��yb��Dnp|����P���͖�7��5b��ºIz�`9�X�P
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
���9j�{`&�k8YL�%K��4X�5�f�1k��D�2����S	K�X@���{X6r4ʇ��Mn�l3�-K{���^2�H�4̭WB�0=Ss��jy2���16�6�&��6���;��M!A�%+�ƽKt�X�"��5�$�W�+)��n���t�[���q�0`
�&���°ω�i��5*Mn���i���pYF��Q�h�
<�8ͩ����xJ-�b#�� �B��6�a<����
�6$1y}^��8%����(�����Lɉ�p)���W>$��N�(k�+�eW�q���xf�]��(����s>>��?2��yb��Dnp|����P���͖�7��5b��ºIz�`9�X�P
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�p�5
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�~ڛ�79kX"�S���	�s�ax�09�1�""ߩT09(]F��㨌�v�
6KR�i��J�>J�E�0�;a6��3�y�~���M�֡ɼK1X��ft�?�
�p�5
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
bk����]>c�C�<O-�,5<U~e� �Ǒc��ʣ�� #;
�p�5
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�쯗"��W������[.Z.%_�%Z������$n�����~���.�ks��rÂq i,���nZ�W�xLU�ܗ��i?02�0a[A��_�7"�CF�,�/�ơ�x���]�r Tҍ���>:�EG�i���J���0Y�˽%��5�{�נ�;�s^&�.�|z.��D�eb�(e�{����;"����u���x�
��q��g=�@��/	]�泎W��]��R�{>r����J�w\'�h��+[s(�	�/&�W�T��\W�J�E2"�&�9W��'���?&=B���Sy��-5�Xbɏ6��QPj췘X5�jj�[���.-#JX�۰c�p�);�2Ǡ��ƫ���(����s>>��?2��yb��Dnp|����P���͖�7��5b��ºIz�`9�X�P
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�쯗"��W������[.Z.%_�%Z������$n�����~���.�ks��rÂq i,���nZ�W�xLU�ܗ��i?02�0a[A��_�7"�CF�,�/�ơ�x���]�r Tҍ���>:�EG�i���J���0Y�˽%��5�{�נ�;�s^&�.�|z.��D�eb�(e�{����;"����u���x�
��q��g=�@��/	]�泎W��]��R�{>r����J�w\'�h��+[s(�	�/&�W�T��\W�J�E2"�&�9W��'���?&=B���Sy��-5�Xbɏ6��QPj췘X5�jj�[���.-#JX�۰c�p�);�2Ǡ��ƫ���(����s>>��?2��yb��Dnp|����P���͖�7��5b��ºIz�`9�X�P
s_���3!�_щZ�P+=����MF��x`����b���XᲒ-M�R�X��w�^�i�)L
�U�
Pr�`ę"��F�|5C�L������
�7�A�W����N3^��I�����z��PF�T�lӄ��=W��BQb�+YT85?��U�w{���-/-�
�\����0���:������!�@���g
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
���6�Y�1�Tҗy�&��2Ԟ��%*5S5<C	�Irm�,�(�ݏ��,�$$Zဉ��D�S���(9��r9y�A���Ku�*<��?�f1<�3�V�2â�-�c�����b��LV3^�+��R��|ܼ᫮Q`h�S�;��eÞ���6v`��-��R���?ܪ�)�
lq�N�����.�c[�����Y�C���J�&���dZ��'+�!�y3�Ub��-צ	��N=?�cna�
t��Bzl>"y�E�M��=��q��A�&pُ���7�7�ǴIp肨.(�,˦����&�P\�%����E�ť��s�p��łr�̣Q�G*A������M���� N�A�7�o� �týL���f08�� X鹂�N�O����.Xk"���4�	n;ʵ,��JV�93sM�u����U�l#�8
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
��g%��-��WV��Ɠ	ъ�k̾�S�VX��F���#���<ȍ� 㙽�'\B���n%�:n �<HtH���5�/�#�?�����әz�4_�#,ѩA y���7
���6�Y�1�Tҗy�&��2Ԟ��%*5S5<C	�Irm�,�(�ݏ��,�$$Zဉ��D�S���(9��r9y�A���Ku�*<��?�f1<�3�V�2â�-�c�����b��LV3^�+��R��|ܼ᫮Q`h�S�;��eÞ���6v`��-��R���?ܪ�)�
lq�N�����.�c[�����Y�C���J�&���dZ��'+�!�y3�Ub��-צ	��N=?�cna�
t��Bzl>"y�E�M��=��q��A�&pُ���7�7�ǴIp肨.(�,˦����&�P\�%����E�ť��s�p��łr�̣Q�G*A������M���� N�A�7�o� �týL���f08�� X鹂�N�O����.Xk"���4�	n;ʵ,��JV�93sM�u����U�l#�8
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
GD d�h/�ı�^ �1Pw/�>�Y&z���èFЋ�
��Z��5�V�'��x�/�_W_�s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
��Z��5�V�'��x�/�_W_�s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
:���<VB�#��e��Ye��
�%J��Wҥ}v��P�������k�h���\�E�nA��C�}---/�_Ŀ�yyyyyyy�yin廖�[ܿ���8\c�̷�xgJ�|F�ĭldJ2�����7Jݐ�M�x+��0"/I�v��/�]&�i�i(��7ˣ�2�۸��l�]����	���sY^y�������`�z�j�j��҉�ʾ���C��ѿ�[1��/j���G3R�+q�[��U�̡�V�p��R~'�{�;��5/��	�r����rf̪Ә�����;�a���2d�j0@
��Z��5�V�'��x�/�_W_�s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�ݤg�~��;+n��W8Q�r���?Ctq�-�|��7��w�xc#�c��gx��s����{�x�����fs�
DEY�_m���=��˕]��U���,2��X9��:�f.:я\�+�}9��{�.1t�5ŗ��b�I�E�b8 �6���7���O"}�~�i����ah�xD�tk)j���3�����4�V.|CqO�#6a;���>�@U��u���|�|><�w_�j9���A������3��7s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
p�j,ؒopTrW������Og�� /��=l��7���T���d��.?ÑY�u�c�η�Ei��u�1��M�����Q�b~�뽵;.�{G��٧���]
�ݤg�~��;+n��W8Q�r���?Ctq�-�|��7��w�xc#�c��gx��s����{�x�����fs�
DEY�_m���=��˕]��U���,2��X9��:�f.:я\�+�}9��{�.1t�5ŗ��b�I�E�b8 �6���7���O"}�~�i����ah�xD�tk)j���3�����4�V.|CqO�#6a;���>�@U��u���|�|><�w_�j9���A������3��7s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�ݤg�~��;+n��W8Q�r���?Ctq�-�|��7��w�xc#�c��gx��s����{�x�����fs�
DEY�_m���=��˕]��U���,2��X9��:�f.:я\�+�}9��{�.1t�5ŗ��b�I�E�b8 �6���7���O"}�~�i����ah�xD�tk)j���3�����4�V.|CqO�#6a;���>�@U��u���|�|><�w_�j9���A������3��7s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�ݤg�~��;+n��W8Q�r���?Ctq�-�|��7��w�xc#�c��gx��s����{�x�����fs�
DEY�_m���=��˕]��U���,2��X9��:�f.:я\�+�}9��{�.1t�5ŗ��b�I�E�b8 �6���7���O"}�~�i����ah�xD�tk)j���3�����4�V.|CqO�#6a;���>�@U��u���|�|><�w_�j9���A������3��7s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�ݤg�~��;+n��W8Q�r���?Ctq�-�|��7��w�xc#�c��gx��s����{�x�����fs�
DEY�_m���=��˕]��U���,2��X9��:�f.:я\�+�}9��{�.1t�5ŗ��b�I�E�b8 �6���7���O"}�~�i����ah�xD�tk)j���3�����4�V.|CqO�#6a;���>�@U��u���|�|><�w_�j9���A������3��7s��;��L��ӽ���\�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�˙FĬ�94��;�";�@���@�^���ð��J~�?ω�Yp��a�6 �8�sĲ���J �+��@Dʑ�[G+�tj"��jE,������k*��}� 5��=N�*
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�1=�'���y�֑`j

l�U��;bn�]p���Gm���\�'��%Zv�&C�1!�+��h��51�zi�����-��t��N|T��_��_�P�]J�)S�w	VG��CA4��N��8�b�Z����Md'�C������Rp��]����<Vb𰫰�BŜ��	���Q�f�yD����	�Z��>ŃM�'�IB	)���h�}���*~��}"2��s��vD�����!�t�&��ޏ�|$�6Rp��LlQS{1��1�Q*��&e]#:>���%;"쭖|�]�2��ӣ"><2�'F^#���M�GP�i*�H�M$'^���Z~
t$���h4�1�CI�ZeN"oG
��H]Qb�%���D��lJ1[���FHw��kA�GN��ًq�0�/���
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�1=�'���y�֑`j

l�U��;bn�]p���Gm���\�'��%Zv�&C�1!�+��h��51�zi�����-��t��N|T��_��_�P�]J�)S�w	VG��CA4��N��8�b�Z����Md'�C������Rp��]����<Vb𰫰�BŜ��	���Q�f�yD����	�Z��>ŃM�'�IB	)���h�}���*~��}"2��s��vD�����!�t�&��ޏ�|$�6Rp��LlQS{1��1�Q*��&e]#:>���%;"쭖|�]�2��ӣ"><2�'F^#���M�GP�i*�H�M$'^���Z~
t$���h4�1�CI�ZeN"oG
��H]Qb�%���D��lJ1[���FHw��kA�GN��ًq�0�/���
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�1=�'���y�֑`j

l�U��;bn�]p���Gm���\�'��%Zv�&C�1!�+��h��51�zi�����-��t��N|T��_��_�P�]J�)S�w	VG��CA4��N��8�b�Z����Md'�C������Rp��]����<Vb𰫰�BŜ��	���Q�f�yD����	�Z��>ŃM�'�IB	)���h�}���*~��}"2��s��vD�����!�t�&��ޏ�|$�6Rp��LlQS{1��1�Q*��&e]#:>���%;"쭖|�]�2��ӣ"><2�'F^#���M�GP�i*�H�M$'^���Z~
t$���h4�1�CI�ZeN"oG
��H]Qb�%���D��lJ1[���FHw��kA�GN��ًq�0�/���
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
Q� u�]L���k��[*X�o�(!��Z�U�
`�y����D-٦*,,��������&�C�����-�ɭ�%�ىm�E�0V�%�2���A�����b�R�K'�n*\Q����[��b43
�Th
J�j4,*,qL�3���*9��*>-���9n�10j�~�TP�����an��H��J*�a@Z�qu�q��+ڄ4�1�ޠ���)R����J�~ɠ/�VG��g�x۰�#k*�K����������B��SYa�K��BТQPJ�EZa�����JWh5%J��Oq+�KR����,� 	D�������E�]��
�8q W�5���#{өD0��~Ai�H\��B�M�*�+�J:����i��ƌ ���ߨh����b���I���0���􍜱<u	8 ��P)( ����"5^҂<2�0��d����5ry��Qc��T�E�'d�7�1�Q��=���]�Y��7�[�9s�Y��|��R�\Z�ڙ=?��H`M�ܑ<W1!J�PU9�T��ɔ�*<B�4�\�?�.�����-C��]�#O�xP@Kg��?=FԷ����*_�{x{��~l�r�j����ǸqK=J: W�D���˄[.:WYp鄺o_�+��h�:N���%j�l�4nLF �K��PQ�;�����
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�Th
J�j4,*,qL�3���*9��*>-���9n�10j�~�TP�����an��H��J*�a@Z�qu�q��+ڄ4�1�ޠ���)R����J�~ɠ/�VG��g�x۰�#k*�K����������B��SYa�K��BТQPJ�EZa�����JWh5%J��Oq+�KR����,� 	D�������E�]��
�8q W�5���#{өD0��~Ai�H\��B�M�*�+�J:����i��ƌ ���ߨh����b���I���0���􍜱<u	8 ��P)( ����"5^҂<2�0��d����5ry��Qc��T�E�'d�7�1�Q��=���]�Y��7�[�9s�Y��|��R�\Z�ڙ=?��H`M�ܑ<W1!J�PU9�T��ɔ�*<B�4�\�?�.�����-C��]�#O�xP@Kg��?=FԷ����*_�{x{��~l�r�j����ǸqK=J: W�D���˄[.:WYp鄺o_�+��h�:N���%j�l�4nLF �K��PQ�;�����
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
��mع�LG�҃eS9�����a�� W�jo%���S��g�(V�v����J`i }�bYħ5r�u�d+�6�Jn�^���n��v�cɑ��Ń�`mUa���J�
-�1AA[�p�S�0i(�`�I�s@ש�S�ن��.Q.
4S�P[�_A�(7 [
1��f��)Md��P������
�w Ռ��"P��m�PQ��u(`v7B^����#�@��]��%3��)��U/ǈR��Sߛ�-n]0G��2�0H(�.r�"�	M�
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
��mع�LG�҃eS9�����a�� W�jo%���S��g�(V�v����J`i }�bYħ5r�u�d+�6�Jn�^���n��v�cɑ��Ń�`mUa���J�
-�1AA[�p�S�0i(�`�I�s@ש�S�ن��.Q.
4S�P[�_A�(7 [
1��f��)Md��P������
�w Ռ��"P��m�PQ��u(`v7B^����#�@��]��%3��)��U/ǈR��Sߛ�-n]0G��2�0H(�.r�"�	M�
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�#�G*;�����a��\\�^y�ar�>��a���1�-�U��5�K*�G��q�=A�J�`	Oi���0�:�/��~ �2�z���
��mع�LG�҃eS9�����a�� W�jo%���S��g�(V�v����J`i }�bYħ5r�u�d+�6�Jn�^���n��v�cɑ��Ń�`mUa���J�
-�1AA[�p�S�0i(�`�I�s@ש�S�ن��.Q.
4S�P[�_A�(7 [
1��f��)Md��P������
�w Ռ��"P��m�PQ��u(`v7B^����#�@��]��%3��)��U/ǈR��Sߛ�-n]0G��2�0H(�.r�"�	M�
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
��W?��qo"u1�@�Xh�E~a�ٵ�|�g�p��� a�v����U��T �;qY�%�Q`p�H�,�K���ǙYF��&^0<�~"Ń�8�F|�js��2�C��v`')߉1k���:k.�>[���/d���̴Os����%E���kvY(�\m|zpa��Z{�R��k:�Q����)�e�x'l&YJ	@jS��DV��m�Ng��Z
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
��W?��qo"u1�@�Xh�E~a�ٵ�|�g�p��� a�v����U��T �;qY�%�Q`p�H�,�K���ǙYF��&^0<�~"Ń�8�F|�js��2�C��v`')߉1k���:k.�>[���/d���̴Os����%E���kvY(�\m|zpa��Z{�R��k:�Q����)�e�x'l&YJ	@jS��DV��m�Ng��Z
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
�G:G3ұ0�L��0[����b��y����^1 �Ȧ�׸��6����|����	ߘ�PU^q̱1V�P�;�v��Ke]�,-�����q�x@E��1�@�R�p�WV�����#(ե� |֌�������W���Q��
̲G,(�)�N��j���z����H�@�y�JF�[S�0F8o"�^���H#�f�� ,
�9�<wp�AՎ�_�P�f �C����_OQ��{�z����͚�9�(��#��|���(8J�~#Ľf�\�@=���T����B���}f8�#ޣ:ڼ�a�9�� ϹU�MT7��<T�)I�?s4�����ϑ�F�Qx����_d.Q����#2���edU��M�ij��l\g/���"ظ��;6��XBꝚ�l�+��S�&7,ݠQ�)�����<.�����!|_oe�LX�h>g�{v��t^�&�`pb[�������N	�Y����6p����+{�U���5a� ��:��z��lI}�xAv�,�XO��5��{�����@��]��I���X�F�[�<* G"���q�4Q�{��&�K�y����xY�<��l�a59K
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
U��+F.��UE%�K@��E�u+0�����~߀�+$֑s��m�����[-�z/�(D8)q�Q����gO���������+��꓈�.�e�%*O�� 쑣�n��JC�w4��KW�m���¥�k��0�yxc7�p���G'~#�� �c�@D�vDu��wN��׸��6����|����	ߘ�PU^q̱1V�P�;�v��Ke]�,-�����q�x@E��1�@�R�p�WV�����#(ե� |֌�������W���Q��
̲G,(�)�N��j���z����H�@�y�JF�[S�0F8o"�^���H#�f�� ,
�9�<wp�AՎ�_�P�f �C����_OQ��{�z����͚�9�(��#��|���(8J�~#Ľf�\�@=���T����B���}f8�#ޣ:ڼ�a�9�� ϹU�MT7��<T�)I�?s4�����ϑ�F�Qx����_d.Q����#2���edU��M�ij��l\g/���"ظ��;6��XBꝚ�l�+��S�&7,ݠQ�)�����<.�����!|_oe�LX�h>g�{v��t^�&�`pb[�������N	�Y����6p����+{�U���5a� ��:��z��lI}�xAv�,�XO��5��{�����@��]��I���X�F�[�<* G"���q�4Q�{��&�K�y����xY�<��l�a59K
�R\���+�d ӄݻ-�q
��U^Cܹ�����)7�.��1T؏S._�̨eC/��8�F��D������k`�����v�-�F�R"N�/�
	@�8���5��W���x����)>
�y��s,��C�f�����9�`��s(�����y����8��<�!W���M^R���P�!d(`����h�qTqI��_.�A���0%p�e��0��b"��˜Fb��>�G����2���(-�\G��h�����0��Zf��v�V���Ll��4���6�a�l@s��y�ey��[��XE���B�@h�ʫɸ<��U�/2�[\��T6�k?�g0��r%$��r���Oޗ�Ai �Cu����$N� )�'s��.E��t7l�rX���Xy���ᖩ��:��
������ЀLF�^�T�.��I�k��SQ����+��bW\-��no��×"#!r�	��8cʨ
�p�Z{�[>���O��]%��^S�PV����?��ض8�M%x�I%�eO���o��ŶYλ ��4C����,}Wej���}��r�L��ޚ�(;����1���<}^�z�Rq��F���z(�*ʂo�f�}ލ��Eh\{L9e�6�k��-T'$J��HCJ�Å�)�r�C73�V
0Q�qW;nU�R��
,�\M�5$�㩺�
]��5��!`�������&��G��խU�Gdc�����3�"�O2� ބ+�>����#d%i<����&wZ]1�)�r����+%��� #�?������>��H  b_ �6P�,�7�1��	��qd�Z�5��e��ʥ�,G8gr��� ���p.��4s]D�Vi�x|J�Wa�E��%�T!Ez�fGq�����]��Q<���E`�8W�\�����{�\J
+�l�p_W8��~�X�H�պ��	�i�oE|�*�/�����;�n�uA�Nb(��r�`k��  6%�^FT�Gl�X,7g2�Z%������@�ҹ̲��~��0Z�_�
�k;D(�vP���X��}b�⁧�,\�klSa�osdZ0.�)���`k 1�opF׋r�����a���խ
�y�A)�=`�
-����g"�\���a�dٸQn|�WI�z3p@(�Υ�]��wG�<��,!�������߂k��S�
M+C�^f�����>Xt�����䇟��p.��m��^�#���ՙP�*���54��F+'�8#�;6y�,���U'��Y��l���v��]���4fTm�e,`<5���XU������_�@cmց}��v���itz�<w������C����TlU���/̻�� �����}g0~�ip@��wPT7�g��꡴H�
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
N�XZH��1�=��*Ń�y\��E��g�Y](9d�%�<��F��-����w����@P5�cř4�kG�ƒ���.����ks���S��˗e��8�X���&�<QWa�*�o�>�"[VZ�4U�[n����L��7����h�y!��y�^f"OJ�G0�S��,l��Ń}*T�bǍ��in1v���e������ש~���a(S]Y�PLwD@C�����j��R�*��}B��euS �G'���R�~~ ��$|��E�a��,��5󊨉Ge�k<K�+C�=�)�[0W̾�j��#9����ړ#W��"�������� �ClU����^��
���C��0����ԛ�t�"��hm�5��|�}����]a,�"*�N����[	��L[ �[wY���! >�3o�JJE���j���#)��C׸@�U�c���gw��_ :�b�s��&qkA�	�
-����g"�\���a�dٸQn|�WI�z3p@(�Υ�]��wG�<��,!�������߂k��S�
M+C�^f�����>Xt�����䇟��p.��m��^�#���ՙP�*���54��F+'�8#�;6y�,���U'��Y��l���v��]���4fTm�e,`<5���XU������_�@cmց}��v���itz�<w������C����TlU���/̻�� �����}g0~�ip@��wPT7�g��꡴H�
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
�N~�B��
X&�
6?q*����ĕ
���C��0����ԛ�t�"��hm�5��|�}����]a,�"*�N����[	��L[ �[wY���! >�3o�JJE���j���#)��C׸@�U�c���gw��_ :�b�s��&qkA�	�
-����g"�\���a�dٸQn|�WI�z3p@(�Υ�]��wG�<��,!�������߂k��S�
M+C�^f�����>Xt�����䇟��p.��m��^�#���ՙP�*���54��F+'�8#�;6y�,���U'��Y��l���v��]���4fTm�e,`<5���XU������_�@cmց}��v���itz�<w������C����TlU���/̻�� �����}g0~�ip@��wPT7�g��꡴H�
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
ۢ�X:����#���"�����D4C��?2����(ה82���P��
��3�y�d���1N�0J�Y�O�:��,����<�� �ȇ_h���(�dH  ���T��h���Vݾ��^U�_ܧ�}]�������X��\v��z���O�t�B R��.1�%]�����'�8[eEF
(�NH���BϹ
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
ۢ�X:����#���"�����D4C��?2����(ה82���P��
��3�y�d���1N�0J�Y�O�:��,����<�� �ȇ_h���(�dH  ���T��h���Vݾ��^U�_ܧ�}]�������X��\v��z���O�t�B R��.1�%]�����'�8[eEF
(�NH���BϹ
(k�7J �=�
0Q�qW;nU�R��
,�\M�5$�㩺�
(�NH���BϹ
E�