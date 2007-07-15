
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "coefficients.h"
#include "input.h"

#define DEBUG 0
#define DEBUG_DUMPRES 1

static const short coef[] = {
  0,6,37,63,-26,-215,-440,-590,-72,961,1713,2141,1073,-1299,-2686,
  -3281,-2360,392,2129,2491,2198,573,-1578,-2136,-1984,-1688,825,
  2582,2342,2582,825,-1688,-1984,-2136,-1578,573,2198,2491,2129,
  392,-2360,-3281,-2686,-1299,1073,2141,1713,961,-72,-590,-440,
  -215,-26,63,37,6,0
};



#define FIRLEN (sizeof(coef)/sizeof(short))


int main(int argc, char *argv[])
{
  FILE *fp;
  char *outfilename;

  short out[INLEN];
  int i, sample, blocksample, tap;
  int blocklen, nblocks;
  int b;
  int lbound, ubound;

  
  /* command-line arguments */
  int fifodepth;  /* FIFO depth */
  short padding;  /* false/true */

  /* read in command-line arguments */
  if ((argc<3) || (argc>4)) {
    printf("Usage: fir_zippy FD PT [OF]\n");
    printf("  FD: FIFO depth (int)\n");
    printf("  PT: padding tag (yes/no: 1/0)\n");
    printf("  OF: name of output file (string) [optional]\n");
    exit(1);
  } else {
    fifodepth   = atoi(argv[1]);
    padding     = atoi(argv[2]);
    if (argc == 4) {
      outfilename = argv[3];
    } else {
      outfilename = "fir_noarray.out";
    }
  }

#if DEBUG_DUMPRES
  /* open output file */
  fp = fopen(outfilename,"w");
#endif DEBUG_DUMPRES

 /* convolution:

                    N-1
     out(sample) =  SUM coef(tap)*in(sample-tap)
                    tap=0

  */

  /*** compute block length and no. of blocks ************************/
  if (padding) {
    blocklen = fifodepth - FIRLEN;
  } else {
    blocklen = fifodepth;
  }
  nblocks = (int) ceil((double)INLEN/blocklen); /* beware of int div. */

#if DEBUG
  printf("\nblock processing: blocklen=%d, nblocks=%d\n",blocklen,nblocks);
#endif
    
  /* process data blocks *********************************************/
  for(b=0; b<nblocks; b++){

    lbound = b*blocklen;
    ubound = lbound+blocklen;

    if (ubound >= INLEN) { /* clipping for last (ev. partial) block */
      ubound = INLEN;
    } 
    
    for(sample=lbound; sample<ubound; sample++){
      blocksample = sample % blocklen;
      out[blocksample]=0;

      for(tap=0; tap<FIRLEN; tap++){
        if (padding) {
          out[blocksample] +=
            (((sample-tap)>= 0) ? in[sample-tap] : 0) * coef[tap];
        } else {
          out[blocksample] +=
            (((blocksample-tap)>= 0) ? in[sample-tap] : 0) * coef[tap];
        }
      }
    }
    
#if DEBUG_DUMPRES
    fprintf(fp,"block: %d\n",b);
    for(i=0; i<(ubound-lbound); i++){
      fprintf(fp,"%d\n",out[i]);
    }
    fprintf(fp,"\n");
    fflush(fp);
#endif

  } /* for b */

  fclose(fp);
}
