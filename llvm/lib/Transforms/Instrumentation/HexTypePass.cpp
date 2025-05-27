//===-- HexTypePass.cpp -----------------------------------------------===//
//
// This file is a part of HexTypePlus, a type confusion detector.
//
// The HexTypePass has below two functions:
//
//===----------------------------------------------------------------------===//

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/InitializePasses.h" // necessary
#include "llvm/Pass.h"
#include "llvm/Transforms/Instrumentation.h"
#include "llvm/Transforms/Instrumentation/HexType.h"
#include "llvm/Transforms/Utils/HexTypeUtil.h"
#include <cstdint>

#define MAXLEN 10000

using namespace llvm;
using namespace std;

namespace {

bool isInterestingStructType(StructType *STy) {
  return STy->isStructTy() && STy->hasName() && !STy->isLiteral() &&
         !STy->isOpaque();
}

void setTypeDetailInfo(StructType *STy) {
  std::string str = STy->getName().str();
  HexTypeCommonUtil::syncTypeName(str);
  uint64_t TypeHashValue = HexTypeCommonUtil::getHashValueFromSTy(STy);

  char fileName[MAXLEN];
  char tmp[MAXLEN];
  strcpy(fileName, "/typehashinfo.txt");
  sprintf(tmp, "%" PRIu64 " %s", TypeHashValue, str.c_str());
  HexTypeCommonUtil::writeInfoToFile(tmp, fileName);
  return;
}

void parsingTypeInfo(StructType *STy) {
  setTypeDetailInfo(STy);
  // get parent type information
  if (STy->elements().size() > 0) {
    for (StructType::element_iterator I = STy->element_begin(),
                                      E = STy->element_end();
         I != E; ++I) {
      StructType *innerSTy = dyn_cast<StructType>(*I);
      if (innerSTy && isInterestingStructType(innerSTy)) {
        setTypeDetailInfo(innerSTy);
      }
    }
  }
  return;
}

void doHexTypePass(Module &M) {
  if (ClCreateDerivedCastTypeList) {
    // Create full type-releationship information
    std::vector<StructType *> Types = M.getIdentifiedStructTypes();
    for (StructType *ST : Types) {
      if (!isInterestingStructType(ST)) {
        continue;
      }
      parsingTypeInfo(ST);
    }
  }
  if (ClTypePlusProfilingAllClasses) {
    std::vector<StructType *> Types = M.getIdentifiedStructTypes();
    for (StructType *ST : Types) {

      char fileName[MAXLEN];
      char tmp[MAXLEN];
      std::string str = ST->getName().str();
      HexTypeCommonUtil::syncTypeName(str);
      strcpy(fileName, "/all_classes.txt");
      sprintf(tmp, "%s", str.c_str());
      HexTypeCommonUtil::writeInfoToFile(tmp, fileName);
    }
  }
}

struct HexType : public ModulePass {
  static char ID;
  HexType() : ModulePass(ID) {}

  virtual bool runOnModule(Module &M) override { return false; }
};
} // namespace

// register pass -- legacy
char HexType::ID = 0;

INITIALIZE_PASS(HexType, "HexType",
                "HexTypePass: fast type safety for C++ programs.", false, false)

ModulePass *createHexTypePass() { return new HexType(); }

// new PM
PreservedAnalyses HexTypePass::run(Module &M, ModuleAnalysisManager &MAM) {
  doHexTypePass(M);
  return PreservedAnalyses::none();
}
