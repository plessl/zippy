/* $Id: $ */
/* $URL$ */

#define DEBUG 0
#define DEBUG_FIFO_WRITE 0
#define DEBUG_CFG_DOWNLOAD 0
#define VERIFICATION 0
#define DEBUG_DUMPRES 0

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <unistd.h>

#include "adpcm.h"
/* void adpcm_decoder(char indata[], short outdata[],        */
/*                     int len, struct adpcm_state * state); */

#include "test.adpcm.h"
#include "test.pcm.h"
/* test vectors */
/* test.adpcm.h defines char adpcmData[ADPCMLEN_BYTES]  */
/*   adpcmData contains ADPCMLEN_SAMPLES data samples   */
/* test.pcm.h   defines short pcmData[PCMLEN]           */


void usage();

int main(int argc, char *argv[])
{

  int maxiter, iter;
  
#if DEBUG_DUMPRES
  FILE *fp;
  char *outfilename = argv[2];
#endif  
  int i;

  
#if VERIFICATION
  int j;
  int verification_ok = 1;
  char adpcmSample;
#endif
  
  struct adpcm_state state;
  short decoded[PCMLEN];

  if(argc <= 1){
    usage(argv[0]);
    exit(-1);
  }
  maxiter = atoi(argv[1]);

#if DEBUG
  printf("running for %d iterations\n",maxiter);
#endif
  
  
#if DEBUG_DUMPRES
#if DEBUG
  /* dump results to output file */
  printf("\ndumping results to output file (be aware that delay may\n");
  printf("later be introduced during simulation)\n\n");
#endif
  fp = fopen(outfilename,"w");   /* open output file */
  if (!fp) {
    perror("output file");
    exit(-1);
  }
  
#endif

  for(iter=0;iter<maxiter;iter++){
  
    adpcm_decoder(adpcmData, decoded, PCMLEN, &state);

#if DEBUG_DUMPRES
    for(i=0;i<PCMLEN;i++){
      fprintf(fp,"0x%04X\n",decoded[i]);
    }
#endif

  
#if VERIFICATION  
    for(i=0;i<PCMLEN;i++){
      j = i >> 1;
      if ((i % 2) == 0){
        adpcmSample = adpcmData[j] & 0xf;
      } else {
        adpcmSample = (adpcmData[j] >> 4) & 0xf;
      }
      printf("%d/%d adpcm: 0x%1X response: 0x%04X (expected: 0x%04X) ",
             i,PCMLEN,adpcmData[i],decoded[i],pcmData[i]);
      if (decoded[i] == pcmData[i]) {
        printf("OK\n");        
      } else {
        printf("FAILED\n");
        verification_ok = 0;
      }
    }
    if (verification_ok){
      printf("verification succeeded, all test vectors correct\n");
    } else {
      printf("verification failed!!\n");
    }
#endif    


  } /* for i=0..maxiter */


  
#if DEBUG_DUMPRES
    fclose(fp);
#endif

    /*asm("nop;nop;"); */ /** FIXME: sim. may behave nasty without **/

    return 0;
}

void usage(char* progname)
{
  fprintf(stderr,"missing arguments: %s iter\n",progname);
  fprintf(stderr,"   iter: number of iterations that should be performed\n");
}
