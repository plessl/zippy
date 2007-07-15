#include "adpcm.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void usage(char *);


int main(int argc, char* argv[])
{

  char *sInputFileName;
  char *sOutputFileName;
  FILE *fpInputFile, *fpOutputFile;
  struct adpcm_state state;
  int iInputLen, iOutputLen;
  int iOutputSamples;
  
  char *cInputBuffer;
  char *cOutputBuffer;
  int iBytesRead, iBytesWritten;
  
  if (argc < 3){
    usage(argv[0]);
    exit(-1);
  }

  sInputFileName = argv[1];
  sOutputFileName = argv[2];
  
  
  printf("Converting ADPCM file %s to PCM file %s\n",
         sInputFileName, sOutputFileName);

  fpInputFile = fopen(sInputFileName, "r");
  if (!fpInputFile){
    perror("input file");
    exit(-2);
  }
  
  fpOutputFile = fopen(sOutputFileName, "w");
  if (!fpOutputFile) {
    perror("output file");
    exit(-3);
  }

  fseek(fpInputFile,0,SEEK_END);
  iInputLen = ftell(fpInputFile);
  printf("Input file has %d bytes\n",iInputLen);
  fseek(fpInputFile,0,SEEK_SET);

  /* each input sample (nibble) will be decoded to two output words (short) */
  iOutputSamples = iInputLen*2;   /* in samples (16bit words) */
  iOutputLen = iInputLen*4;       /* in bytes */
  
  printf("File will be decoded to %d output samples\n",iOutputSamples);
           
  cInputBuffer = (char *)malloc(iInputLen);
  if (!cInputBuffer){
    perror("input buffer:");
    exit(-3);
  }
  
  cOutputBuffer = (char *)malloc(iOutputLen);
  if (!cOutputBuffer){
    perror("output buffer:");
    exit(-4);
  }

  iBytesRead = 0;
  while (iBytesRead < iInputLen) {
    iBytesRead += fread(cInputBuffer+iBytesRead, sizeof(char),
                        iInputLen-iBytesRead,fpInputFile);
  }
  
  adpcm_decoder(cInputBuffer, (short *)cOutputBuffer, iOutputSamples, &state);

  iBytesWritten = 0;
  while (iBytesWritten < iOutputLen) {
    iBytesWritten += fwrite(cOutputBuffer+iBytesWritten, sizeof(char),
                            iOutputLen-iBytesWritten,fpOutputFile);
  }
      
  fclose(fpInputFile);
  fclose(fpOutputFile);

  return 0;
  
}

void usage(char* sProgramName)
{
  printf("usage: %s adpcmfile pcmfile\n",sProgramName);
}
