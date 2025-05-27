//===- Transforms/Instrumentation/HexType.h - TSan Pass -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the hex type pass.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_INSTRUMENTATION_HEXTYPE_H
#define LLVM_TRANSFORMS_INSTRUMENTATION_HEXTYPE_H

#include "llvm/IR/PassManager.h"
#include "llvm/Pass.h"

namespace llvm {

struct HexTypePass : public PassInfoMixin<HexTypePass> {
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);
};

} // namespace llvm
#endif /* LLVM_TRANSFORMS_INSTRUMENTATION_HEXTYPE_H */
