#define DEBUG 0

#define DEBUG_FIFO_WRITE 0
#define DEBUG_FIFO_READ 0

#define DEBUG_CFG_DOWNLOAD 0

#define DEBUG_DUMPRES 1


#include <stdio.h>
#include <math.h>

#include "schedule.h"
#include "tstfir8_virt_cfg.h"
#include "input.h"

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

  int out[INLEN];
  unsigned level;

  int i,val;
  int res;
  int c, b, s;
  int lbound, ubound;
  int blocklen, nblocks;
  int nsamples;
  int outindex;
  int lastzippycontext;
  unsigned int schedword;

  /* command-line arguments */
  int appcontexts;    /* no. application contexts */
  int zippycontexts;  /* no. hardware contexts */
  int zippyfifodepth; /* depth of ZIPPY FIFOs */
  int firlen;         /* FIR length */
  short padding;      /* false/true */
  short statestore;   /* false/true */
  
  /* execution flow tags */
  short virtualizing   = 0; /* false/true */
  short overlapping    = 0; /* false/true */
  short contextstoring = 0; /* false/true */

  /* read in command-line arguments */
  if ((argc<7) || (argc>8)) {
    printf("Usage: fir_zippy ZC ZF AC FL PT ST [OF]\n");
    printf("  ZC: no. of ZIPPY hardware contexts (int)\n");
    printf("  ZF: ZIPPY FIFO depth (int)\n");
    printf("  AC: no. of application (FIR) contexts (int)\n");
    printf("  FL: FIR filter length (int)\n");
    printf("  PT: padding tag (yes/no: 1/0)\n");
    printf("  ST: statestore tag (yes/no: 1/0)\n");
    printf("  OF: name of output file (string) [optional]\n");
    exit(1);
  } else {
    zippycontexts  = atoi(argv[1]);
    zippyfifodepth = atoi(argv[2]);
    appcontexts    = atoi(argv[3]);
    firlen         = atoi(argv[4]);
    padding        = atoi(argv[5]);
    statestore     = atoi(argv[6]);
    if (argc == 8) {
      outfilename = argv[7];
    } else {
      outfilename = "fir_zippy.out";
    }
  }
  
  /* determine if virtualization is required */
  if (appcontexts > zippycontexts) {
    virtualizing = 1;
    lastzippycontext = zippycontexts-1;
  }
  /* determine if blocks have to be overlapped */
  if (padding && (!statestore || virtualizing)) {
    overlapping = 1;
  }
  /* determine if context state can/should be stored */
  if (padding && statestore && !virtualizing) {
    contextstoring = 1;
  }

#if DEBUG
  printf("\nexe mode: virtualizing=%d, overlapping=%d, contextstoring=%d\n\n",
         virtualizing, overlapping, contextstoring);
#endif

#if DEBUG_DUMPRES
  /* open output file */
  fp = fopen(outfilename,"w");
#endif DEBUG_DUMPRES


  /*******************************************************************/
  /* compute block length and no. of blocks                          */
  /*******************************************************************/
  if (overlapping) {
    blocklen = zippyfifodepth - firlen;
  } else {
    blocklen = zippyfifodepth;
  }
  nblocks = (int) ceil((double)INLEN/blocklen); /* beware of int div. */
  
#if DEBUG
  printf("\nblock processing: inlen=%d, blocklen=%d, nblocks=%d\n\n",
         INLEN, blocklen, nblocks);
#endif

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
#if DEBUG
    printf("\n");
#endif

  /*******************************************************************/
  /* download schedule program                                       */
  /*******************************************************************/
  /* note: schedword assembling (eg. shift) depends on SIW format    */
  for(s=0; s<zippycontexts-1; s++){
    schedword = schedprog[s] + (zippyfifodepth<<8);
#if DEBUG
    printf("loading word 0X%08x into schedule store (addr %d)\n",
           schedword, s);
#endif
    zippy_set_reg(schedulestore[s],schedword);
  }
  /* last context; set `last' flag in SIW */
  schedword = (schedprog[s] + (zippyfifodepth<<8)) | 1;
#if DEBUG
    printf("loading word 0X%08x into schedule store (addr %d)\n",
           schedword, s);
