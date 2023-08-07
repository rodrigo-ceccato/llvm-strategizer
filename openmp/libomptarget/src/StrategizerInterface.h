

#ifndef STRATEGIZER_INTERFACE_H
#define STRATEGIZER_INTERFACE_H

#include "omptarget.h"
#include <assert.h>


inline int test(int a, int b){
    printf("Call to test\n");
    return a + b;
}
// Implemented in libomp, they are called from within __tgt_* functions.
#ifdef __cplusplus
extern "C" {
#endif
/*!
 * The ident structure that describes a source location.
 * The struct is identical to the one in the kmp.h file.
 * We maintain the same data structure for compatibility.
 */
typedef int kmp_int32;

int __kmpc_omp_taskwait(ident_t *loc_ref, kmp_int32 gtid) __attribute__((weak));

#ifdef __cplusplus
}
#endif

#endif