#!/bin/zsh

target_successful_executions=10

module load cuda

source_file=offload.c
llvm_build_dir=/home/rdefreitas/llvm/llvm-builds/builds/llvm-project/release
llvm_install_dir=/home/rdefreitas/llvm/llvm-builds/installs/auto-strategizer/release

# Set LLVM path
# ============================================
echo "Setting local LLVM path..."
# workaround for libffi in JLSE
export LD_LIBRARY_PATH=/home/rdefreitas/spack/opt/spack/linux-opensuse15-x86_64_v3/gcc-7.5.0/libffi-3.4.4-7h3jlfsirwvjniclthwijc5cek5ysjse/lib64/:$LD_LIBRARY_PATH
export LIBRARY_PATH=/home/rdefreitas/spack/opt/spack/linux-opensuse15-x86_64_v3/gcc-7.5.0/libffi-3.4.4-7h3jlfsirwvjniclthwijc5cek5ysjse/lib64/:$LIBRARY_PATH
export LIBRARY_PATH=/home/rdefreitas/spack/opt/spack/linux-opensuse15-skylake_avx512/gcc-7.5.0/libffi-3.4.4-kiyiuobe6h7uxi2ncui2gpojwyejq24l/lib64/:$LIBRaRY_PATH

export PATH=$llvm_install_dir/bin/:$PATH
export LD_LIBRARY_PATH=$llvm_install_dir/lib/:$LD_LIBRARY_PATH
export LIBRARY_PATH=$llvm_install_dir/lib/:$LIBRARY_PATH

# Common environment variables
export LIBOMPTARGET_MEMORY_MANAGER_THRESHOLD=0 # disable memory manager
export LIBOMPTARGET_STRATEGIZER_MIN_SIZE=1
export LIBOMPTARGET_STRATEGIZER_TOPO="topo_smx"
unset OMP_PROC_BIND
unset OMP_NUM_THREADS
unset OMP_PLACES

# remove binary if it exists
if [ -f test.out ]; then
    rm test.out
fi
clang -fuse-ld=lld -fopenmp -fopenmp-targets=nvptx64 -O2 -o test.out $source_file

echo " " >benchmark_results.txt

# Loop over LIBOMPTARGET_USE_STRATEGIZER values (0 and 1)
for use_strategizer in 1 0; do
    # Set the environment variable
    export LIBOMPTARGET_USE_STRATEGIZER=$use_strategizer

    # Loop over payload_size values
    for payload_size in 0.2 2 20 200 2000 6000 8000; do
        # Set the payload_size environment variable
        export PAYLOAD_SIZE=$payload_size

        # Loop over LIBOMPTARGET_STRATEGIZER_STRATEGY values if LIBOMPTARGET_USE_STRATEGIZER is 1
        if [ "$use_strategizer" -eq 1 ]; then
            for strategy in DVT MXF P2P; do
                # Print the this strategy and payload_size
                echo "Strategy: $strategy, Payload Size: $payload_size"
                # Set the additional environment variable
                export LIBOMPTARGET_STRATEGIZER_STRATEGY=$strategy

                # Execute the command until target_successful_executions is reached
                successful_executions=0
                while [ "$successful_executions" -lt "$target_successful_executions" ]; do
                    start_time=$(date +%s.%3N)
                    output=$(./test.out 2>&1)
                    exit_code=$?
                    end_time=$(date +%s.%3N)
                    execution_time=$(echo "$end_time - $start_time" | bc)
                    data_time=$(echo $output | cut -d ' ' -f 2)

                    if [ "$exit_code" -eq 0 ]; then
                        ((successful_executions++))
                        echo "$execution_time,$data_time,$PAYLOAD_SIZE,$LIBOMPTARGET_USE_STRATEGIZER,$LIBOMPTARGET_STRATEGIZER_STRATEGY,$LIBOMPTARGET_STRATEGIZER_TOPO,$LIBOMPTARGET_STRATEGIZER_MIN_SIZE,$exit_code"
                        echo "$execution_time,$data_time,$PAYLOAD_SIZE,$LIBOMPTARGET_USE_STRATEGIZER,$LIBOMPTARGET_STRATEGIZER_STRATEGY,$LIBOMPTARGET_STRATEGIZER_TOPO,$LIBOMPTARGET_STRATEGIZER_MIN_SIZE,$exit_code" >>benchmark_results.txt
                    fi
                done

            done
        else
            # Execute the command until target_successful_executions is reached
            # Print the this strategy and payload_size
            echo "Strategy: BASELINE, Payload Size: $payload_size"
            successful_executions=0
            while [ "$successful_executions" -lt "$target_successful_executions" ]; do
                start_time=$(date +%s.%3N)
                output=$(./test.out 2>&1)
                exit_code=$?
                end_time=$(date +%s.%3N)
                execution_time=$(echo "$end_time - $start_time" | bc)
                data_time=$(echo $output | cut -d ' ' -f 2)

                if [ "$exit_code" -eq 0 ]; then
                    ((successful_executions++))
                    echo "$execution_time,$data_time,$PAYLOAD_SIZE,$LIBOMPTARGET_USE_STRATEGIZER,$LIBOMPTARGET_STRATEGIZER_STRATEGY,$LIBOMPTARGET_STRATEGIZER_TOPO,$LIBOMPTARGET_STRATEGIZER_MIN_SIZE,$exit_code"
                    echo "$execution_time,$data_time,$PAYLOAD_SIZE,$LIBOMPTARGET_USE_STRATEGIZER,$LIBOMPTARGET_STRATEGIZER_STRATEGY,$LIBOMPTARGET_STRATEGIZER_TOPO,$LIBOMPTARGET_STRATEGIZER_MIN_SIZE,$exit_code" >>benchmark_results.txt
                fi
            done
        fi
    done
done
