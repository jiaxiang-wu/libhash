#include <mex.h>
#include <stdio.h>
#include <math.h>
/////// Main semantic hash + randomizing hash routine
/////// Version 1.0, Rob Fergus (fergus@cs.nyu.edu), 1/4/09

/////// Known bugs:
/////// The while loops won't terminate if the hash table becomes full. To make sure the hash table is always sparse make sure TABLE_BITS is large enough. 


//// Parameters that the user can alter
#define TABLE_BITS     20 // Number of bits in table. This control the memory requirements of the hash table.
                          // the actual size will be a prime number that is a bit smaller that 2^TABLE_BITS bits.
                          // Hence TABLE_BITS sets the upper bound on the memory requirement. Please make sure that 2^TABLE_BITS is quite a bit larger than the number of training vectors. If the hash table becomes full it becomes very inefficient. 

#define MAX_RETURN     1000 // Max. number of neighbors returned.

#define COLLISION_OFFSET 15 // Is there is a hash collision, add this and re-hash to find an empty bin.

//// Don't alter things below here...

/* Input Arguments */
#define	MAT      prhs[0] // Uint8 vector of size n x m - matrix of training data
#define HAM_RAD       prhs[1] // Uint8 integer of hamming distance to search

/* Output Arguments */
#define	OUTPUT	plhs[0] // Double vector p x MAX_RETURN, list of all  binary hamming distance to the p test cases

 
typedef struct ns {
        int data;
        unsigned long long key;
        struct ns *next;
} node;
 
node *list_add(node **p, node*n,  int i, unsigned long long j) {
    /* some compilers don't require a cast of return value for malloc */
    //node *n = (node *)mxMalloc(sizeof(node));
  
  // mexPrintf("Existing pointer: %p, new pointer: %p, new value: %d\n",*p,n,i);
    if ((n) == NULL)
        return NULL;
    (n)->next = *p;                                                                            
    *p = (n);
    (n)->data = i;
    (n)->key = j;
    return (n);
}
 
node* list_remove(node **p) { /* remove head */
    if (*p != NULL) {
        node *n = *p;
        *p = (*p)->next;
        mxFree(n);
    }
    return *p;
}
 
unsigned long long node_key(node *n) {
  return n->key;
}
 
node **list_search(node **n, int i) {
    while (*n != NULL) {
        if ((*n)->data == i) {
            return n;
        }
        n = &(*n)->next;
    }
    return NULL;
}
 
void list_print(node *n) {
    if (n == NULL) {
        printf("list is empty\n");
    }
    while (n != NULL) {
      printf("print %p %p %d %llu\n", n, n->next, n->data, n->key);
        n = n->next;
    }
}
 
int list_copy(node *n, int** output, int offset, int limit) {
  int i=0;
    if (n == NULL) {
        printf("list is empty\n");
    }
    while ((n != NULL)  && (i<limit)){
      //printf("print %p %p %d\n", n, n->next, n->data);
      //  mexPrintf("Index: %d, pointer: %p\n",i,(*output+offset+i));
	*(*output+offset+i) = (n->data)+1;  // 1 based indexing
	//	mexPrintf("Index: %d, pointer: %p, value: %d, correct value: %d\n",i,(*output+offset+i),*(*output+offset+i),(n->data)+1);
	i++;
	n = n->next;
    }
   
    return i; 
}
 

static int initialized = 0;
static node* linked_list_nodes=NULL;
static node** pHashTable=NULL;
static unsigned long long* xor_vectors=NULL;
static int num_xor_vectors = 0;

