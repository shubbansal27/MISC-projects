OS_PROJECT
-----------
Image-file system for android:  version 2

Objective : design a file system for android camera app with optimized overhead.

Team members:
--------------
1. Dipesh Palod
2. Shivam Agarwal
3. Shubham Bansal


IDEA:
-----
in version-1 :  
		we have implemented linked block allocation that is traditional approach. block size is 4 KB. each block contains intial 6 bytes for addressing next 			block. and remaining 4090 bytes are data.

 
problem:       there is always 6 bytes westage of memory which is large overhead. Instead of this internal fragmentation is also there. Now we have challenge to 		       reduce this overhead. 



Now version-2:
		initially we didn't notice that we have a known range of image size for android camera. now idea is that if we try to allocate blocks in contigious 			fashion as much as possible, we can get rid of those 6 address bytes.  now whole idea is about hybrid of linked and contigious.
		we are now linking several contigious chain of blocks only by writing 12 intial bytes for addressing in each first block of each chain.

		assumption: image size is large(> 250 KB)
		----------
		benifit:   a large number of contigious blocks are always avialable even after deleting any image file.

 



 
