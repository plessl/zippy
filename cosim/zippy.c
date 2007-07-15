/*
 * $Id: zippy.c,v 1.1.1.1 2003/10/16 09:01:16 enzler Exp $
 * $Log: zippy.c,v $
 * Revision 1.1.1.1  2003/10/16 09:01:16  enzler
 * ZIPPY-6 array; initial import
 *
 * Revision 1.6  2003/04/03 15:11:31  enzler
 * added FAKESIM define: allows simulation wo/ that the simulator is actually
 * called
 *
 * Revision 1.5  2003/01/31 09:09:50  plessl
 * Bugfix in cosimulation.
 *
 * Revision 1.4  2003/01/30 16:23:54  plessl
 * Fix some compiler warnings
 *
 * Revision 1.3  2003/01/30 14:58:22  plessl
 * Improvement for faster simulation. Do not send a ZIPPY_NOP to the
 * simulator fo r the array in every cycle. Now the array simulation is
 * allowed to backlog. The NOPs are accumulated and as soon as a non-NOP
 * command is sent to the array the accumulated NOPs are executed to
 * resynchronize CPU and array simulator.
 *
 *
 */


#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <semaphore.h>
#include <sys/mman.h>
#include <fcntl.h>
#include "comm.h"
#include <unistd.h>

#define FAKESIM 0

int shm_fd;
struct message_t *shm_msgp;
sem_t *sem_client_done;
sem_t *sem_server_done;
mode_t perm;

typedef enum {
    E_OK = 0,
    E_OPEN_SHM,    // cannot open shared memory region
    E_MMAP_SHM,    // cannot mmap shared memory region
    E_OPEN_SEM_CL, // cannot open semaphore client done
    E_OPEN_SEM_SV  // cannot open semaphore server done
} zippy_init_err_t;


typedef enum {
  S_INIT,
  S_STARTED,
  S_SUSPENDED,
  S_RESUMED,
  S_STOPPED
} zippy_sim_status_t;




zippy_init_err_t zippy_init(void);
int zippy_get_reg(unsigned int zreg);
int zippy_set_reg(int zreg,unsigned int value);
void zippy_nop(void);
void zippy_start_sim(void);
void zippy_stop_sim(void);
void simulation_catchup(void);

// to supress compilation warning on SunOS
int shm_open(const char *name, int oflag, mode_t mode);


// The following global variable controls whether the cosimulation is
// enabled. The variable shall only be modified by zippy_start_sim,
// zippy_stop_sim, zippy_resume_sim and zippy_suspend_sim.
static zippy_sim_status_t zippy_sim_status = S_INIT;

zippy_init_err_t zippy_init(void)
{
#if FAKESIM == 0
    perm = S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH;
  
    if (-1 == (shm_fd = shm_open("/zippy_shm", O_RDWR,perm))){
        perror("client: cannot open shared memory region");
        return E_OPEN_SHM;
    }

    if (MAP_FAILED == 
        (shm_msgp = (struct message_t*)mmap(NULL,sizeof(struct message_t),PROT_READ|PROT_WRITE,MAP_SHARED,shm_fd,0))){
        perror("client: cannot mmap shared memory");
        return E_MMAP_SHM;
    }

    ftruncate(shm_fd,sizeof(struct message_t));
    close(shm_fd);

    if (SEM_FAILED == (sem_client_done = 
                       sem_open("/client_done", O_CREAT,perm,0))){
        perror("client: cannot open semaphore /client_done");
        return E_OPEN_SEM_CL;
    }

    if (SEM_FAILED == (sem_server_done = 
                       sem_open("/server_done", O_CREAT,perm,0))){
        perror("client: cannot open semaphore /server_done");
        return E_OPEN_SEM_SV;
    }

    zippy_sim_status = S_INIT;   // initialize simulation status
    
    return E_OK;
#else
    return E_OK;
#endif    

}



int zippy_get_reg(unsigned int zreg)
{
#if FAKESIM == 0

  int res;

  simulation_catchup();
  
  if (zippy_sim_status != S_STOPPED){
    shm_msgp->req.cmd=ZIPPY_GET_REG;
    shm_msgp->req.zreg = zreg;
    shm_msgp->req.value = 0;
    sem_post(sem_client_done);
    while(0 != (res = sem_wait(sem_server_done))){
      ;
    }
    return shm_msgp->resp.sig_DataxDO;
  } else {
    printf("fatal error in %s, line %d: simulation was stopped",__FILE__,__LINE__);    
    return 0;
  }
#else
  return 0;
#endif  
}


int zippy_set_reg(int zreg,unsigned int value)
{
#if FAKESIM == 0

  int res;

  simulation_catchup();

  if (zippy_sim_status != S_STOPPED){
    shm_msgp->req.cmd=ZIPPY_SET_REG;
    shm_msgp->req.zreg = zreg;
    shm_msgp->req.value = value;
    sem_post(sem_client_done);
    while(0 != (res = sem_wait(sem_server_done))){
      ;
    }
    return shm_msgp->resp.sig_DataxDO;
  }  else {
    printf("fatal error in %s, line %d: simulation was stopped",__FILE__,__LINE__);
    return 0;
  }  
#else
  return 0;
#endif
  
}


// allow the simulation of the array to have a certain backlog. The
// amount of the backlog is increase with every zippy_nop
// instruction. The simulation-time of CPU and array simulation is
// synchronized at any non zippy_nop operation.

static unsigned int simulation_backlog = 0;


void simulation_catchup(void)
{
#if FAKESIM == 0

  int res;
  
  if (simulation_backlog > 0){
    shm_msgp->req.cmd=ZIPPY_NOP;
    shm_msgp->req.zreg = 0;
    shm_msgp->req.value = simulation_backlog;
    sem_post(sem_client_done);
    while(0 != (res = sem_wait(sem_server_done))){
      ;
    }
    
  
    simulation_backlog = 0;
  }
#endif
  return;
}


// FIXME: Check for overflows and issue simulation_catchup before overflow
void zippy_nop(void)
{
#if FAKESIM == 0
  simulation_backlog++;
#endif  
}


void zippy_start_sim(void)
{
#if FAKESIM == 0
  int res;

  simulation_catchup();
  
  shm_msgp->req.cmd=ZIPPY_START_SIM;
  shm_msgp->req.zreg = 0;
  shm_msgp->req.value = 0;
  sem_post(sem_client_done);
  while(0 != (res = sem_wait(sem_server_done))){
    ;
  }

  zippy_sim_status = S_STARTED;
  return;
#else
  return;
#endif
  
}

void zippy_stop_sim(void)
{
#if FAKESIM == 0
  int res;
    
    simulation_catchup();

    shm_msgp->req.cmd=ZIPPY_STOP_SIM;
    shm_msgp->req.zreg = 0;
    shm_msgp->req.value = 0;
    sem_post(sem_client_done);
    //while(0 != (res = sem_wait(sem_server_done))){
    //    ;
    //}
    zippy_sim_status = S_STOPPED;
    return;
#else
    return;
#endif
    
}


