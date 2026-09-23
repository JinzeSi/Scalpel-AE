/**
 *  @file          X86CostModel.cpp
 *
 *  @version       1.0
 *  @created       02/07/2013 11:53:02 AM
 *  @revision      $Id$
 *
 *  @author        Ryan Huang <ryanhuang@cs.ucsd.edu>
 *  @organization  University of California, San Diego
 *  
 *  Copyright (c) 2013, Ryan Huang
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *  http://www.apache.org/licenses/LICENSE-2.0
 *     
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  @section       DESCRIPTION
 *  
 *  x86 cost model implementation
 *
 */

#include <string>

#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/CodeGen/TargetLowering.h"

#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/Host.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/CodeGen/ISDOpcodes.h"
#include "llvm/MC/MCSubtargetInfo.h"

#include "llvm/ADT/STLExtras.h"

#include "llvm/Support/raw_ostream.h"

#include "analyzer/CostTable.h"
#include "analyzer/X86SubtargetStub.h"
#include "analyzer/X86CostModel.h"

using namespace llvm;

#ifdef X86COSTMODEL_DEBUG
  #define WARN_DEFAULT_COST(type)  \
    errs() << "Warning: " <<  #type << " falling to default cost\n"
#else
  #define WARN_DEFAULT_COST(type) 
#endif

//#define X86COSTMODEL_DEBUG

X86CostModel::X86CostModel(TargetMachine *TM) : CostModel(), TM(TM)
{
  assert (TM && "Target machine cannot be NULL");
  
  LLVMContext Ctx;
  Module M("dummy", Ctx);
  M.setDataLayout(TM->createDataLayout());
  Function *F = Function::Create(FunctionType::get(Type::getVoidTy(Ctx), false),
                                 GlobalValue::ExternalLinkage, "dummy", &M);
  // 通过 Subtarget 获取 TargetLowering
  TLI = TM->getSubtargetImpl(*F)->getTargetLowering();

  assert(TLI && "No associated target lowering");
  VTT = new VectorTargetTransformStub(TLI);

  const MCSubtargetInfo *TSI = TM->getMCSubtargetInfo();
  FeatureBitset Bits = TSI->getFeatureBits();
  #ifdef X86COSTMODEL_DEBUG
  errs() << "Feature bits: " << Bits << "\n";
  #endif

  ST = new X86SubtargetStub(Bits);

  
  #ifdef X86COSTMODEL_DEBUG
  errs() << "has3DNow " << ST->has3DNow() << "\n";
  errs() << "hasAVX " << ST->hasAVX() << "\n";
  errs() << "is64Bit " << ST->is64Bit() << "\n";
  errs() << "hasBMI " << ST->hasBMI() << "\n";
  errs() << "isBTMemSlow " << ST->isBTMemSlow() << "\n";
  errs() << "hasCmpxchg16b " << ST->hasCmpxchg16b() << "\n";
  #endif
}

X86CostModel::~X86CostModel()
{
  if (VTT == NULL)
    delete VTT;
  if (ST == NULL)
    delete ST;
}

unsigned X86CostModel::getNumberOfRegisters(bool Vector) const
{
  if (Vector && !ST->hasSSE1())
    return 0;

  if (ST->is64Bit())
    return 16;
  return 8;
}
unsigned X86CostModel::getRegisterBitWidth(bool Vector) const
{
  if (Vector) {
    if (ST->hasAVX()) return 256;
    if (ST->hasSSE1()) return 128;
    return 0;
  }

  if (ST->is64Bit())
    return 64;
  return 32;
}

unsigned X86CostModel::getMaximumUnrollFactor() const
{
  if (ST->isAtom())
    return 1;

  // Sandybridge and Haswell have multiple execution ports and pipelined
  // vector units.
  if (ST->hasAVX())
    return 4;

  return 2;
}

unsigned X86CostModel::getArithmeticInstrCost(unsigned Opcode, Type *Ty) const
{
  std::pair<unsigned, MVT> LT = VTT->getTypeLegalizationCost(Ty);

  int ISD = VectorTargetTransformStub::InstructionOpcodeToISD(Opcode);
  assert(ISD && "Invalid opcode");

  static const CostTblEntry<MVT> AVX1CostTable[] = {
    // We don't have to scalarize unsupported ops. We can issue two half-sized
    // operations and we only need to extract the upper YMM half.
    // Two ops + 1 extract + 1 insert = 4.
    { ISD::MUL,     MVT::v8i32,    4 },
    { ISD::SUB,     MVT::v8i32,    4 },
    { ISD::ADD,     MVT::v8i32,    4 },
    { ISD::MUL,     MVT::v4i64,    4 },
    { ISD::SUB,     MVT::v4i64,    4 },
    { ISD::ADD,     MVT::v4i64,    4 },
  };

  // Look for AVX1 lowering tricks.
  if (ST->hasAVX()) {
    int Idx = CostTableLookup<MVT>(AVX1CostTable, array_lengthof(AVX1CostTable), ISD,
                          LT.second);
    if (Idx != -1)
      return LT.first * AVX1CostTable[Idx].Cost;
  }
  //WARN_DEFAULT_COST(arithmetic);
  return VTT->getArithmeticInstrCost(Opcode, Ty);
}

