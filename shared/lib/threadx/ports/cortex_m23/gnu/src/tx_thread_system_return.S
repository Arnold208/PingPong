/**************************************************************************/
/*                                                                        */
/*       Copyright (c) Microsoft Corporation. All rights reserved.        */
/*                                                                        */
/*       This software is licensed under the Microsoft Software License   */
/*       Terms for Microsoft Azure RTOS. Full text of the license can be  */
/*       found in the LICENSE file at https://aka.ms/AzureRTOS_EULA       */
/*       and in the root directory of this software.                      */
/*                                                                        */
/**************************************************************************/


/**************************************************************************/
/**************************************************************************/
/**                                                                       */
/** ThreadX Component                                                     */
/**                                                                       */
/**   Thread                                                              */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/

#include "tx_user.h"

/**************************************************************************/
/*                                                                        */
/*  FUNCTION                                               RELEASE        */
/*                                                                        */
/*    _tx_thread_system_return                          Cortex-M23/GNU    */
/*                                                           6.x          */
/*  AUTHOR                                                                */
/*                                                                        */
/*    Scott Larson, Microsoft Corporation                                 */
/*                                                                        */
/*  DESCRIPTION                                                           */
/*                                                                        */
/*    This function is target processor specific.  It is used to transfer */
/*    control from a thread back to the ThreadX system.  Only a           */
/*    minimal context is saved since the compiler assumes temp registers  */
/*    are going to get slicked by a function call anyway.                 */
/*                                                                        */
/*  INPUT                                                                 */
/*                                                                        */
/*    None                                                                */
/*                                                                        */
/*  OUTPUT                                                                */
/*                                                                        */
/*    None                                                                */
/*                                                                        */
/*  CALLS                                                                 */
/*                                                                        */
/*    _tx_thread_schedule                   Thread scheduling loop        */
/*                                                                        */
/*  CALLED BY                                                             */
/*                                                                        */
/*    ThreadX components                                                  */
/*                                                                        */
/*  RELEASE HISTORY                                                       */
/*                                                                        */
/*    DATE              NAME                      DESCRIPTION             */
/*                                                                        */
/*  09-30-2020      Scott Larson            Initial Version 6.1           */
/*  xx-xx-xxxx      Scott Larson            Include tx_user.h,            */
/*                                            resulting in version 6.x    */
/*                                                                        */
/**************************************************************************/
// VOID   _tx_thread_system_return(VOID)
// {
    .section .text
    .balign 4
    .syntax unified
    .eabi_attribute Tag_ABI_align_preserved, 1
    .global  _tx_thread_system_return
    .thumb_func
.type _tx_thread_system_return, function
_tx_thread_system_return:
    /* Return to real scheduler via PendSV. Note that this routine is often
       replaced with in-line assembly in tx_port.h to improved performance.  */

    LDR     r0, =0x10000000                         // Load PENDSVSET bit
    LDR     r1, =0xE000ED04                         // Load ICSR address
    STR     r0, [r1]                                // Set PENDSVBIT in ICSR
    MRS     r0, IPSR                                // Pickup IPSR
    CMP     r0, #0                                  // Is it a thread returning?
    BNE     _isr_context                            // If ISR, skip interrupt enable
    MRS     r1, PRIMASK                             // Thread context returning, pickup PRIMASK
    CPSIE   i                                       // Enable interrupts
    MSR     PRIMASK, r1                             // Restore original interrupt posture
_isr_context:
    BX      lr                                      // Return to caller
// }
    .end
