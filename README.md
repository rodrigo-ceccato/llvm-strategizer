# LLVM Strategizer

This repository contains the LLVM Strategizer project, which is built using GCC 7.5.0 and Ninja. Follow the steps below to set up, build, and use the project.

## Prerequisites

- GCC 7.5.0
- Ninja
- Git

## Clone the Repository

```bash
git clone https://github.com/rodrigo-ceccato/llvm-strategizer.git llvm-strategizer
cd llvm-strategizer
```

## Build LLVM and Clang

Before building LLVM Strategizer, you need to build LLVM and Clang with the required configurations. Make sure to replace $llvm_install_dir with your desired installation directory.

```bash
export llvm_install_dir=...

mkdir build
cd build
cmake -S../llvm-strategizer/llvm -B./build -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$llvm_install_dir -DLLVM_ENABLE_PROJECTS=clang-tools-extra;clang;compiler-rt -DLLVM_ENABLE_RUNTIMES=libcxx;openmp;libcxxabi -DLLVM_TARGETS_TO_BUILD=X86\;AMDGPU\;nvvptx -DCLANG_VENDOR=auto-strategizer -DLIBOMPTARGET_ENABLE_DEBUG=1 -DLLVM_ENABLE_ASSERTIONS=On -DCMAKE_EXPORT_COMPILE_COMMANDS=On -DLLVM_INCLUDE_BENCHMARKS=Off -DLIBOMPTARGET_ENABLE_PROFILER=1 -DOPENMP_STANDALONE_BUILD=0 -DBUILD_SHARED_LIBS=1 -DLLVM_USE_SPLIT_DWARF=1
```

## Build LLVM Strategizer

Once LLVM and Clang are built, you can build LLVM Strategizer using the following commands:

```bash
cmake --build ./build -j 129
```

This will compile the LLVM Strategizer project.

## Installation

You can install LLVM Strategizer as follows:

```bash
cmake --install ./build --prefix $llvm_install_dir
```

## Environment Variables

Before using LLVM Strategizer, set the following environment variables:

```bash
export LIBOMPTARGET_MEMORY_MANAGER_THRESHOLD=0 # Disable memory manager
export LIBOMPTARGET_STRATEGIZER_MIN_SIZE=1
export LIBOMPTARGET_USE_STRATEGIZER=1
export LIBOMPTARGET_STRATEGIZER_TOPO="topo_smx"
export LIBOMPTARGET_STRATEGIZER_STRATEGY="DVT"
export PAYLOAD_SIZE=8000
export OMP_PROC_BIND=spread
export OMP_NUM_THREADS=22
export OMP_PLACES=cores
```

## Running a test

To run a test with LLVM Strategizer, use the following command:

```bash
clang -g -fuse-ld=lld -fopenmp -fopenmp-targets=nvptx64 -O2 -fno-omit-frame-pointer -fno-optimize-sibling-calls -fopenmp-target-debug=3 -o test.out $source_file
```

To display the whole command output and capture the output in a log file, use the following commands:

```bash
start_time=$(date +%s.%3N)
output=$(taskset -c 0-21 ./test.out 2>&1)
exit_code=$?
end_time=$(date +%s.%3N)
execution_time=$(echo "$end_time - $start_time" | bc)

echo "$output" > test.out.log
echo "$output"
```