unsigned X86CostModel::getShuffleCost(ShuffleKind Kind, Type *Tp,
   int Index, Type *SubTp) const
{
    // We only estimate the cost of reverse shuffles.
  if (Kind != SK_Reverse) {
    WARN_DEFAULT_COST(shuffle);
    return 1;
  }

  std::pair<unsigned, MVT> LT = VTT->getTypeLegalizationCost(Tp);
  unsigned Cost = 1;
  //TODO
  if (LT.second != MVT::Other && LT.second.getSizeInBits() > 128)
    Cost = 3; // Extract + insert + copy.

  // Multiple by the number of parts.
  return Cost * LT.first;
}

unsigned X86CostModel::getCastInstrCost(unsigned Opcode, Type *Dst,
   Type *Src) const
{
  int ISD = VectorTargetTransformStub::InstructionOpcodeToISD(Opcode);
  assert(ISD && "Invalid opcode");

  const DataLayout &DL = TLI->getTargetMachine().createDataLayout();
  EVT SrcTy = TLI->getValueType(DL, Src);
  EVT DstTy = TLI->getValueType(DL, Dst);

  if (!SrcTy.isSimple() || !DstTy.isSimple()) {
    WARN_DEFAULT_COST(cast);
    return VTT->getCastInstrCost(Opcode, Dst, Src);
  }

  static const TypeConversionCostTblEntry<MVT> AVXConversionTbl[] = {
    { ISD::SIGN_EXTEND, MVT::v8i32, MVT::v8i16, 1 },
    { ISD::ZERO_EXTEND, MVT::v8i32, MVT::v8i16, 1 },
    { ISD::SIGN_EXTEND, MVT::v4i64, MVT::v4i32, 1 },
    { ISD::ZERO_EXTEND, MVT::v4i64, MVT::v4i32, 1 },
    { ISD::TRUNCATE,    MVT::v4i32, MVT::v4i64, 1 },
    { ISD::TRUNCATE,    MVT::v8i16, MVT::v8i32, 1 },
    { ISD::SINT_TO_FP,  MVT::v8f32, MVT::v8i8,  1 },
    { ISD::SINT_TO_FP,  MVT::v4f32, MVT::v4i8,  1 },
    { ISD::UINT_TO_FP,  MVT::v8f32, MVT::v8i8,  1 },
    { ISD::UINT_TO_FP,  MVT::v4f32, MVT::v4i8,  1 },
    { ISD::FP_TO_SINT,  MVT::v8i8,  MVT::v8f32, 1 },
    { ISD::FP_TO_SINT,  MVT::v4i8,  MVT::v4f32, 1 },
//  { ISD::ZERO_EXTEND, MVT::v8i32, MVT::v8i1,  6 },
//  { ISD::SIGN_EXTEND, MVT::v8i32, MVT::v8i1,  9 },
    { ISD::TRUNCATE,    MVT::v8i32, MVT::v8i64, 3 },
  };

  if (ST->hasAVX()) {
    int Idx = ConvertCostTableLookup<MVT>(AVXConversionTbl,
                                 array_lengthof(AVXConversionTbl),
                                 ISD, DstTy.getSimpleVT(), SrcTy.getSimpleVT());
    if (Idx != -1)
      return AVXConversionTbl[Idx].Cost;
  }
  WARN_DEFAULT_COST(cast);
  return VTT->getCastInstrCost(Opcode, Dst, Src);
}

