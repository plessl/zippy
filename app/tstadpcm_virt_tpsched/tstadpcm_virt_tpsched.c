#define DEBUG 0

#define DEBUG_FIFO_WRITE 0

#define DEBUG_CFG_DOWNLOAD 0

#define VERIFICATION 0

#define DEBUG_DUMPRES 0

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <unistd.h>

#include "tstadpcm_virt_tpsched_cfg.h"

/*
 *   -- ZUnit Register Mapping and Functions:
 *
 *   --   0   Reset                     W
 *   --   1   FIFO0                     R/W
 *   --   2   FIFO0 Level               R
 *   --   3   FIFO1                     R/W
 *   --   4   FIFO1 Level               R
 *   --   5   Run Cycle Counter         R/W
 *   --   6   CfgMemory0                W
 *   --   7   CfgMemory0 Pointer        W
 *   --   8   CfgMemory1                W
 *   --   9   CfgMemory1 Pointer        W
 *   --  10   CfgMemory2                W
 *   --  11   CfgMemory2 Pointer        W
 *   --  12   CfgMemory3                W
 *   --  13   CfgMemory3 Pointer        W
 *   --  14   CfgMemory4                W
 *   --  15   CfgMemory4 Pointer        W
 *   --  16   CfgMemory5                W
 *   --  17   CfgMemory5 Pointer        W
 *   --  18   CfgMemory6                W
 *   --  19   CfgMemory6 Pointer        W
 *   --  20   CfgMemory7                W
 *   --  21   CfgMemory7 Pointer        W
 *   --  22   Context SelReg wo/ clear  W
 *   --  23   Context SelReg w/ clear   W
 *   -- 125   Context Schedule Start    W
 *   -- 126   Context Schedule Status   R
 *   -- 127   Context Schedule Program  W
 *   -- 128   ""
 *   -- ...   ""
 *   -- 134   ""
 */
#define ZREG_RST           0
#define ZREG_FIFO0         1
#define ZREG_FIFO0LEV      2
#define ZREG_FIFO1         3
#define ZREG_FIFO1LEV      4
#define ZREG_CYCLECNT      5
#define ZREG_CFGMEM0       6
#define ZREG_CFGMEM0PTR    7
#define ZREG_CFGMEM1       8
#define ZREG_CFGMEM1PTR    9
#define ZREG_CFGMEM2       10
#define ZREG_CFGMEM2PTR    11
#define ZREG_CFGMEM3       12
#define ZREG_CFGMEM3PTR    13
#define ZREG_CFGMEM4       14
#define ZREG_CFGMEM4PTR    15
#define ZREG_CFGMEM5       16
#define ZREG_CFGMEM5PTR    17
#define ZREG_CFGMEM6       18
#define ZREG_CFGMEM6PTR    19
#define ZREG_CFGMEM7       20
#define ZREG_CFGMEM7PTR    21
#define ZREG_CONTEXTSEL    22
#define ZREG_CONTEXTSELCLR 23

/* set number of contexts, used for cyclic context activation with
   temporal partitioning. */

#define ZREG_VIRTCONTEXTNO  50
#define ZREG_CONTEXTSCHEDSEL 51
/* -- 0: context sequencer and cycle counter
   -- 1: temporal paritioning scheduler */

#define ZREG_SCHEDSTART    125
#define ZREG_SCHEDSTATUS   126
#define ZREG_SCHEDIWORD00  127
#define ZREG_SCHEDIWORD01  128
#define ZREG_SCHEDIWORD02  129
#define ZREG_SCHEDIWORD03  130
#define ZREG_SCHEDIWORD04  131
#define ZREG_SCHEDIWORD05  132
#define ZREG_SCHEDIWORD06  133
#define ZREG_SCHEDIWORD07  134

static const short contextreg[] = {
  ZREG_CFGMEM0, ZREG_CFGMEM1, ZREG_CFGMEM2, ZREG_CFGMEM3,
  ZREG_CFGMEM4, ZREG_CFGMEM5, ZREG_CFGMEM6, ZREG_CFGMEM7};

static const short schedulestore[] = {
  ZREG_SCHEDIWORD00, ZREG_SCHEDIWORD01, ZREG_SCHEDIWORD02,
  ZREG_SCHEDIWORD03, ZREG_SCHEDIWORD04, ZREG_SCHEDIWORD05,
  ZREG_SCHEDIWORD06, ZREG_SCHEDIWORD07};

/* test vectors */

/* test.adpcm.h defines char adpcmData[ADPCMLEN_BYTES] */
/* test.pcm.h   defines short pcmData[PCMLEN]          */

#include "test.adpcm.h"
#include "test.pcm.h"


#define zippy_stop_sim()                                            \
    asm volatile("zippy_stop_sim $0,$0,$0")


#define zippy_get_reg(x)                                            \
  ({ int __result, __what = (x);                          \
  asm volatile("zippy_get_reg %0,%1" : "=r" (__result): "r" (__what)); \
  __result; })

#define zippy_set_reg(myreg,myvalue)                                      \
({ int __result; int __reg = (myreg); int __value = (myvalue);            \
asm volatile("zippy_set_reg %0,%1,%2" : "=r" (__result): "r" (__reg), "r" (__value));  \
__result; })
        

void usage();