#endif
    zippy_set_reg(schedulestore[s],schedword);
    
  /*******************************************************************/
  /* process data blocks                                             */
  /*******************************************************************/
  for(b=0; b<nblocks; b++){
#if DEBUG
    printf("\n### BLOCK: %d ################################\n\n", b);
#endif
  
    /*** write to FIFO_0 *********************************************/

#if DEBUG
    printf("writing data into FIFO_0\n");
#endif
    
    lbound = b*blocklen;
    ubound = lbound+blocklen;
    /* overlap block if required (1st block is never overlapped) */
    if (overlapping && (b!=0)) {
      lbound -= firlen;
    }
    /* clipping for last (ev. partial) block */
    if (ubound >= INLEN) {
      ubound = INLEN;
    }
    nsamples = ubound - lbound;
    for(i=lbound; i<ubound; i++){
      /* asm("nop;"); */ /** FIXME: sim. may behave nasty without **/
      zippy_set_reg(ZREG_FIFO0,in[i]);
#if DEBUG_FIFO_WRITE
      printf("  %d: write `%d' (fill level after push = %d)\n", i, in[i],
             zippy_get_reg(ZREG_FIFO0LEV));
#endif    
    }
      
#if DEBUG  
    printf("\n");
    printf("FIFO_0 fill level = %d\n", zippy_get_reg(ZREG_FIFO0LEV));
    printf("FIFO_1 fill level = %d\n", zippy_get_reg(ZREG_FIFO1LEV));
    printf("\n");
#endif

    /*** execute contexts ********************************************/

    /*** (1) the present contexts ***/

    if  (nsamples == zippyfifodepth){           /*** use scheduler ***/

      if (contextstoring) {
#if DEBUG    
        printf("starting context scheduler (%d contexts, state stored)\n",
               zippycontexts);
#endif
        zippy_set_reg(ZREG_SCHEDSTART, 0);
      } else {
#if DEBUG    
        printf("starting context scheduler (%d contexts, state cleared)\n",
               zippycontexts);
#endif
        zippy_set_reg(ZREG_SCHEDSTART, 1);
      }
      /* poll schedule status register */
      while ((i = zippy_get_reg(ZREG_SCHEDSTATUS)) > 0){
#if DEBUG    
        printf("polling schedule status: %d\n", i);
#endif
        ;  /* wait */
      }

    } else {                             /**** don't use scheduler ***/

      for(c=0; c<zippycontexts; c++){
      
        if (contextstoring) {
#if DEBUG
          printf("activating context %d (state stored)\n", c);
#endif
          zippy_set_reg(ZREG_CONTEXTSEL, c);    /* store context state */
        }
        else {
#if DEBUG
          printf("activating context %d (state cleared)\n", c);
#endif
          zippy_set_reg(ZREG_CONTEXTSELCLR, c); /* clear context state */
        }          
#if DEBUG
        printf("starting the array for %d cycles\n", nsamples);
#endif
        zippy_set_reg(ZREG_CYCLECNT,nsamples);
      
        while ((i = zippy_get_reg(ZREG_CYCLECNT)) > 0){
#if DEBUG    
          printf("polling cycle count register: %d\n",i);
#endif
          ;  /* wait */
        }
      }
    }
      
#if DEBUG  
    printf("\n");
    printf("FIFO_0 fill level = %d\n", zippy_get_reg(ZREG_FIFO0LEV));
    printf("FIFO_1 fill level = %d\n", zippy_get_reg(ZREG_FIFO1LEV));
    printf("\n");
#endif

 
    /*** (2) virtualize if required ***/
    if (virtualizing) {
      for(c=zippycontexts; c<appcontexts; c++){
#if DEBUG
    printf("loading app. context %d into context memory %d\n",
           c, lastzippycontext);
#endif

        /* configure current app context to highest ZIPPY context */
        for(i=0; i<NCFGPARTS; i++){
#if DEBUG_CFG_DOWNLOAD
          printf("  downloading context %d - slice %d - `%#.*X'\n",
                 c, i, PARTWIDTH/4, contextdata[c][i]);
#endif    
          zippy_set_reg(contextreg[lastzippycontext], contextdata[c][i]);
        }

        /* set context select register (with clear) */
#if DEBUG
        printf("activating context %d (state cleared)\n",
               lastzippycontext);
#endif
        zippy_set_reg(ZREG_CONTEXTSELCLR, lastzippycontext); /* clear context state */

        /* execute */
#if DEBUG
        printf("starting the array for %d cycles\n", nsamples);
#endif
        zippy_set_reg(ZREG_CYCLECNT,nsamples);

        /* poll */
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
        
      }

      /* configure the highest ZIPPY context again with the first */
      /* used app context */
      if (b < nblocks-1) {
        c = lastzippycontext;
#if DEBUG
        printf("loading app. context %d into context memory %d\n\n",
               c, c);
#endif
        for(i=0; i<NCFGPARTS; i++){
#if DEBUG_CFG_DOWNLOAD
          printf("  writing context %d - slice %d - `%#.*X'\n",
                 c, i, PARTWIDTH/4, contextdata[c][i]);
#endif
          zippy_set_reg(contextreg[c], contextdata[c][i]);
        }
      }
      
    } /* END virtualize */
    
    
    /*** read from FIFO_0 ********************************************/
    
    level = zippy_get_reg(ZREG_FIFO0LEV);
    
#if DEBUG
    printf("there are %d data values in FIFO_0\n", level);
    printf("reading data from FIFO_0\n");
#endif

    outindex = 0;
    for(i=0; i<level; i++){
#if DEBUG_FIFO_READ
      res = zippy_get_reg(ZREG_FIFO0LEV);
#endif
      
      val = zippy_get_reg(ZREG_FIFO0);
      if (overlapping && (b!=0)) { /* 1st block is never overlapped */
        if (i >= firlen) { /* ignore the crap data */
          out[outindex] = val;
          outindex++;
        }
      } else {
        out[i] = val;
      }
      
#if DEBUG_FIFO_READ
      printf("  %d: read `%d' (fill level before pop = %d)\n",i,val,res);
#endif
    }

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
    
  } /* END for(b=0; b<nblocks; b++) */
  asm("nop;nop;"); /** FIXME: sim. may behave nasty without **/

  fclose(fp);

  /*******************************************************************/
  /* terminate simulation                                            */
  /*******************************************************************/
  zippy_stop_sim();
}
