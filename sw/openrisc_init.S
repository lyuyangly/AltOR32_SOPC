/* Start Code for OpenRISC 1200 */

#include "openrisc.h"

.global _main
.global _reset

.section .text, "ax"

#-------------------------------------------------------------
# Context Stack Frame - 140 bytes / 35 words
#-------------------------------------------------------------
#   0: R0
#   4: R1 (SP)
#   8: R2
#  12: R3 (ARG0)
#  16: R4
#  20: R5
#  24: R6
#  28: R7
#  32: R8
#  36: R9 (LR)
#  40: R10
#  44: R11
#  48: R12
#  52: R13
#  56: R14
#  60: R15
#  64: R16
#  68: R17
#  72: R18
#  76: R19
#  80: R20
#  84: R21
#  88: R22
#  92: R23
#  96: R24
# 100: R25
# 104: R26
# 108: R27
# 112: R28
# 116: R29
# 120: R30
# 124: R31
# 128: X
# 132: EPC
# 136: ESR
#-------------------------------------------------------------

#-------------------------------------------------------------
# asm_save_context:
#-------------------------------------------------------------
.macro asm_save_context

    l.nop
    l.nop

    # Adjust SP (frame size is 140 + allow for 128 uncommitted in-use stack)
    l.addi  r1, r1, -268

    # Save register file to stack
    l.sw 124(r1), r31
    l.sw 120(r1), r30
    l.sw 116(r1), r29
    l.sw 112(r1), r28
    l.sw 108(r1), r27
    l.sw 104(r1), r26
    l.sw 100(r1), r25
    l.sw 96(r1),  r24
    l.sw 92(r1),  r23
    l.sw 88(r1),  r22
    l.sw 84(r1),  r21
    l.sw 80(r1),  r20
    l.sw 76(r1),  r19
    l.sw 72(r1),  r18
    l.sw 68(r1),  r17
    l.sw 64(r1),  r16
    l.sw 60(r1),  r15
    l.sw 56(r1),  r14
    l.sw 52(r1),  r13
    l.sw 48(r1),  r12
    l.sw 44(r1),  r11
    l.sw 40(r1),  r10
    l.sw 36(r1),  r9
    l.sw 32(r1),  r8
    l.sw 28(r1),  r7
    l.sw 24(r1),  r6
    l.sw 20(r1),  r5
    l.sw 16(r1),  r4
    l.sw 12(r1),  r3
    l.sw 8(r1),   r2
    l.sw 0(r1),   r0

    # R10 = EPC
    l.mfspr r10, r0, 32
    l.sw 132(r1),  r10

    # R10 = ESR
    l.mfspr r10, r0, 64
    l.sw 136(r1),  r10

    # Stack pointer (R1)
    l.or   r10, r0,  r1
    l.addi r10, r10, +268
    l.sw 4(r1), r10

.endm

#-------------------------------------------------------------
# asm_load_context:
#-------------------------------------------------------------
.macro asm_load_context

    # Restore EPC (PC of non-exception code)
    l.lwz r10, 132(r1)

    # EPC = R10
    l.mtspr r0,r10,32

    # Restore ESR (SR of non-exception code)
    l.lwz r10, 136(r1)

    # ESR = R10
    l.mtspr r0,r10,64

    # Restore register set
    # r1/r1 already set
    l.lwz r2,   8(r1)
    l.lwz r3,  12(r1)
    l.lwz r4,  16(r1)
    l.lwz r5,  20(r1)
    l.lwz r6,  24(r1)
    l.lwz r7,  28(r1)
    l.lwz r8,  32(r1)
    l.lwz r9,  36(r1)
    l.lwz r10, 40(r1)
    l.lwz r11, 44(r1)
    l.lwz r12, 48(r1)
    l.lwz r13, 52(r1)
    l.lwz r14, 56(r1)
    l.lwz r15, 60(r1)
    l.lwz r16, 64(r1)
    l.lwz r17, 68(r1)
    l.lwz r18, 72(r1)
    l.lwz r19, 76(r1)
    l.lwz r20, 80(r1)
    l.lwz r21, 84(r1)
    l.lwz r22, 88(r1)
    l.lwz r23, 92(r1)
    l.lwz r24, 96(r1)
    l.lwz r25,100(r1)
    l.lwz r26,104(r1)
    l.lwz r27,108(r1)
    l.lwz r28,112(r1)
    l.lwz r29,116(r1)
    l.lwz r30,120(r1)
    l.lwz r31,124(r1)

    # Adjust SP past register set
    l.addi  r1, r1, +268

    # Return from interrupt (to restore PC & SR)
    l.rfe
    l.nop

.endm


#-------------------------------------------------------------
# VECTOR 0x0 - Reset Boot
#-------------------------------------------------------------
.org    0x0
_reset:
    l.j vector_reset
    l.nop

.size _reset, .-_reset

#-------------------------------------------------------------
# VECTOR 0x100 - Reset
#-------------------------------------------------------------
.org    0x100
vector_reset:
    # Setup SP (R1)
    l.movhi r4,hi(__stack_pointer);
    l.ori r1,r4,lo(__stack_pointer);

    # R4 = _bss_start
    l.movhi r4,hi(__bss_start);
    l.ori r4,r4,lo(__bss_start);

    # R5 = _bss_end
    l.movhi r5,hi(__bss_end);
    l.ori r5,r5,lo(__bss_end);

BSS_CLEAR:
    l.sw 0x0(r4),r0         # Write 0x00 to mem[r4]
    l.sfleu r4,r5           # SR[F] = (r4 < r5)
    l.addi r4, r4, 4        # r4 += 4
    l.bf  BSS_CLEAR         # If SR[F] == 0, jump to BSS_CLEAR
    l.nop

    # Jump to debug agent
    l.j _main
    l.nop

.size vector_reset, .-vector_reset

#-------------------------------------------------------------
# VECTOR 0x200 - Fault / Illegal Instruction
#-------------------------------------------------------------
.org    0x200
vector_fault:

    # Save context
    asm_save_context

    # Arg 2 = Fault
    l.addi r4, r0, 1

    l.j handle_exception
    l.nop

.size vector_fault, .-vector_fault

#-------------------------------------------------------------
# VECTOR 0x300 - External Interrupt
#-------------------------------------------------------------
.org    0x300
vector_extint:

    # Save context
    asm_save_context

    # Arg 2 = Ext Int
    l.addi r4, r0, 2

    l.j handle_exception
    l.nop

.size vector_extint, .-vector_extint

#-------------------------------------------------------------
# VECTOR 0x400 - Syscall
#-------------------------------------------------------------
.org    0x400
vector_syscall:

    # Save context
    asm_save_context

    # Arg 2 = Syscall
    l.addi r4, r0, 3

    l.j handle_exception
    l.nop

.size vector_syscall, .-vector_syscall

#-------------------------------------------------------------
# VECTOR 0x600 - Trap
#-------------------------------------------------------------
.org    0x600
vector_trap:

    # Save context
    asm_save_context

    # Arg 2 = Trap
    l.addi r4, r0, 4

    # Fall through...

.size vector_trap, .-vector_trap

#-------------------------------------------------------------
# handle_exception: Common exception handling code
#-------------------------------------------------------------
handle_exception:
    # Copy stack pointer to arg1
    # l.add r3, r0, r1

    # Jump to handler
    # l.movhi r10,hi(0x0);
    # l.ori r10,r10,lo(0x0);
    # l.jalr r10
    l.nop

    # Return value is stack pointer
    # l.add r1, r0, r11

    # Restore context
    asm_load_context

.size   handle_exception, .-handle_exception

