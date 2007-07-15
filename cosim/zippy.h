#ifndef ZIPPY_H

#define ZIPPY_H

typedef enum {
    E_OK = 0,
    E_OPEN_SHM,    // cannot open shared memory region
    E_MMAP_SHM,    // cannot mmap shared memory region
    E_OPEN_SEM_CL, // cannot open semaphore client done
    E_OPEN_SEM_SV  // cannot open semaphore server done
} zippy_init_err_t;

zippy_init_err_t zippy_init(void);

// FIXME: insert macro definitions here, instead of function
// declarations

int zippy_get_reg(unsigned int zreg);
int zippy_set_reg(int zreg,unsigned int value);
void zippy_nop(void);
void zippy_start_sim(void);
void zippy_stop_sim(void);

#else

#endif
