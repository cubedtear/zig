/*
 * Copyright (c) 2016 Andrew Kelley
 *
 * This file is part of zig, which is MIT licensed.
 * See http://opensource.org/licenses/MIT
 */

#ifndef ZIG_IR_HPP
#define ZIG_IR_HPP

#include "all_types.hpp"

IrInstruction *ir_gen(CodeGen *g, AstNode *node, BlockContext *scope, IrExecutable *ir_executable);
IrInstruction *ir_gen_fn(CodeGen *g, FnTableEntry *fn_entry);

TypeTableEntry *ir_analyze(CodeGen *g, IrExecutable *old_executable, IrExecutable *new_executable,
        TypeTableEntry *expected_type, AstNode *expected_type_source_node);

IrInstruction *ir_exec_const_result(IrExecutable *exec);

bool ir_has_side_effects(IrInstruction *instruction);
ConstExprValue *const_ptr_pointee(ConstExprValue *const_val);

#endif