#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <semaphore.h>
#include <sys/mman.h>
#include <sys/stat.h>

#include "mti.h"
#include "comm.h"

#define SEMAPHORE_DEBUG 0

typedef enum {
    WAIT_REQUEST,
    SEND_RESPONSE
} driver_state_t;



/* The naming of the signals corresponds to the naming of the ports of
   the zippy array. E.g. WExEI is an _input_ of the zippy array, but
   in the driver (implemented in this file) it is an _output_ */

typedef struct {

    mtiProcessIdT proc;

    // handles to the ports of the zippy array driver
    mtiSignalIdT sig_WExEI;
    mtiSignalIdT sig_RExEI;
    mtiSignalIdT sig_DataxDI;
    mtiSignalIdT sig_DataxDO;
    mtiSignalIdT sig_AddrxDI;
    
    // handles to drivers
    mtiDriverIdT drv_sig_WExEI;
    mtiDriverIdT drv_sig_RExEI;
    mtiDriverIdT drv_sig_DataxDI;
    mtiDriverIdT drv_sig_AddrxDI;
    
    sem_t *sem_client_done;
    sem_t *sem_server_done; 
  
    struct message_t *shm_msgp;
  

} inst_rec;


static char msgbuf[256];
static char command[80];

static const mtiDelayT c_cycleTime = 100;


/*  VHDL declaration of the driver entity is:

entity driver is
  port(
    WExEI   : out bit;
    RExEI   : out bit;
    DataxDI : out integer;
    DataxDO : in  integer;
    AddrxDI : out integer
    );
end driver;


*/

// declaration of functions
static void eval_message(void *param);
static void print_semvalue(inst_rec *ip);

void server_init(
		 mtiRegionIdT       region,
		 char              *param,
		 mtiInterfaceListT *generics,
		 mtiInterfaceListT *ports
		 )
{

    inst_rec     *ip;

    mtiSignalIdT  outsig;
    mode_t perm;
    int flags;
    int shm_fd;

        
    ip = (inst_rec *)mti_Malloc(sizeof(inst_rec));
    mti_AddRestartCB(mti_Free, ip);
    perm = S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH;

    // create handles to signals (ports of entity)
    ip->sig_WExEI = mti_FindPort(ports,"WExEI");
    ip->sig_RExEI = mti_FindPort(ports,"RExEI");
    ip->sig_DataxDI = mti_FindPort(ports,"DataxDI");
    ip->sig_DataxDO = mti_FindPort(ports,"DataxDO");
    ip->sig_AddrxDI = mti_FindPort(ports,"AddrxDI");
    
    // create drivers to input signals
    ip->drv_sig_WExEI =mti_CreateDriver(ip->sig_WExEI);
    ip->drv_sig_RExEI = mti_CreateDriver(ip->sig_RExEI);
    ip->drv_sig_DataxDI = mti_CreateDriver(ip->sig_DataxDI);
    ip->drv_sig_AddrxDI = mti_CreateDriver(ip->sig_AddrxDI);    

    
    // setup shared memory and semaphores
    if(0 != shm_unlink("/zippy_shm")){
        mti_PrintMessage("cannot unlink zippy_shm");
    }

    if(0 != sem_unlink("/client_done")){
        mti_PrintMessage("cannot unlink client_done");
    }

    if(0 != sem_unlink("/server_done")){
        mti_PrintMessage("cannot unlink server_done");
    }

    if (-1 == (shm_fd = shm_open("/zippy_shm", O_RDWR|O_CREAT,perm))){
        mti_PrintMessage("cannot open shared memory region");
        exit(-1);
    }

    if (MAP_FAILED == (ip->shm_msgp = (struct message_t *)
                       mmap(NULL,sizeof(struct message_t),PROT_READ|PROT_WRITE,
                            MAP_SHARED,shm_fd,0))){
        mti_PrintMessage("cannot mmap shared memory");
        exit(-1);
    }

    ftruncate(shm_fd,0);
    close(shm_fd);

    if (SEM_FAILED == (ip->sem_client_done = sem_open("/client_done", O_CREAT,perm,0))){
        mti_PrintMessage("cannot open semaphore /client_done");
        exit(-1);
    }
  
    if (SEM_FAILED == (ip->sem_server_done = sem_open("/server_done", O_CREAT,perm,0))){
        mti_PrintMessage("cannot open semaphore /server_done");
        exit(-1);
    }


    sprintf(msgbuf,"communication channels opened");
    mti_PrintMessage(msgbuf);

    // create driver process
    ip->proc = mti_CreateProcess("p_driver", eval_message, ip);

    print_semvalue(ip);
    sprintf(msgbuf,"driver process created");
    mti_PrintMessage(msgbuf);

}


