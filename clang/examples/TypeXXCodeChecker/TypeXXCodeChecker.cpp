//===- TypeXXCodeChecker.cpp ---------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Example clang plugin which simply prints the names of all the top-level decls
// in the input file.
//
//===----------------------------------------------------------------------===//

#include "clang/AST/AST.h"
#include "clang/AST/ASTConsumer.h"
#include "clang/AST/RecursiveASTVisitor.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/FrontendPluginRegistry.h"
#include "clang/Sema/Sema.h"
#include "clang/Sema/SemaInternal.h"

#include "llvm/Support/raw_ostream.h"

#include "clang/ASTMatchers/ASTMatchFinder.h"

#include <algorithm>
#include <fstream>
#include <map>
#include <set>

using namespace clang;

namespace {

class TypeInfo {
public:
  uint64_t hashValue;
  std::set<std::string> directParents;
  std::set<std::string> directPhantomTypes;
  std::set<std::string> allParents;
  std::set<std::string> allPhantomTypes;
};

using namespace clang::ast_matchers;
class DiagnosticsMatcher {
public:
  DiagnosticsMatcher();

  void emitWarning(const MatchFinder::MatchResult &, std::string, std::string,
                   std::string, std::string);
  bool hasAProblem(RecordDecl *);
  bool isAPhantomCast(std::string, std::string);

  std::unique_ptr<clang::ASTConsumer> makeASTConsumer() {
    return astMatcher.newASTConsumer();
  }

private:
  class SizeOfChecker : public MatchFinder::MatchCallback {
  public:
    SizeOfChecker(DiagnosticsMatcher *_parentDiagnostic)
        : MatchFinder::MatchCallback() {
      parentDiagnostic = _parentDiagnostic;
    }
    virtual void run(const MatchFinder::MatchResult &Result) override;

  private:
    DiagnosticsMatcher *parentDiagnostic;
  };

  class OffsetofChecker : public MatchFinder::MatchCallback {
  public:
    OffsetofChecker(DiagnosticsMatcher *_parentDiagnostic)
        : MatchFinder::MatchCallback() {
      parentDiagnostic = _parentDiagnostic;
    }
    virtual void run(const MatchFinder::MatchResult &Result) override;

  private:
    DiagnosticsMatcher *parentDiagnostic;
  };

  class ReinterpretCastChecker : public MatchFinder::MatchCallback {
  public:
    ReinterpretCastChecker(DiagnosticsMatcher *_parentDiagnostic)
        : MatchFinder::MatchCallback() {
      parentDiagnostic = _parentDiagnostic;
    }
    virtual void run(const MatchFinder::MatchResult &Result) override;

  private:
    DiagnosticsMatcher *parentDiagnostic;
  };

  class OtherCastChecker : public MatchFinder::MatchCallback {
  public:
    OtherCastChecker(DiagnosticsMatcher *_parentDiagnostic)
        : MatchFinder::MatchCallback() {
      parentDiagnostic = _parentDiagnostic;
    }
    virtual void run(const MatchFinder::MatchResult &Result) override;

  private:
    DiagnosticsMatcher *parentDiagnostic;
  };

  std::set<std::string> classesToCheck;
  bool considerAllClasses;
  std::string logFilePath;

  std::map<uint64_t, std::string> hashNameMap;
  std::map<std::string, TypeInfo> allTypeInfo;
  // std::vector<Constant*> typeInfoArray;
  // std::vector<Constant*> typePhantomInfoArray;
  // std::vector<uint64_t> typeInfoArrayInt;
  // std::set<std::string> CastingRelatedSet;
  // std::set<std::string> CastingRelatedExtendSet;