int main(int argc, char *argv[])
{
  FILE *fp;
  char *outfilename;
  char *infilename1;
  char *infilename2;

  int i,j,c;
  int maxiter, iter;
  unsigned char sample;
  
  short val;  
  short runcycles;
  unsigned short level;

  int verification_ok = 1;

  int zippycontexts = 3; /* This application uses 3 contexts */

  if(argc <= 1){
    usage(argv[0]);
    exit(-1);
  }
  maxiter = atoi(argv[1]);



    
#if DEBUG_DUMPRES

#if DEBUG
  /* dump results to output file */
  printf("\ndumping results to output file (be aware that delay may\n");
  printf("later be introduced during simulation)\n\n");
#endif

  /* open output file */
  fp = fopen(outfilename,"w");
#endif DEBUG_DUMPRES


#if DEBUG  
  printf("resetting zippy array\n\n");
#endif  
  zippy_set_reg(ZREG_RST,0);   /* reset ZIPPY array */

  /* download contexts (first # zippycontexts) */

  for(c=0; c<zippycontexts; c++){
#if DEBUG
    printf("loading app. context %d into context memory %d\n",
           c, c);
#endif
    for(i=0; i<NCFGPARTS; i++){
#if DEBUG_CFG_DOWNLOAD
      printf("  downloading context %d - slice %d - `%#.*X'\n",
             c, i, PARTWIDTH/4, contextdata[c][i]);
#endif
      zippy_set_reg(contextreg[c], contextdata[c][i]);
    }
  }


  for(iter=1;iter<=maxiter;iter++){

#if DEBUG
    printf("\niteration: %d of %d ------------ \n",iter,maxiter);
#endif
    
     /******* fill FIFO_0 with input data *************/
     for(i=0;i<ADPCMLEN_SAMPLES;i++) {
       j = i >> 1;
       if (( i % 2) == 1){
         sample = adpcmData[j] & 0xf;
       } else {
         sample = (adpcmData[j] >> 4) & 0xf;
       }

#if DEBUG_FIFO_WRITE       
       printf("write sample %d val: 0x%1X\n",i,sample);
#endif
       zippy_set_reg(ZREG_FIFO0,sample);
     }
      
#if DEBUG  
     printf("\nFIFO_0 fill level = %d\n\n", zippy_get_reg(ZREG_FIFO0LEV));
#endif

#if DEBUG
     printf("setting up the temporal partitioning context sequencer\n");
#endif


     /* this application requires that the contexts are reset because
        we run maxiter independent iterations of the algorithm

        The temporal partitioning sequencer does not support resetting
        the contexts, hence we reset the contexts in the context
        sequencer mode
     */
     
     zippy_set_reg(ZREG_CONTEXTSCHEDSEL,0);
     zippy_set_reg(ZREG_CYCLECNT,0);
     zippy_set_reg(ZREG_CONTEXTSELCLR,2);
     zippy_set_reg(ZREG_CONTEXTSELCLR,1);
     zippy_set_reg(ZREG_CONTEXTSELCLR,0);
     
     /* setup temporal partitioning context sequencer  */
     zippy_set_reg(ZREG_CONTEXTSCHEDSEL,1);
     zippy_set_reg(ZREG_VIRTCONTEXTNO,3);

     runcycles = PCMLEN + 2;
     
#if DEBUG
     printf("starting the array for %d cycles\n", runcycles);
#endif
     zippy_set_reg(ZREG_CYCLECNT,runcycles);
     zippy_set_reg(ZREG_SCHEDSTART,1);
     
     
     while ((i = zippy_get_reg(ZREG_CYCLECNT)) > 0){

#if DEBUG    
       printf("polling cycle count register: %d\n",i);
#endif
       ;  /* wait */
     }
      
#if DEBUG  
     printf("\n");
     printf("FIFO_0 fill level = %d\n", zippy_get_reg(ZREG_FIFO0LEV));
     printf("FIFO_1 fill level = %d\n", zippy_get_reg(ZREG_FIFO1LEV));
     printf("\n");
#endif

     level = zippy_get_reg(ZREG_FIFO1LEV);

#if DEBUG
     printf("there are %d data values in FIFO_1\n", level);
     printf("reading data from FIFO_1\n");
#endif

     /* discard two dummy words introduced by pipelining */
     val = zippy_get_reg(ZREG_FIFO1);
     val = zippy_get_reg(ZREG_FIFO1);
     level = level - 2; 

     for(i=0; i<level; i++){
       val = zippy_get_reg(ZREG_FIFO1);

#if DEBUG_DUMPRES
       fprintf(fp,"0x%04X\n",val);
#endif
      
#if VERIFICATION
       printf(" %d/%d: reponse: 0x%04X (expected: 0x%04X) ",
              i,level-1,val,pcmData[i]);
       if (val == pcmData[i]) {
         printf("OK\n");        
       } else {
         printf("FAILED\n");
         verification_ok = 0;
       }
#endif    

     } /* read all results data from FIFO_1 */

#if VERIFICATION
     if (verification_ok){
       printf("verification succeeded, all test vectors correct\n");
     } else {
       printf("verification failed!!\n");
     }
#endif
    
#if DEBUG
    printf("\n");
    printf("FIFO_0 fill level = %d\n", zippy_get_reg(ZREG_FIFO0LEV));
    printf("FIFO_1 fill level = %d\n", zippy_get_reg(ZREG_FIFO1LEV));
#endif
    
   } /* for i=0..maxiter */
    

#if DEBUG_DUMPRES
    fflush(fp);
#endif    

    
  asm("nop;nop;"); /** FIXME: sim. may behave nasty without **/

/*  fclose(fp); */

  /*******************************************************************/
  /* terminate simulation                                            */
  /*******************************************************************/
  zippy_stop_sim();
}

void usage(char* progname)
{
  fprintf(stderr,"missing arguments: %s iter\n",progname);
  fprintf(stderr,"   iter: number of iterations that should be performed\n");
}
