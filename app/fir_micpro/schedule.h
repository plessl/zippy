/* schedule instruction word (SIW) format: */
/* 00000000000000000000000000000000b       */
/* .|-||------------------||-----||        */
/*  Con       Cycles        Next  L        */
/*  text                    Adr   a        */
/*  ID                            s        */
/*                                t        */

/* the number of execution cycles is not specified yet; */
/* the program can include the cycles (with an addition) */

/* the `last' flag is not specified either */
/* the program can add the flag too        */

#ifndef SCHEDULE_H
#define SCHEDULE_H

static const unsigned int schedprog[8] = {
              /* .|-||------------------||-----||  */
  0X00000002, /* 00000000000000000000000000000010b */
  0X10000004, /* 00010000000000000000000000000100b */
  0X20000006, /* 00100000000000000000000000000110b */
  0X30000008, /* 00110000000000000000000000001000b */
  0X4000000A, /* 01000000000000000000000000001010b */ 
  0X5000000C, /* 01010000000000000000000000001100b */ 
  0X6000000E, /* 01100000000000000000000000001110b */ 
  0X70000000  /* 01110000000000000000000000000000b */ 
};

#endif /* SCHEDULE_H */
