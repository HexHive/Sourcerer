//===-- hextype.cc -- runtime support for HexType  ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===-------------------------------------------------------------------===//

#include <assert.h>
#include <execinfo.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

#include "sanitizer_common/sanitizer_atomic.h"
#include "sanitizer_common/sanitizer_common.h"
#include "sanitizer_common/sanitizer_hash.h"
#include "sanitizer_common/sanitizer_stacktrace.h"
#include "typeplus.h"
#include "ubsan/ubsan_handlers.h"
#include "ubsan/ubsan_platform.h"
#include "ubsan/ubsan_type_hash.h"

// #define DO_REPORT_BADCAST_FATAL_NOCOREDUMP

#ifdef DO_REPORT_BADCAST_FATAL_NOCOREDUMP
#define TERMINATE exit(-1);
#else
#define TERMINATE abort();
#endif

using namespace __ubsan;
using namespace __asan;

#define BT_BUF_SIZE 100
#define MAXPATH 1000

#ifdef HEX_LOG

atomic_uint64_t count_index[MAXINDEX];
bool isInit = false;

void IncVal(int index, int count) {
  unsigned long val = atomic_load_relaxed(&count_index[index]);
  atomic_store_relaxed(&count_index[index], val + count);
}

unsigned long getVal(int index) {
  return atomic_load_relaxed(&count_index[index]);
}

static void write_log(char *result, char *filename) {
  if (getenv("TYPEPLUS_LOG_PATH") != nullptr) {
    char *home = getenv("TYPEPLUS_LOG_PATH");
    char path[MAXPATH];
    strcpy(path, home);
    strcat(path, filename);

    // Append to file with name containing process_id to ensure to process
    // collision
    FILE *op = fopen(path, "a");
    if (op != NULL) {
      fprintf(op, "%s\n", result);
      fflush(op);
      fclose(op);
    }
  } else {
    fprintf(stderr, "Tried to log info but no TYPEPLUS_LOG_PATH set\n");
  }
}

void printInfotoFile(char *PrintStr, char *FileName) {
  write_log(PrintStr, FileName);
}

static void PrintStatResult(void) {

#ifdef PRINT_BAD_CASTING_STATS
  char tmp[MAXLEN];
  char fileName[MAXLEN] = "/total_result.txt";

  snprintf(tmp, sizeof(tmp), "== Casting verification status ==\n");
  printInfotoFile(tmp, fileName);
  snprintf(tmp, sizeof(tmp), "VPTR through constructor: %lu\n",
           getVal(numVTAdded));
  printInfotoFile(tmp, fileName);
  snprintf(tmp, sizeof(tmp), "Vptr Insertor Call: %lu\n",
           getVal(numVICallAdded));
  printInfotoFile(tmp, fileName);

  snprintf(
      tmp, sizeof(tmp),
      "Unrelated Casting: %lu, Type_Confusion: %lu, Missed: %lu, Handled: "
      "%lu\n",
      getVal(numCastUnrl), getVal(numCastUnrlBad), getVal(numCastUnrlMiss),
      (getVal(numCastUnrl) - getVal(numCastUnrlBad) - getVal(numCastUnrlMiss)));
  printInfotoFile(tmp, fileName);
  snprintf(
      tmp, sizeof(tmp),
      "Derived Casting: %lu, Type_Confusion: %lu, Missed: %lu, Handled: %lu\n",
      getVal(numCastDrvd), getVal(numCastDrvdBad), getVal(numCastDrvdMiss),
      (getVal(numCastDrvd) - getVal(numCastDrvdBad) - getVal(numCastDrvdMiss)));
  printInfotoFile(tmp, fileName);
#endif
}

static void HexTypeAtExit(void) { PrintStatResult(); }

void InstallAtExitHandler() { atexit(HexTypeAtExit); }
#endif

extern "C" SANITIZER_INTERFACE_ATTRIBUTE void
__profiling_typecheck(CFICheckFailData *Data) {
#ifdef HEX_LOG

  if (Data->CheckKind == CFITCK_DerivedCast)
    IncVal(numCastDrvd, 1);
  if (Data->CheckKind == CFITCK_UnrelatedCast)
    IncVal(numCastUnrl, 1);
  if (!isInit) {
    isInit = true;
    InstallAtExitHandler();
  }
#endif
  return;
}

extern "C" SANITIZER_INTERFACE_ATTRIBUTE void
__profiling_constructor_init_call(char *name, int count) {
#ifdef LOG_INSERTOR_CALL

  IncVal(numVTAdded, count);
  if (!isInit) {
    isInit = true;
    InstallAtExitHandler();
  }
  // char tmp[MAXLEN];
  // char fileName[MAXLEN] = "/inst_cast.txt";
  // snprintf(tmp, sizeof(tmp), "%s", name);
  // printInfotoFile(tmp, fileName);
#endif
  return;
}

