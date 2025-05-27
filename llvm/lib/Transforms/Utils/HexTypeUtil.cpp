//===- HexTypeUtil.cpp - helper functions and classes for HexType ---------===//
////
////                     The LLVM Compiler Infrastructure
////
//// This file is distributed under the University of Illinois Open Source
//// License. See LICENSE.TXT for details.
////
////===--------------------------------------------------------------------===//

#include "llvm/Transforms/Utils/HexTypeUtil.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/Support/CommandLine.h"

#include <sys/types.h>
#include <unistd.h>

#define MAXLEN 1000

namespace llvm {
// Command line options for Vtype
cl::opt<bool>
    ClCreateDerivedCastTypeList("create-derived-cast-type-list",
                                cl::desc("create casting related object list"),
                                cl::Hidden, llvm::cl::init(false));
cl::opt<bool> ClVoidStar("create-void-star-type-list",
                         cl::desc("create casting void star object list"),
                         cl::Hidden, llvm::cl::init(false));

cl::opt<bool> ClCreateUnrelatedCastTypeList(
    "create-unrelated-cast-type-list",
    cl::desc("create casting related object list"), cl::Hidden,
    llvm::cl::init(false));

cl::opt<bool> ClOldClassList("old-class-list",
                             cl::desc("revert to old method of collecting "
                                      "classes, incomplete for unrelated cast"),
                             cl::Hidden, llvm::cl::init(false));

cl::opt<bool>
    ClWrongPolymorphism("wrong-polymorphism",
                        cl::desc("SHOULD NOT BE USED, legacy version of "
                                 "setting polymorphism, incorrect"),
                        cl::Hidden, llvm::cl::init(false));

cl::opt<bool> ClMissingChecks("missing-checks",
                              cl::desc("SHOULD NOT BE USED, legacy version of "
                                       "cast checking which was incomplete"),
                              cl::Hidden, llvm::cl::init(false));

cl::opt<bool> ClPolyClasses("poly-classes",
                            llvm::cl::desc("force classes to be polymorphic"),
                            llvm::cl::Hidden, llvm::cl::init(false));

cl::opt<bool> ClCastObjOpt(
    "cast-obj-opt",
    llvm::cl::desc(
        "insert vtable into only casting related object tracing optimization"),
    llvm::cl::Hidden, llvm::cl::init(false));

cl::opt<bool> ClNoCheckUnsuppClass(
    "no-check-unsupported-class",
    llvm::cl::desc(
        "do not check class not in the list of casting related object"),
    llvm::cl::Hidden, llvm::cl::init(false));

cl::opt<bool> ClTypePlusProfilingAllClasses(
    "collect-profiling-data-all",
    llvm::cl::desc("collect profiling data incl. all classes"),
    llvm::cl::Hidden, llvm::cl::init(false));

cl::opt<bool> ClTypePlusProfiling("collect-profiling-data",
                                  llvm::cl::desc("collect profiling data"),
                                  llvm::cl::Hidden, llvm::cl::init(false));

cl::opt<bool> ClNoSetSourcererRTTI(
    "no-set-sourcerer-rtti",
    llvm::cl::desc("do not call insertor to set RTTI"),
    llvm::cl::Hidden, llvm::cl::init(false));

cl::opt<bool> ClVtableStandard(
    "apply-vtable-standard",
    llvm::cl::desc("insert vtable into standardlayout class also"),
    llvm::cl::Hidden, llvm::cl::init(false));

cl::opt<bool> ClTypePlusCheckDerivedCasting(
    "check-base-to-derived-casting",
    cl::desc("use llvm cfi type casting verification"), cl::Hidden,
    llvm::cl::init(false));

cl::opt<bool> ClTypePlusCheckUnrelatedCasting(
    "check-unrelated-casting",
    cl::desc("use llvm cfi type casting verification for"), cl::Hidden,
    llvm::cl::init(false));
// END Command line options for Vtype

void removeTargetStr(std::string &FullStr, std::string RemoveStr) {
  std::string::size_type i;

  while ((i = FullStr.find(RemoveStr)) != std::string::npos) {
    if (RemoveStr.compare("::") == 0) {
      FullStr.erase(FullStr.begin(), FullStr.begin() + i + 2);
    } else {
      FullStr.erase(i, RemoveStr.length());
    }
  }
}

void removeTargetNum(std::string &TargetStr) {
  std::string::size_type i;
  if ((i = TargetStr.find(".")) == std::string::npos) {
    return;
  }

  if ((i + 1 < TargetStr.size()) &&
      (TargetStr[i + 1] >= '0' && TargetStr[i + 1] <= '9')) {
    TargetStr.erase(i, TargetStr.size() - i);
  }
}

uint64_t crc64c(unsigned char *message) {
  int i, j;
  unsigned int byte;
  uint64_t crc, mask;
  static uint64_t table[256];

  if (table[1] == 0) {
    for (byte = 0; byte <= 255; byte++) {
      crc = byte;
      for (j = 7; j >= 0; j--) { // Do eight times.
        mask = -(crc & 1);
        crc = (crc >> 1) ^ (0xC96C5795D7870F42UL & mask);
      }
      table[byte] = crc;
    }
  }

  i = 0;
  crc = 0xFFFFFFFFFFFFFFFFUL;
  while ((byte = message[i]) != 0) {
    crc = (crc >> 8) ^ table[(crc ^ byte) & 0xFF];
    i = i + 1;
  }
  return ~crc;
}

uint64_t HexTypeCommonUtil::getHashValueFromStr(std::string &str) {
  syncTypeName(str);
  unsigned char *className = new unsigned char[str.length() + 1];
  strcpy((char *)className, str.c_str());
  return crc64c(className);
}

uint64_t HexTypeCommonUtil::getHashValueFromSTy(StructType *STy) {
  std::string str = STy->getName().str();
  syncTypeName(str);
  return getHashValueFromStr(str);
}

void HexTypeCommonUtil::syncTypeName(std::string &TargetStr) {
  SmallVector<std::string, 12> RemoveStrs;
  RemoveStrs.push_back("::");
  RemoveStrs.push_back("class.");
  RemoveStrs.push_back("./");
  RemoveStrs.push_back("struct.");
  RemoveStrs.push_back("union.");
  RemoveStrs.push_back(".base");
  RemoveStrs.push_back("trackedtype.");
  RemoveStrs.push_back("blacklistedtype.");
  RemoveStrs.push_back("*");
  RemoveStrs.push_back("'");

  for (unsigned long i = 0; i < RemoveStrs.size(); i++) {
    removeTargetStr(TargetStr, RemoveStrs[i]);
  }
  removeTargetNum(TargetStr);
}

void HexTypeCommonUtil::updateDerivedCastingRelatedTypeIntoFile(Type *SrcTy) {
  logClassToFile(SrcTy, "/derived_casting_obj_init");
}

void HexTypeCommonUtil::updateUnrelatedCastingTypeIntoFile(Type *SrcTy) {
  logClassToFile(SrcTy, "/unrelated_casting_obj_init");
}

void HexTypeCommonUtil::logClassToFile(Type *AggTy, const char *filename) {
  if (AggTy->isStructTy()) {
    char fileName[MAXLEN];
    char fileNameTmp[MAXLEN];
    strcpy(fileName, filename);
    sprintf(fileNameTmp, "_%d.txt", getpid());
    strcat(fileName, fileNameTmp);

    char tmp[MAXLEN];
    std::string TypeName(AggTy->getStructName().str());
    syncTypeName(TypeName);
    sprintf(tmp, "%s", TypeName.c_str());
    writeInfoToFile(tmp, fileName);
  }
}

void HexTypeCommonUtil::updateCastingRelatedTypeIntoFile(Type *SrcTy) {
  if (SrcTy->isPointerTy()) {
    llvm::PointerType *ptr = cast<llvm::PointerType>(SrcTy);
    if (llvm::Type *AggTy = ptr) {
      if (AggTy->isStructTy()) {
        char fileName[MAXLEN];
        char fileNameTmp[MAXLEN];
        strcpy(fileName, "/casting_obj_init");
        sprintf(fileNameTmp, "_%d.txt", getpid());
        strcat(fileName, fileNameTmp);

        char tmp[MAXLEN];
        std::string TypeName(AggTy->getStructName().str());
        syncTypeName(TypeName);
        sprintf(tmp, "%s", TypeName.c_str());
        writeInfoToFile(tmp, fileName);
      }
    }
  } else if (SrcTy->isStructTy()) {
  }
}

void HexTypeCommonUtil::writeInfoToFile(char *Info, char *FilePath) {
  assert(Info && "Invalid information");
  assert(FilePath && "Invalid filepath");
  if ((Info != NULL) && getenv("TYPEPLUS_LOG_PATH") != nullptr) {
    char path[MAXLEN];
    strcpy(path, getenv("TYPEPLUS_LOG_PATH"));
    strcat(path, FilePath);

    FILE *op = fopen(path, "a");
    if (op) {
      fprintf(op, "%s\n", Info);
      fflush(op);
      fclose(op);
    }
  } else {
    fprintf(stderr,
            "TypePlus Logging Error: Invalid information or filepath\n");
    exit(1);
  }
}
} // namespace llvm
