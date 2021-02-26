#include<stdio.h>
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

}// end of main