uint64_t hashString(const char *str) {
  MurMur2Hash64Builder hashBuilder;
  for (size_t i = 0; str[i] != '\0'; ++i) {
    hashBuilder.add(static_cast<uint64_t>(str[i]));
  }
  return hashBuilder.get();
}

bool isAlreadyLogged(const char * str1, const char * str2) {
    char *home = getenv("TYPEPLUS_LOG_PATH");
    char path[MAXPATH];
    strcpy(path, home);
    __sanitizer::MurMur2Hash64Builder hash;
    hash.add(hashString(str1));
    hash.add(hashString(str2));
    char hashFileName[MAXPATH];
    snprintf(hashFileName, sizeof(hashFileName), "/%zu.txt", hash.get());
    strcat(path, hashFileName);
    struct stat buffer2;
    bool isAlreadyLogged = stat(path, &buffer2) == 0;
    if(!isAlreadyLogged) {
      printInfotoFile("found", hashFileName);
    }
    return isAlreadyLogged;
}

extern "C" SANITIZER_INTERFACE_ATTRIBUTE void
__profiling_vptr_insertor_call(char *name, int count) {
#ifdef LOG_INSERTOR_CALL

  IncVal(numVICallAdded, count);
  if (!isInit) {
    isInit = true;
    InstallAtExitHandler();
  }
  // char tmp[MAXLEN];
  // char fileName[MAXLEN] = "/inst_cast.txt";
  // snprintf(tmp, sizeof(tmp), "%s", name);
  // printInfotoFile(tmp, fileName);
#endif
  return;
}