static void eval_message(
			 void *param
			 )
{
 
    inst_rec *ip = (inst_rec *)param;
    int res;
    static int firsttime = 1;
    static driver_state_t driverState = WAIT_REQUEST;
    static cmd_t requestCmd = ZIPPY_NOP;
    unsigned int requestZreg;
    int requestValue;
        
    int len;
    mtiDelayT nextWakeup;
    
    
#ifdef DEBUG_SERVER
    sprintf(msgbuf,"handler called!");
    mti_PrintMessage(msgbuf);
#endif

    // eval_message is called once at initialization. ignore this call
    // and return immediately
    
    if(firsttime){
#ifdef DEBUG_SERVER
      sprintf(msgbuf,"handler called for first time!\n");
#endif      
        //print_semvalue(ip);
      
        mti_PrintMessage(msgbuf);

        // FIXME here we can introduce the initial delay, where the
        // simulation shall start.
        mti_ScheduleWakeup( ip->proc, 0);
        firsttime = 0;
        return;
    }

#if DEBUG_SERVER    
    print_semvalue(ip);
#endif    
    
    nextWakeup = c_cycleTime;  // default value for next wakeup
    

    switch (driverState){
        
    

    case WAIT_REQUEST:

        /***************************************************************
         sem_wait(client_done)
        ****************************************************************/

#ifdef DEBUG_SERVER      
        sprintf(msgbuf,"waiting for request");
        mti_PrintMessage(msgbuf);
#endif        
        
        // sem wait can be interrupted by a signal resulting in returning
        // without having aqcuired the semaphore, error EINTR
        // wait until the semaphore was acquired 
        while(0 != (res = sem_wait(ip->sem_client_done))){
            ;
        }

#ifdef DEBUG_SERVER
        sprintf(msgbuf,"request received!");
        mti_PrintMessage(msgbuf);
#endif        

        /****************************************************************
         read_request()
        ****************************************************************/
        requestCmd   = ip->shm_msgp->req.cmd;
        requestZreg  = ip->shm_msgp->req.zreg;
        requestValue = ip->shm_msgp->req.value;
        
        
        /***************************************************************
         drive_signals()
        *****************************************************************/
        
        switch (requestCmd){

        case ZIPPY_GET_REG:
            mti_ScheduleDriver(ip->drv_sig_WExEI,0,0,MTI_INERTIAL);
            mti_ScheduleDriver(ip->drv_sig_RExEI,1,0,MTI_INERTIAL);
            mti_ScheduleDriver(ip->drv_sig_AddrxDI,requestZreg,0,MTI_INERTIAL);
            mti_ScheduleDriver(ip->drv_sig_DataxDI,requestValue,0,MTI_INERTIAL);
            break;

        case ZIPPY_SET_REG:
            mti_ScheduleDriver(ip->drv_sig_WExEI,1,0,MTI_INERTIAL);
            mti_ScheduleDriver(ip->drv_sig_RExEI,0,0,MTI_INERTIAL);
            mti_ScheduleDriver(ip->drv_sig_AddrxDI,requestZreg,0,MTI_INERTIAL);
            mti_ScheduleDriver(ip->drv_sig_DataxDI,requestValue,0,MTI_INERTIAL);
            break;
            
        case ZIPPY_NOP:
            mti_ScheduleDriver(ip->drv_sig_WExEI,0,0,MTI_INERTIAL);
            mti_ScheduleDriver(ip->drv_sig_RExEI,0,0,MTI_INERTIAL);
            mti_ScheduleDriver(ip->drv_sig_AddrxDI,requestZreg,0,MTI_INERTIAL);
            mti_ScheduleDriver(ip->drv_sig_DataxDI,requestValue,0,MTI_INERTIAL);

            if(requestValue != 0) {
              nextWakeup = requestValue * c_cycleTime;
              // mti_PrintFormatted("issuing %d zippy_nops",requestValue);
            } else {
              // mti_PrintFormatted("issuing 1 zippy_nop");
              nextWakeup = c_cycleTime;
            }
            
            
            break;

        case ZIPPY_STOP_SIM:
          mti_PrintFormatted("Simulation stop requested by application "
                             "at time %d ", mti_Now());

          // FIXME / IDEA
          // A zippy quit sim command could be introduced. Just all mti_Quit
          // and the simulator will exit. This is good for non interactive
          // simulations.
          //mti_Quit();
          
          break;

          
        default:
            sprintf(msgbuf, "Invalid command\n");
            mti_PrintFormatted("command %d ",requestCmd);
            mti_PrintMessage(msgbuf);
            break;
        }

        driverState = SEND_RESPONSE;
        
        /****************************************************************
          schedule_wakeup(T)
        *****************************************************************/
        mti_ScheduleWakeup(ip->proc,nextWakeup);

        break;

    case SEND_RESPONSE:

        /************************************************************
          read_signals()
          send_response()
        *************************************************************/
#ifdef DEBUG_SERVER
      sprintf(msgbuf,"sending answer to client\n");
        mti_PrintMessage(msgbuf);
#endif        
        // reset driving signals
        mti_ScheduleDriver(ip->drv_sig_WExEI,0,0,MTI_INERTIAL);
        mti_ScheduleDriver(ip->drv_sig_RExEI,0,0,MTI_INERTIAL);
        mti_ScheduleDriver(ip->drv_sig_AddrxDI,0,0,MTI_INERTIAL);
        mti_ScheduleDriver(ip->drv_sig_DataxDI,0,0,MTI_INERTIAL);

        ip->shm_msgp->resp.sig_DataxDO=mti_GetSignalValue(ip->sig_DataxDO);


        /************************************************************
           signal(server_done)
        ***********************************************************/
        sem_post(ip->sem_server_done);


        if (requestCmd == ZIPPY_STOP_SIM){
          mti_Break();
          return;
        }
        
        driverState = WAIT_REQUEST;

        /*************************************************************
           schedule_wakeup(0)
        ***********************************************************/
    
#ifdef DEBUG_SERVER
        sprintf(msgbuf,"end of handler!");
        mti_PrintMessage(msgbuf);
#endif
        
        mti_ScheduleWakeup(ip->proc,0);
        break;
        
    } 

}

static void print_semvalue(inst_rec *ip){

    if (SEMAPHORE_DEBUG){
        int val_sem_client_done;
        int val_sem_server_done;

        char buf1[80], buf2[80];

        sem_getvalue(ip->sem_client_done,&val_sem_client_done);
        sem_getvalue(ip->sem_server_done,&val_sem_server_done);

        snprintf(buf1,sizeof(buf1),"value of sem client_done %d",val_sem_client_done);
        snprintf(buf2,sizeof(buf2),"value of sem server_done %d",val_sem_server_done);

        mti_PrintMessage(buf1);
        mti_PrintMessage(buf2);
    }
}