  MatchFinder astMatcher;
  SizeOfChecker *sizeOfChecker;
  // OffsetofChecker *offsetofChecker;
  OtherCastChecker *otherCastChecker;
  ReinterpretCastChecker *reinterpretCastChecker;
};

DiagnosticsMatcher::DiagnosticsMatcher() {

  char path[10000] = {0};

  // load log file path
  if (getenv("WARNING_LOG_PATH")) {
    strcpy(path, getenv("WARNING_LOG_PATH"));
    logFilePath = path;
  } else {
    llvm::errs() << "WARNING_LOG_PATH not set, exit\n";
    exit(-1);
  }

  memset(path, 0, sizeof(path));
  // load classes structure
  considerAllClasses = true;
  if (getenv("TARGET_TYPE_LIST_PATH")) {
    strcpy(path, getenv("TARGET_TYPE_LIST_PATH"));

    std::fstream newfile;
    newfile.open(path, std::ios::in);
    if (newfile.is_open()) {
      std::string tp;
      while (getline(newfile, tp))
        classesToCheck.insert(tp);
      newfile.close();
      considerAllClasses = false;
    } else {
      llvm::errs() << "TARGET_TYPE_LIST_PATH is not pointing to a correct "
                      "file, considering all classes.\n";
    }
  } else {
    llvm::errs()
        << "TARGET_TYPE_LIST_PATH not defined, considering all classes.\n";
  }

  if (getenv("TYPEPLUS_LOG_PATH") != nullptr) {

    std::fstream newfile;

    // THIS IS FOR S IS FOR typehashinfo.txt
    memset(path, 0, sizeof(path));
    strcpy(path, getenv("TYPEPLUS_LOG_PATH"));
    strcat(path, "/typehashinfo.txt");
    newfile.open(path, std::ios::in);
    if (newfile.is_open()) {
      std::string nameTy;
      uint64_t hashTy;
      while (newfile >> hashTy >> nameTy) {
        hashNameMap[hashTy] = nameTy;}
      newfile.close();
    }

    // THIS IS FOR S IS FOR typeinfo.txt
    memset(path, 0, sizeof(path));
    strcpy(path, getenv("TYPEPLUS_LOG_PATH"));
    strcat(path, "/typeinfo.txt");
    newfile.open(path, std::ios::in);
    if (newfile.is_open()) {
      uint64_t fromTy, toTy;
      uint32_t type;
      while (newfile >> type >> fromTy >> toTy) {
        auto fromTyIter = hashNameMap.find(fromTy);
        auto toTyIter = hashNameMap.find(toTy);
        // both hashes are in the name <-> hash map
        if (hashNameMap.count(toTy)) {
        if (hashNameMap.count(fromTy)) {
          std::string fromTyName = fromTyIter->second;
          std::string toTyName = toTyIter->second;

          TypeInfo ti = allTypeInfo[fromTyName];

          // 1 => direct parent
          if (type == 1) {
            ti.directParents.insert(toTyName);
            ti.allParents.insert(toTyName);
          }
          // 2 => phantom cast
          else if (type == 2) {
            ti.directPhantomTypes.insert(toTyName);
            ti.allPhantomTypes.insert(toTyName);
          } /*else {
            llvm::errs() << "Type [" << type << "] not valid, only 1 or 2\n";
            // exit(-1);
          }*/

          allTypeInfo[fromTyName] = ti;
        }}
        // else {
        //   llvm::errs() << "Hash [" << fromTy << "] not valid\n";
        //   llvm::errs() << "Hash [" << toTy << "] not valid\n";
        //   // exit(-1);
        // }
      }
      newfile.close();
    }
  }

  // for (auto const &IT: allTypeInfo) {
  //   llvm::errs() << "> " << IT.first << "\n";
  //   llvm::errs() << "Direct Parents:\n";
  //   for (auto const dp: IT.second.directParents)
  //     llvm::errs() << ">> " << dp << "\n";
  //   llvm::errs() << "Direct Phantom:\n";
  //   for (auto const dp: IT.second.directPhantomTypes)
  //     llvm::errs() << ">> " << dp << "\n";
  //   llvm::errs() << "All Parents:\n";
  //   for (auto const dp: IT.second.allParents)
  //     llvm::errs() << ">> " << dp << "\n";
  //   llvm::errs() << "All Phantom:\n";
  //   for (auto const dp: IT.second.allPhantomTypes)
  //     llvm::errs() << ">> " << dp << "\n";
  //   llvm::errs() << "\n";
  // }

  sizeOfChecker = new SizeOfChecker(this);
  astMatcher.addMatcher(sizeOfExpr(anything()).bind("node"), sizeOfChecker);

  // FOR LATER - do not include
  // offsetofChecker = new OffsetofChecker(this);
  // astMatcher.addMatcher(expr(anything()).bind("node"), offsetofChecker);

  reinterpretCastChecker = new ReinterpretCastChecker(this);
  astMatcher.addMatcher(cxxReinterpretCastExpr(anything()).bind("node"),
                        reinterpretCastChecker);

  // EXTEND WITH ALL OTHER TYPES OF CASTS...
  otherCastChecker = new OtherCastChecker(this);
  astMatcher.addMatcher(cStyleCastExpr(anything()).bind("node"),
                        otherCastChecker);
  astMatcher.addMatcher(cxxConstCastExpr(anything()).bind("node"),
                        otherCastChecker);
  astMatcher.addMatcher(cxxDynamicCastExpr(anything()).bind("node"),
                        otherCastChecker);
  astMatcher.addMatcher(cxxStaticCastExpr(anything()).bind("node"),
                        otherCastChecker);
}

bool DiagnosticsMatcher::hasAProblem(RecordDecl *RD) {

  if (!RD)
    return false;

  if (RD->isStruct() || RD->isClass() || RD->isInterface()) {
    if (considerAllClasses) {
      return true;
    } else {
      StringRef nameStruct = RD->getName();
      if (std::find(classesToCheck.begin(), classesToCheck.end(),
                    nameStruct.str()) != classesToCheck.end())
        return true;
    }
  }
  return false;
}

void DiagnosticsMatcher::emitWarning(const MatchFinder::MatchResult &result,
                                     std::string severity, std::string type,
                                     std::string class1,
                                     std::string class2 = "") {
  const SourceManager *SM = result.SourceManager;

  if (!SM)
    return;

  const Stmt *s = result.Nodes.getNodeAs<Stmt>("node");

  // file name
  SourceLocation Loc = s->getSourceRange().getBegin();
  StringRef FileName = SM->getFilename(Loc);
  unsigned int line = SM->getPresumedLineNumber(Loc);
  unsigned int column = SM->getPresumedColumnNumber(Loc);
  // file offset
  unsigned int Offset = SM->getFileOffset(Loc);

  std::ofstream log(logFilePath, std::ios_base::app | std::ios_base::out);
  log << severity << "|" << type << "|" << FileName.str() << "|" << Offset
      << "|" << line << "|" << column << "|" << class1 << "|" << class2 << "\n";
  log.close();
}

void DiagnosticsMatcher::SizeOfChecker::run(
    const MatchFinder::MatchResult &Result) {
  if (const auto *s =
          Result.Nodes.getNodeAs<UnaryExprOrTypeTraitExpr>("node")) {

    if (!s->isArgumentType())
      return;

    QualType st = s->getArgumentType();
    if (const Type *tt = st.getTypePtr()) {
      if (const auto *RT = tt->getAs<RecordType>()) {

        if (RecordDecl *RD = RT->getDecl()) {

          if (parentDiagnostic->hasAProblem(RD))
            parentDiagnostic->emitWarning(Result, "warning", "sizeof",
                                          RD->getNameAsString());
        }
      }
    }
  }
}

void DiagnosticsMatcher::OffsetofChecker::run(
    const MatchFinder::MatchResult &Result) {
  // TODO FLAVIO: for some reason, offsetof is not well parsed at this stage. To
  // indagate
  if (const auto *s = Result.Nodes.getNodeAs<OffsetOfExpr>("node")) {
    s->dump();
    // expr0->dump();
    // expr1->dump();
    // QualType st = s->getArgumentType();
    //   const Type* tt = st.getTypePtr();parentDiagnostic->emitWarning(Result,
    //   "warning", "sizeof"); if (const auto *RT = tt->getAs<RecordType>()) {
    //     RecordDecl *RD = RT->getDecl();

    //     if (parentDiagnostic->hasAProblem(RD))
    //       parentDiagnostic->emitWarning(Result, "warning", "sizeof",
    //       RD->getNameAsString());
  }
}

void DiagnosticsMatcher::ReinterpretCastChecker::run(
    const MatchFinder::MatchResult &Result) {
  if (const auto *s = Result.Nodes.getNodeAs<CXXReinterpretCastExpr>("node")) {
    QualType st = s->getTypeAsWritten();
    const Type *tt = st.getTypePtr();

    while (const PointerType *pt = dyn_cast<PointerType>(tt)) {
      QualType ste = pt->getPointeeType();
      tt = ste.getTypePtr();
    }

    // if the pointer is pointing a builtin type, skip it
    if (isa<BuiltinType>(tt))
      return;

    RecordDecl *RD = tt->getAsRecordDecl();
    if (RD) {
      if (parentDiagnostic->hasAProblem(RD))
        parentDiagnostic->emitWarning(Result, "warning", "reinterpret_cast",
                                      RD->getNameAsString());
    }
  }
}

void DiagnosticsMatcher::OtherCastChecker::run(
    const MatchFinder::MatchResult &Result) {

  const ExplicitCastExpr *s = nullptr;

  if (Result.Nodes.getNodeAs<CStyleCastExpr>("node"))
    s = Result.Nodes.getNodeAs<ExplicitCastExpr>("node");

  if (Result.Nodes.getNodeAs<CXXStaticCastExpr>("node"))
    s = Result.Nodes.getNodeAs<ExplicitCastExpr>("node");

  if (Result.Nodes.getNodeAs<CXXConstCastExpr>("node"))
    s = Result.Nodes.getNodeAs<ExplicitCastExpr>("node");

  if (Result.Nodes.getNodeAs<CXXDynamicCastExpr>("node"))
    s = Result.Nodes.getNodeAs<ExplicitCastExpr>("node");

  if (s) {

    // this is always the "return" cast
    QualType st = s->getTypeAsWritten();
    const Type *tt = st.getTypePtr();

    while (const PointerType *pt = dyn_cast<PointerType>(tt)) {
      QualType ste = pt->getPointeeType();
      tt = ste.getTypePtr();
    }

    if (isa<BuiltinType>(tt)) {
      // llvm::errs() << "this is a builtin type, not intersted\n";
      return;
    }

    // s->dump();

    RecordDecl *RD = tt->getAsRecordDecl();
    if (!RD)
      return;
    StringRef destinationStructName = RD->getName();
    // llvm::errs() << "I am casting into: " << destinationStructName << "\n";

    const Expr *subExpr = s->getSubExpr();

    if (const auto *cnstExpr = dyn_cast<CXXConstructExpr>(subExpr)) {
      if (cnstExpr->getNumArgs() == 1)
        subExpr = cnstExpr->getArg(0);
      else
        return;
    }

    while (const auto *tmpCast = dyn_cast<ImplicitCastExpr>(subExpr))
      subExpr = tmpCast->getSubExpr();

    tt = subExpr->getType().getTypePtr();

    while (const PointerType *pt = dyn_cast<PointerType>(tt)) {
      QualType ste = pt->getPointeeType();
      tt = ste.getTypePtr();
    }

    RD = tt->getAsRecordDecl();
    if (!RD)
      return;
    StringRef sourceStructName = RD->getName();

    if (parentDiagnostic->isAPhantomCast(sourceStructName.str(),
                                         destinationStructName.str()))
      parentDiagnostic->emitWarning(Result, "warning", "phantomcast",
                                    sourceStructName.str(),
                                    destinationStructName.str());

    // subExpr->dump();
    // tt->dump();
  }
}

bool DiagnosticsMatcher::isAPhantomCast(std::string srcName,
                                        std::string dstName) {

  // I check only a subset of classes (P2)
  if (!considerAllClasses) {

    // if one of the two classes is not in the classesToCheck, the I skip it
    if (std::find(classesToCheck.begin(), classesToCheck.end(), srcName) ==
        classesToCheck.end())
      return false;

    if (std::find(classesToCheck.begin(), classesToCheck.end(), dstName) ==
        classesToCheck.end())
      return false;
  }

  // If one of the classes is not in the typeinfo.txt file, I can't say aynting,
  // so it is just fine I guess
  if (allTypeInfo.find(srcName) == allTypeInfo.end() ||
      allTypeInfo.find(dstName) == allTypeInfo.end())
    return false;

  auto allPhantomType = allTypeInfo[srcName].allPhantomTypes;

  // dstName is in the phantom set of srcName -> there is a phatom cast!
  if (allPhantomType.find(dstName) != allPhantomType.end())
    return true;

  return false;
}

class TypeXXCodeCheckerAction : public PluginASTAction {
protected:
  DiagnosticsMatcher checker = DiagnosticsMatcher();
  std::unique_ptr<ASTConsumer> CreateASTConsumer(CompilerInstance &CI,
                                                 llvm::StringRef) override {
    return checker.makeASTConsumer();
  }

  bool ParseArgs(const CompilerInstance &CI,
                 const std::vector<std::string> &args) override {
    return true;
  }
};

} // namespace

static FrontendPluginRegistry::Add<TypeXXCodeCheckerAction>
    X("typexx-codecheck", "check type++ code compatibility");