extern "C" SANITIZER_INTERFACE_ATTRIBUTE void
__report_type_confusion(CFICheckFailData *Data, ValueHandle Value,
                        uptr ValidVtable) {
  int j, nptrs;
  void *buffer[BT_BUF_SIZE];
  char **strings;
  if (!ValidVtable) {
#ifdef HEX_LOG
    if (Data->CheckKind == CFITCK_DerivedCast)
      IncVal(numCastDrvdMiss, 1);
    if (Data->CheckKind == CFITCK_UnrelatedCast)
      IncVal(numCastUnrlMiss, 1);
#endif
#ifdef PRINT_MISSED_CAST
    char tmp[MAXLEN];
    char tmp1[MAXLEN];
    char tmp2[MAXLEN];
    char fileName[MAXLEN] = "/missed_cast.txt";

    SourceLocation LocFile = Data->Loc.acquire();
    const char *type = "unknown cast";
    if (Data->CheckKind == CFITCK_DerivedCast) {
      type = "d";
    }

    if (Data->CheckKind == CFITCK_UnrelatedCast) {
      type = "u";
    }

    DynamicTypeInfo DTIFile = ValidVtable
                                  ? getDynamicTypeInfoFromVtable((void *)Value)
                                  : DynamicTypeInfo(0, 0, 0);
    const char *srcName = "";
    if (DTIFile.isValid())
      srcName = DTIFile.getMostDerivedTypeName();
    snprintf(tmp, sizeof(tmp), "%s (Src) %s to (Dst): %s ==", type, srcName,
             Data->Type.getTypeName());
    snprintf(tmp1, sizeof(tmp1), "File: %s Ln: %d Col: %d", LocFile.getFilename(),
             LocFile.getLine(), LocFile.getColumn());

    if (!isAlreadyLogged(tmp, tmp1)) {
      printInfotoFile(tmp, fileName);
      printInfotoFile(tmp1, fileName);
      snprintf(tmp, sizeof(tmp), "\t Call Stack:");
      printInfotoFile(tmp, fileName);

      nptrs = backtrace(buffer, BT_BUF_SIZE);
      strings = backtrace_symbols(buffer, nptrs);
      if (strings != NULL)
        for (j = 0; j < nptrs; j++) {
          snprintf(tmp, sizeof(tmp), "\t\t%s", strings[j]);
          printInfotoFile(tmp, fileName);
        }
      free(strings);
    }
#endif // PRINT_MISSED_CAST
#ifdef PRINT_BAD_CASTING_FATAL
  TERMINATE
#endif
    return;
  }

#ifdef HEX_LOG
  if (Data->CheckKind == CFITCK_DerivedCast)
    IncVal(numCastDrvdBad, 1);
  if (Data->CheckKind == CFITCK_UnrelatedCast)
    IncVal(numCastUnrlBad, 1);

#endif

#ifdef PRINT_BAD_CASTING_STDOUT
  SourceLocation Loc = Data->Loc.acquire();
  if (Data->CheckKind == CFITCK_DerivedCast)
    printf("\n\n Detect type confusion from base-to-derived cast\n");

  if (Data->CheckKind == CFITCK_UnrelatedCast)
    printf("\n\n Detect type confusion from cast to unrelated type\n");

  DynamicTypeInfo DTI = ValidVtable
                            ? getDynamicTypeInfoFromVtable((void *)ValidVtable)
                            : DynamicTypeInfo(0, 0, 0);

  if (!DTI.isValid())
    printf("\t %d, type casting from (Src) invalid to (Dst): %s ==\n",
           ValidVtable, Data->Type.getTypeName());

  else
    printf("\t %d, type casting from (Src) %s to (Dst): %s ==\n", ValidVtable,
           DTI.getMostDerivedTypeName(), Data->Type.getTypeName());

  printf("\t Filename: %s Line: %d Column: %d\n", Loc.getFilename(),
         Loc.getLine(), Loc.getColumn());
  printf("\t Call Stack: \n");
  nptrs = backtrace(buffer, BT_BUF_SIZE);
  strings = backtrace_symbols(buffer, nptrs);
  if (strings != NULL)
    for (j = 0; j < nptrs; j++)
      printf("\t\t%s\n", strings[j]);
  free(strings);
#endif

#ifdef PRINT_BAD_CASTING_FILE
  char tmp[MAXLEN];
  char tmp1[MAXLEN];
  char tmp2[MAXLEN];
  char fileName[MAXLEN] = "/type_confusion.txt";

  SourceLocation LocFile = Data->Loc.acquire();
  const char *type = "unknown cast";
  if (Data->CheckKind == CFITCK_DerivedCast) {
    type = "derived cast";
  }

  if (Data->CheckKind == CFITCK_UnrelatedCast) {
    type = "unrelated cast";
  }

  DynamicTypeInfo DTIFile = ValidVtable
                                ? getDynamicTypeInfoFromVtable((void *)Value)
                                : DynamicTypeInfo(0, 0, 0);
  const char *srcName = "";
  if (DTIFile.isValid())
    srcName = DTIFile.getMostDerivedTypeName();
    snprintf(tmp, sizeof(tmp), "%s (Src) %s to (Dst): %s ==", type, srcName,
           Data->Type.getTypeName());

    snprintf(tmp1, sizeof(tmp1), "File: %s Ln: %d Col: %d", LocFile.getFilename(),
           LocFile.getLine(), LocFile.getColumn());
    if (!isAlreadyLogged(tmp, tmp1)) {
      printInfotoFile(tmp, fileName);
      printInfotoFile(tmp1, fileName);

      snprintf(tmp, sizeof(tmp), "\t Call Stack:");
      printInfotoFile(tmp, fileName);

      nptrs = backtrace(buffer, BT_BUF_SIZE);
      strings = backtrace_symbols(buffer, nptrs);
      if (strings != NULL)
        for (j = 0; j < nptrs; j++) {
          snprintf(tmp, sizeof(tmp), "\t\t%s", strings[j]);
          printInfotoFile(tmp, fileName);
        }
      free(strings);
    }
#endif

#if defined(PRINT_BAD_CASTING_STDERR) || defined(PRINT_BAD_CASTING_FATAL)
  SourceLocation LocSTDERR = Data->Loc.acquire();
  if (Data->CheckKind == CFITCK_DerivedCast)
    fprintf(stderr,
            "\n\n== Detect type confusion from base-to-derived cast ==\n");

  if (Data->CheckKind == CFITCK_UnrelatedCast)
    fprintf(stderr,
            "\n\n== Detect type confusion from cast to unrelated type ==\n");

  DynamicTypeInfo DTISTDERR = getDynamicTypeInfoFromVtable((void *)Value);

  fprintf(stderr, "\t type casting from (Src) %s to (Dst): %s ==\n",
          DTISTDERR.getMostDerivedTypeName(), Data->Type.getTypeName());
  fprintf(stderr, "\t Filename: %s Line: %d Column: %d\n",
          LocSTDERR.getFilename(), LocSTDERR.getLine(), LocSTDERR.getColumn());
  fprintf(stderr, "\t Call Stack:\n");

  nptrs = backtrace(buffer, BT_BUF_SIZE);
  backtrace_symbols_fd(buffer, nptrs, 2);
#endif

#ifdef PRINT_BAD_CASTING_FATAL
  TERMINATE
#endif

  return;
}

extern "C" SANITIZER_INTERFACE_ATTRIBUTE void
__report_type_confusion2(CFICheckFailData *Data, uptr ValidVtable) {
  __report_type_confusion(Data, 0, false);
}
