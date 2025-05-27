////===-- HexTypeUtil.h -- helper functions and classes for HexType -------===//
////
////                     The LLVM Compiler Infrastructure
////
//// This file is distributed under the University of Illinois Open Source
//// License. See LICENSE.TXT for details.
////
////===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_UTILS_HEXTYPE_H
#define LLVM_TRANSFORMS_UTILS_HEXTYPE_H

#include "llvm/IR/DerivedTypes.h"
#include "llvm/Support/CommandLine.h"

namespace llvm {

extern cl::opt<bool> ClCreateUnrelatedCastTypeList;
extern cl::opt<bool> ClVoidStar;
extern cl::opt<bool> ClCreateDerivedCastTypeList;
extern cl::opt<bool> ClOldClassList;
extern cl::opt<bool> ClWrongPolymorphism;
extern cl::opt<bool> ClMissingChecks;
extern cl::opt<bool> ClCastObjOpt;
extern cl::opt<bool> ClNoCheckUnsuppClass;
extern cl::opt<bool> ClPolyClasses;
extern cl::opt<bool> ClTypePlusProfiling;
extern cl::opt<bool> ClTypePlusProfilingAllClasses;
extern cl::opt<bool> ClNoSetSourcererRTTI;
extern cl::opt<bool> ClVtableStandard;
extern cl::opt<bool> ClTypePlusCheckDerivedCasting;
extern cl::opt<bool> ClTypePlusCheckUnrelatedCasting;
extern cl::opt<bool> ClStackOpt;

class HexTypeCommonUtil {
public:
  static uint64_t getHashValueFromStr(std::string &);
  static uint64_t getHashValueFromSTy(StructType *);
  static void syncTypeName(std::string &);
  static void logClassToFile(Type *, const char *);
  static void updateDerivedCastingRelatedTypeIntoFile(Type *);
  static void updateUnrelatedCastingTypeIntoFile(Type *);
  static void writeInfoToFile(char *, char *);
  static void updateCastingRelatedTypeIntoFile(Type *);
};
} // namespace llvm
#endif // LLVM_TRANSFORMS_UTILS_HEXTYPE_H