unsigned X86CostModel::getCmpSelInstrCost(unsigned Opcode, Type *ValTy,
   Type *CondTy) const
{
  // Legalize the type.
  std::pair<unsigned, MVT> LT = VTT->getTypeLegalizationCost(ValTy);

  MVT MTy = LT.second;

  int ISD = VectorTargetTransformStub::InstructionOpcodeToISD(Opcode);
  assert(ISD && "Invalid opcode");

  static const CostTblEntry<MVT> SSE42CostTbl[] = {
    { ISD::SETCC,   MVT::v2f64,   1 },
    { ISD::SETCC,   MVT::v4f32,   1 },
    { ISD::SETCC,   MVT::v2i64,   1 },
    { ISD::SETCC,   MVT::v4i32,   1 },
    { ISD::SETCC,   MVT::v8i16,   1 },
    { ISD::SETCC,   MVT::v16i8,   1 },
  };

  static const CostTblEntry<MVT> AVX1CostTbl[] = {
    { ISD::SETCC,   MVT::v4f64,   1 },
    { ISD::SETCC,   MVT::v8f32,   1 },
    // AVX1 does not support 8-wide integer compare.
    { ISD::SETCC,   MVT::v4i64,   4 },
    { ISD::SETCC,   MVT::v8i32,   4 },
    { ISD::SETCC,   MVT::v16i16,  4 },
    { ISD::SETCC,   MVT::v32i8,   4 },
  };

  /*
  static const CostTblEntry<MVT> AVX2CostTbl[] = {
    { ISD::SETCC,   MVT::v4i64,   1 },
    { ISD::SETCC,   MVT::v8i32,   1 },
    { ISD::SETCC,   MVT::v16i16,  1 },
    { ISD::SETCC,   MVT::v32i8,   1 },
  };
  */

  if (ST->hasSSE42()) {
    int Idx = CostTableLookup<MVT>(SSE42CostTbl, array_lengthof(SSE42CostTbl), ISD, MTy);
    if (Idx != -1)
      return LT.first * SSE42CostTbl[Idx].Cost;
  }

  if (ST->hasAVX()) {
    int Idx = CostTableLookup<MVT>(AVX1CostTbl, array_lengthof(AVX1CostTbl), ISD, MTy);
    if (Idx != -1)
      return LT.first * AVX1CostTbl[Idx].Cost;
  }

  /*
  if (ST->hasAVX2()) {
    int Idx = CostTableLookup<MVT>(AVX2CostTbl, array_lengthof(AVX2CostTbl), ISD, MTy);
    if (Idx != -1)
      return LT.first * AVX2CostTbl[Idx].Cost;
  }
  */
  return VTT->getCmpSelInstrCost(Opcode, ValTy, CondTy);
}

unsigned X86CostModel::getVectorInstrCost(unsigned Opcode, Type *Val,
   unsigned Index) const
{
  assert(Val->isVectorTy() && "This must be a vector type");

  if (Index != -1U) {
    // Legalize the type.
    std::pair<unsigned, MVT> LT = VTT->getTypeLegalizationCost(Val);

    // This type is legalized to a scalar type.
    if (!LT.second.isVector())
      return 0;

    // The type may be split. Normalize the index to the new type.
    unsigned Width = LT.second.getVectorNumElements();
    Index = Index % Width;

    // Floating point scalars are already located in index #0.
    if (Val->getScalarType()->isFloatingPointTy() && Index == 0)
      return 0;
  }
  return VTT->getVectorInstrCost(Opcode, Val, Index);
}

unsigned X86CostModel::getMemoryOpCost(unsigned Opcode, Type *Src,
   unsigned Alignment, unsigned AddressSpace) const
{
  // Legalize the type.
  std::pair<unsigned, MVT> LT = VTT->getTypeLegalizationCost(Src);
  assert((Opcode == Instruction::Load || Opcode == Instruction::Store) &&
         "Invalid Opcode");

  // Each load/store unit costs 1.
  unsigned Cost = LT.first * 1;

  // On Sandybridge 256bit load/stores are double pumped
  // (but not on Haswell).
  if (LT.second != MVT::Other && LT.second.getSizeInBits() > 128)
  //if (LT.second.getSizeInBits() > 128 && !ST->hasAVX2())
    Cost*=2;

  return Cost;
}

unsigned X86CostModel::getFunctionCost(Function *F) const {
  if (!F || F->empty()) return 0;

  // 1. 获取当前函数 F 对应的 Subtarget
  //    这会正确处理函数的属性（如 +avx2, -sse 等）
  const TargetSubtargetInfo *STI = TM->getSubtargetImpl(*F);
  
  // 2. 更新 TLI
  TLI = STI->getTargetLowering();

  // 3. 重新创建 VTT (因为它依赖 TLI)
  if (VTT) delete VTT;
  VTT = new VectorTargetTransformStub(TLI);

  // 4. 调用基类的通用逻辑进行计算
  //    此时基类调用的虚函数（如 getMemoryOpCost）会使用上面更新过的 VTT/TLI
  return CostModel::getFunctionCost(F);
}
