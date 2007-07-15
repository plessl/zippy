#define DEBUG 1

#define DEBUG_FIFO_WRITE 1

#define DEBUG_CFG_DOWNLOAD 1

#define VERIFICATION 1

#define DEBUG_DUMPRES 0




#include <stdio.h>
#include <math.h>
#include "tstbitat0_cfg.h"

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
static const short testv[] = {
  /* INFIFO1, INFIFO2, expected result */
  0x0000, 0x0F0F, 0xFFFF,
  0x0000, 0x0000, 0xFFFF,
  0x7DA5, 0x8202, 0xFFFF,
  0xD5D8, 0xB020, 0x0000,
  0x97E1, 0x2C00, 0x0000,
  0x97E1, 0x2802, 0xFFFF
};

static const testv_nr = sizeof(testv)/sizeof(testv[0])/3;

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
        

int main(int argc, char *argv[])
{
  FILE *fp;
  char *outfilename;
  char *infilename1;
  char *infilename2;

  int i,c;
  short val;  
  short runcycles;
  unsigned short level;

  int verification_ok = 1;
  
#if DEBUG_DUMPRES
  /* open output file */
  fp = fopen(outfilename,"w");
#endif DEBUG_DUMPRES


  /*******************************************************************/
  /* reset ZIPPY array                                               */
  /*******************************************************************/

#if DEBUG  
  printf("resetting zippy array\n\n");
#endif  
  zippy_set_reg(ZREG_RST,0);

  /*******************************************************************/
  /* download contexts (first # zippycontexts)                       */
  /*******************************************************************/


  for(i=0; i<NCFGPARTS; i++){
#if DEBUG_CFG_DOWNLOAD
    printf("  downloading context %d - slice %d - `%#.*X'\n",
           0, i, PARTWIDTH/4, config[i]);
#endif
    zippy_set_reg(contextreg[c], config[i]);
  }

#if DEBUG
   printf("\n");
#endif


/******* fill FIFOs with input data *************/

for(i=0;i<testv_nr;i++)
{
  zippy_set_reg(ZREG_FIFO0,testv[3*i]);
  zippy_set_reg(ZREG_FIFO1,testv[3*i+1]);
}
      
#if DEBUG  
    printf("\n");
    printf("FIFO_0 fill level = %d\n", zippy_get_reg(ZREG_FIFO0LEV));
    printf("FIFO_1 fill level = %d\n", zippy_get_reg(ZREG_FIFO1LEV));
    printf("\n");
#endif




/*** execute contexts ********************************************/

c=0;
runcycles = testv_nr + 2;

#if DEBUG
    printf("activating context %d (state cleared)\n", c);
#endif
    zippy_set_reg(ZREG_CONTEXTSELCLR, c); /* clear context state */


#if DEBUG
    printf("starting the array for %d cycles\n", runcycles);
#endif
    zippy_set_reg(ZREG_CYCLECNT,runcycles);
      
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

 
    /*** read from FIFO_0 ********************************************/
    
    level = zippy_get_reg(ZREG_FIFO0LEV);
    
#if DEBUG
    printf("there are %d data values in FIFO_0\n", level);
    printf("reading data from FIFO_0\n");
#endif


    for(i=0; i<level; i++){
      val = zippy_get_reg(ZREG_FIFO0);

#if VERIFICATION
      printf(" %d/%d: reponse: 0x%04X (expected: 0x%04X) ",
             i,level,val,testv[3*i+2]);
      if (val == testv[3*i+2]) {
        printf("OK\n");        
      } else {
        printf("FAILED\n");
        verification_ok = 0;
      }
#endif      

    }


#if VERIFICATION
    if (verification_ok){
      printf("verfication succeeded, all test vectors correct\n");
    } else {
      printf("verfication failed!!\n");
    }
#endif    

    
    
#if DEBUG
    printf("\n");
    printf("FIFO_0 fill level = %d\n", zippy_get_reg(ZREG_FIFO0LEV));
    printf("FIFO_1 fill level = %d\n", zippy_get_reg(ZREG_FIFO1LEV));
#endif
    
#if DEBUG_DUMPRES
    /* dump results to output file */
#if DEBUG
    printf("\ndumping results to output file (be aware that delay may\n");
    printf("later be introduced during simulation)\n\n");
#endif
    fprintf(fp,"block: %d\n",b);
    if (overlapping && (b!=0)) { /* 1st block is never overlapped */
      for(i=0; i<nsamples-firlen; i++){
        fprintf(fp,"%i\n",out[i]);
      }
    } else {
      for(i=0; i<nsamples; i++){
        fprintf(fp,"%i\n",out[i]);
      }
    }
    fprintf(fp,"\n");
    fflush(fp);
#endif
    
  asm("nop;nop;"); /** FIXME: sim. may behave nasty without **/

/*  fclose(fp); */

  /*******************************************************************/
  /* terminate simulation                                            */
  /*******************************************************************/
  zippy_stop_sim();
}
