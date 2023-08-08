

#ifndef STRATEGIZER_INTERFACE_H
#define STRATEGIZER_INTERFACE_H

#include "omptarget.h"
#include <assert.h>
#include "private.h"

inline int test(int a, int b){
    printf("Call to test\n");
    return a + b;
}

// Implemented in libomp, keep in sync with kmp.h
#ifdef __cplusplus
extern "C" {
#endif

// TODO: check if we need this definition here
typedef union kmp_cmplrdata {
  kmp_int32 priority; /**< priority specified by user for the task */
  kmp_routine_entry_t
      destructors; /* pointer to function to invoke deconstructors of
                      firstprivate C++ objects */
  /* future data */
} kmp_cmplrdata_t;

// TODO: check if we need this definition here
typedef char kmp_int8;
// TODO: check if we need this definition here
typedef unsigned char kmp_uint8;

int __kmpc_omp_taskwait(ident_t *loc_ref, kmp_int32 gtid) __attribute__((weak));

kmp_int32 __kmpc_omp_task_with_deps(
    ident_t *loc_ref, kmp_int32 gtid, kmp_task_t *new_task, kmp_int32 ndeps,
    kmp_depend_info_t *dep_list, kmp_int32 ndeps_noalias,
    kmp_depend_info_t *noalias_dep_list) __attribute__((weak));

#ifdef __cplusplus
} // extern "C"
#endif

#endif