void cleanup(void) {
    mexPrintf("MEX-file is terminating\nDestroying linked-list nodes...");
    mxFree(linked_list_nodes);
    mexPrintf("done\nDestroying hash table...");
    mxFree(xor_vectors);
    mxFree(pHashTable);
    mexPrintf("done\n");
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
  int nBytes, nTrain, nTest, i, j, k, l, found, tally, offset, limit, ham_dist, max_xor_vectors;
  unsigned long hash_table_size, hash_key, nNodes;
  unsigned long long big_hash_key, xor_vec,  xor_vec2,  xor_vec3,  xor_vec4, new_hash_key, new_hash_key2, xor_vec_max, tmp;
  int *outputp, *outputp_base;
  unsigned char *pMat;
  double *pHam_Radius;
  unsigned long long byte_offset[8];
  unsigned long long hash_prime[32];

  // offsets for each byte 1st .. 8th
  byte_offset[0] = 1;
  byte_offset[1] = 256;
  byte_offset[2] = 65536;
  byte_offset[3] = 16777216;
  byte_offset[4] = 4294967296;
  byte_offset[5] = 1099511627776;
  byte_offset[6] = 281474976710656;
  byte_offset[7] = 72057594037927936;
 
  // manually specify prime numbers for second hash operation.
  hash_prime[7] = 97;
  hash_prime[8] = 193;
  hash_prime[9] = 389;
  hash_prime[10] = 769;
  hash_prime[11] = 1543;
  hash_prime[12] = 3079;
  hash_prime[13] = 6151;
  hash_prime[14] = 12289;
  hash_prime[15] = 24593;
  hash_prime[16] = 49157;
  hash_prime[17] = 98317;
  hash_prime[18] =    196613;
  hash_prime[19] =    393241;
  hash_prime[20] =    786433;
  hash_prime[21] =    1572869;
  hash_prime[22] =    3145739;  
  hash_prime[23] =    6291469;
  hash_prime[24] =    12582917;
  hash_prime[25] =    25165843;
  hash_prime[26] =    50331653;
  hash_prime[27] =    100663319;
  hash_prime[28] =    201326611;
  hash_prime[29] =    402653189;
  hash_prime[30] =    805306457;
  hash_prime[31] =    1610612741;

  if (!initialized) {
    // Hash table creation
   
    /* Check for proper number of arguments */
    
    if (nrhs != 2) { 
      mexErrMsgTxt("Hash table creation - two arguments required."); 
    } else if (nlhs != 1) {
      mexErrMsgTxt("Hash table creation - one output argument rqeuired."); 
    } 

    if (!mxIsUint8(MAT))
      mexErrMsgTxt("Train matrix must be uInt8");

    /* Check size of prime number for hashing */ 
    if ((TABLE_BITS<7) | (TABLE_BITS>31))
      mexErrMsgTxt("Please set TABLE_BITS to be between 7 and 31 and recompile.");
      
  /* Get dimensions of image and kernel */
    nBytes = (int)  mxGetM(MAT); 
    nTrain = (int)  mxGetN(MAT); 
    
    if (nBytes>8)
      mexErrMsgTxt("Too many bits -- please use 64 or less");
    
    mexPrintf("Creating hash table....\n");
    mexPrintf("Bytes: %d Bits: %d  Train vectors: %d\n",nBytes,TABLE_BITS,nTrain);
    
    OUTPUT = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
    outputp = (int*) mxGetPr(OUTPUT);

    // Get radius
    pHam_Radius = mxGetPr(HAM_RAD);
    ham_dist = (int) round(pHam_Radius[0]);

    if (ham_dist>4)
      mexErrMsgTxt("Hamming distance <=4 supported.");

    // upper bound on # of vectors
    max_xor_vectors = 1+(int) round(pow(nBytes*8,pHam_Radius[0]));
    // allocate memory
    mexPrintf("Hamming distance: %d, created space for %d xor vectors\n",ham_dist,max_xor_vectors);
    xor_vectors =  (unsigned long long*) mxCalloc(max_xor_vectors+1, sizeof(unsigned long long));


    // Create pointer array
    hash_table_size = hash_prime[TABLE_BITS];
    pHashTable = (node**) mxCalloc(hash_table_size, sizeof(node*));
    mexPrintf("Created hash table pointers (%u of them), each %d bytes\n",hash_table_size,sizeof(node*));
  
    // Create linked_list array
    linked_list_nodes = (node*) mxCalloc(nTrain, sizeof(node));
    mexPrintf("Create linked list pointers (%d of them), each %d bytes\n",nTrain,sizeof(node));

    // Make persistent 
    mexMakeMemoryPersistent(pHashTable);
    mexMakeMemoryPersistent(linked_list_nodes);
    mexMakeMemoryPersistent(xor_vectors);


    pMat = (unsigned char*) mxGetPr(MAT);
    nNodes = 0;

       
    for (i=0;i<nTrain;i++){
      
      big_hash_key = 0;
      
      for (j=0;j<nBytes;j++){
	big_hash_key += ( pMat[i*nBytes+j] * byte_offset[j] );
      	//mexPrintf("hash key: %d, pMat: %d, byte_offset[%d]=%llu\n",big_hash_key,pMat[i*nBytes+j],j,byte_offset[j]);
      }

      // Now reduce to fit in table of 2^TABLE_BITS
      hash_key = big_hash_key % hash_prime[TABLE_BITS];

      // Handle hash collisions
      // Try different offsets until we find an empty slot
      // Note, that if the big_hash_key is the same, then we don't do this since the overall
      // bit vectors are the same and rely on the linked list stucture to store multiple entries in the same memory location. We only need this if the reduction from the large bit vector to the smaller sized hash_prime[TABLE_BITS] memory block causes two unrelated bit vectors in the original space to collide.

      // This part has a potential serious bug: if the hash table becomes full, then it will never exit the while loop below.... needs fixing at some point....x
      k = COLLISION_OFFSET;
      while ( (pHashTable[hash_key]!=NULL) && (node_key(pHashTable[hash_key])!=big_hash_key) ){
	//mexPrintf("i: %d Big hash key: %llu, hash_key: %lu, offset: %llu, k: %d\n",i,big_hash_key,hash_key,node_key(pHashTable[hash_key]),k);
	hash_key = (big_hash_key+k) %  hash_prime[TABLE_BITS];
	//mexPrintf("new hash key: %llu\n",hash_key);
	//mexPrintf("%d\n",k);
	k += COLLISION_OFFSET;
      }

      //mexPrintf("Big hash key: %llu, hash_key: %lu\n",big_hash_key,hash_key);

      // Empty, so add in entry
      pHashTable[hash_key] = list_add(&pHashTable[hash_key],&linked_list_nodes[nNodes], i, big_hash_key);
      //mexPrintf("Added element to list\n");
      //list_print(pHashTable[hash_key]);
	
      nNodes++;
      
    }
    
    mexPrintf("Hash table successfully built, using %d training examples\n",nTrain);
 
    // Create xor vectors for hamming ball
    // this section is really messy, but I couldn't think of a another way to generate xor vectors 
    // without repeats occurring -- this version does do that though.
    num_xor_vectors = 1;
    xor_vectors[0] = 0;

   if (ham_dist>=1){
      
      for (i=0;i<=((nBytes*8)-1);i++){
	xor_vectors[num_xor_vectors] += (0x1 << i);
	num_xor_vectors++;
      }

    }
  
    if (ham_dist>=2){
      

     for (i=0;i<=((nBytes*8)-1);i++){
       for (j=i+1;j<=((nBytes*8)-1);j++){
	 if (i!=j){
	   xor_vectors[num_xor_vectors] += (0x1 << i);
	   xor_vectors[num_xor_vectors] += (0x1 << j);
	   num_xor_vectors++;
	 }
       }
     }
 
    }
  
    if (ham_dist>=3){
      
      for (i=0;i<=((nBytes*8)-1);i++){
	for (j=i+1;j<=((nBytes*8)-1);j++){
	  for (k=j+1;k<=((nBytes*8)-1);k++){
	    if ((i!=j) && (i!=k) && (j!=k)){
	      xor_vectors[num_xor_vectors] += (0x1 << i);
	      xor_vectors[num_xor_vectors] += (0x1 << j);
	      xor_vectors[num_xor_vectors] += (0x1 << k);
	      num_xor_vectors++;
	    }
	  }
	} 
      }
    }
  
    if (ham_dist==4){
      
      for (i=0;i<=((nBytes*8)-1);i++){
	for (j=i+1;j<=((nBytes*8)-1);j++){
	  for (k=j+1;k<=((nBytes*8)-1);k++){
	    for (l=k+1;l<=((nBytes*8)-1);l++){
	      if ((i!=j) && (i!=k) && (j!=k) && (i!=l) && (l!=k) && (j!=l)){
		xor_vectors[num_xor_vectors] += (0x1 << i);
		xor_vectors[num_xor_vectors] += (0x1 << j);
		xor_vectors[num_xor_vectors] += (0x1 << k);
		xor_vectors[num_xor_vectors] += (0x1 << l);
		num_xor_vectors++;
	      }
	    }
	  }
	}
      }

    }


    // Resize
    xor_vectors = (unsigned long long*) mxRealloc(xor_vectors,num_xor_vectors*sizeof(unsigned long long));
    mexPrintf("Pre-computed all %d xor vectors\n\n",num_xor_vectors);

    // Sanity check
    //for (xor_vec=0; xor_vec<num_xor_vectors; xor_vec++){
    /////  mexPrintf("Vector: %d, xor_vector: %llu\n",xor_vec,xor_vectors[xor_vec]);
    //}


    // Setup clean-up routine
    mexAtExit(cleanup);
    // Set initialized flag
    initialized = 1;
    // Set output
    outputp[0]=1;

  }
  else{ 

    /* Check for proper number of arguments */
    
    if (nrhs != 1) { 
      mexErrMsgTxt("Hash table use - one argument required."); 
    } else if (nlhs != 1) {
      mexErrMsgTxt("Hash table use- one output argument rqeuired."); 
    } 

    if (!mxIsUint8(MAT))
      mexErrMsgTxt("Test matrix must be uInt8");

    /* Get dimensions of image and kernel */
    nBytes = (int)  mxGetM(MAT); 
    nTest = (int)  mxGetN(MAT); 
        
    // Check to see if hash table exist
    if ((pHashTable==NULL) || (linked_list_nodes==NULL) || (xor_vectors==NULL))
      mexErrMsgTxt("Cannot find hash table or linked list nodes");
    else{
      //mexPrintf("Found hash table....\n");
      //mexPrintf("Bytes: %d  Test vectors: %d\n",nBytes,nTest);
    }
    
    // Make output matrix
    //mexPrintf("Creating output matrix of size: %d  by %d\n",nTest,MAX_RETURN);
    OUTPUT = mxCreateNumericMatrix(MAX_RETURN,nTest,mxINT32_CLASS,mxREAL);
    outputp = (int*) mxGetPr(OUTPUT);
    outputp_base = (int*) mxGetPr(OUTPUT);

    
    // Test mode
    //mexPrintf("Now put test data into hash\n");
    pMat = (unsigned char*) mxGetPr(MAT);
 
    //mexPrintf("Output array start address: %p\n",outputp);
    
    for (i=0;i<nTest;i++){
      
      big_hash_key = 0; tally = 0;
     
      for (j=0;j<nBytes;j++)
	big_hash_key += ( pMat[i*nBytes+j] * byte_offset[j] );
      
      // Now search over hamming ball
       for (k=0;k<num_xor_vectors;k++){
	 //mexPrintf("k: %d, num_xor_vectors: %llu, Tally: %d, MAX_RETURN: %d\n",k,num_xor_vectors,tally,MAX_RETURN);
	
	if (tally<MAX_RETURN){
	  
	  new_hash_key = big_hash_key ^ xor_vectors[k]; // peturb bit vector
	  new_hash_key2 = new_hash_key %  hash_prime[TABLE_BITS]; // do 2nd randomizing hash
	  
	  //mexPrintf("Big hash key: %llu, Xor vec: %llu, new hash key: %lu\n",big_hash_key,xor_vectors[k],new_hash_key);
	  // check for collision.
	  j=COLLISION_OFFSET;
	  while ( (pHashTable[new_hash_key2]!=NULL) && (node_key(pHashTable[new_hash_key2])!=new_hash_key) ){
	    new_hash_key2 = (new_hash_key + j) %  hash_prime[TABLE_BITS];
	    //     mexPrintf("Big hash key: %u, hash_key: %u, offset: %d\n",new_hash_key,new_hash_key2,j);
	    j+=COLLISION_OFFSET;
	  }
	  // mexPrintf("Big hash key: %llu, Xor vec: %llu, new hash key: %lu\n",big_hash_key,xor_vectors[k],new_hash_key2);

	  // Now see if there is a linked list at this location
	  if (pHashTable[new_hash_key2]!=NULL){

	    //list_print(pHashTable[new_hash_key2]);
	  
	    // We found a list
	    offset = (i*MAX_RETURN) + tally;
	    limit = MAX_RETURN - tally;
	    //mexPrintf("Cigar! - Found list with pointer: %p, passing in output location: %p\n",pHashTable[new_hash_key],&outputp,offset);
	    // Now copy the contents of the list into output array
	    found = list_copy(pHashTable[new_hash_key2],&outputp,offset,limit);
	    //mexPrintf("Copied %d elements from list\n",found);
	    
	    // inc. pointer
	    tally += found;
	    //mexPrintf("Tally is %d\n",tally);
	    
	  } 
	  
	  
	}// safety on max_return
	else{
	  //mexPrintf("Too many found for example: %d, skipping..\n",i);
	} 
       }// loop over xor vectors
      
       
    } // loop over testing images
  } // end of else


  return;
    
}

