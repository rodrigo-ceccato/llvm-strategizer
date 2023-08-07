

#ifndef STRATEGIZER_INTERFACE_H
#define STRATEGIZER_INTERFACE_H

#include "omptarget.h"
#include <assert.h>
#include "private.h"


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
// typedef int kmp_int32;

// typedef kmp_int32 (*kmp_routine_entry_t)(kmp_int32, void *);

typedef union kmp_cmplrdata {
  kmp_int32 priority; /**< priority specified by user for the task */
  kmp_routine_entry_t
      destructors; /* pointer to function to invoke deconstructors of
                      firstprivate C++ objects */
  /* future data */
} kmp_cmplrdata_t;

// typedef struct kmp_task { /* GEH: Shouldn't this be aligned somehow? */
//   void *shareds; /**< pointer to block of pointers to shared vars   */
//   kmp_routine_entry_t
//       routine; /**< pointer to routine to call for executing task */
//   kmp_int32 part_id; /**< part id for the task                          */
//   kmp_cmplrdata_t
//       data1; /* Two known optional additions: destructors and priority */
//   kmp_cmplrdata_t data2; /* Process destructors first, priority second */
//   /* future data */
//   /*  private vars  */
// } kmp_task_t;

typedef char kmp_int8;
typedef unsigned char kmp_uint8;

// typedef struct kmp_depend_info {
//   kmp_intptr_t base_addr;
//   size_t len;
//   union {
//     kmp_uint8 flag; // flag as an unsigned char
//     struct { // flag as a set of 8 bits
//       unsigned in : 1;
//       unsigned out : 1;
//       unsigned mtx : 1;
//       unsigned set : 1;
//       unsigned unused : 3;
//       unsigned all : 1;
//     } flags;
//   };
// } kmp_depend_info_t;

int __kmpc_omp_taskwait(ident_t *loc_ref, kmp_int32 gtid) __attribute__((weak));


kmp_int32 __kmpc_omp_task_with_deps(
    ident_t *loc_ref, kmp_int32 gtid, kmp_task_t *new_task, kmp_int32 ndeps,
    kmp_depend_info_t *dep_list, kmp_int32 ndeps_noalias,
    kmp_depend_info_t *noalias_dep_list) __attribute__((weak));

#ifdef __cplusplus
} // extern "C"
#endif

#endif