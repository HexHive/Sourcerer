#define HEX_LOG
#define PRINT_BAD_CASTING_STATS
//#define PRINT_BAD_CASTING_STDOUT
//#define PRINT_BAD_CASTING_FILE
//#define PRINT_BAD_CASTING_STDERR
//#define PRINT_BAD_CASTING_FATAL
//#define DO_REPORT_BADCAST_FATAL_NOCOREDUMP
//#define PRINT_MISSED_CAST // in case of partial class coverage, might need to be
                          // be disabled to not gobble all disk
#define LOG_INSERTOR_CALL


#ifdef DO_REPORT_BADCAST_FATAL_NOCOREDUMP
#define TERMINATE exit(-1);
#else
#define TERMINATE abort();
#endif

#define MAXINDEX 8
#define MAXLEN 1000

#define numCastUnrl 0
#define numCastDrvd 1
#define numCastUnrlMiss 2
#define numCastDrvdMiss 3
#define numCastUnrlBad 4
#define numCastDrvdBad 5
#define numVTAdded 6
#define numVICallAdded 7
