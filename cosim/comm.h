typedef enum {
        ZIPPY_NOP,
        ZIPPY_GET_REG,
        ZIPPY_SET_REG,
        ZIPPY_START_SIM,
        ZIPPY_STOP_SIM,
        ZIPPY_SUSPEND_SIM,
        ZIPPY_RESUME_SIM
} cmd_t;


typedef enum {
  STD_LOGIC_U,
  STD_LOGIC_X,
  STD_LOGIC_0,
  STD_LOGIC_1,
  STD_LOGIC_Z,
  STD_LOGIC_W,  
  STD_LOGIC_L,  
  STD_LOGIC_H,  
  STD_LOGIC_D  
} standardLogicType;


struct request_t {
    cmd_t cmd;
    unsigned int zreg;
    int value;
};

struct response_t {
    int  sig_DataxDO;
};

struct message_t {
  struct request_t req;
  struct response_t resp;
};
