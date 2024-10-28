#include <stdio.h>
#include <cuda.h>

__global__ void writeSharedMemorySame() {
    __shared__ int shared_data[256];
    shared_data[0] = -1;
    // 所有线程写入同一位置
    if (shared_data[0] < 0) {
        shared_data[0] = threadIdx.x;
    }
    __syncthreads(); // 确保所有线程完成写入
}

__global__ void writeSharedMemoryDifferent() {
    __shared__ int shared_data[256]; // 假设最大线程数为256

    // 每个线程写入不同位置
    shared_data[threadIdx.x] = threadIdx.x;
    __syncthreads(); // 确保所有线程完成写入
}

int main() {
    const int blockSize = 256; // 线程块大小
    const int numBlocks = 1 << 20;   // 线程块数量

    // 记录时间
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // 测试不同位置
    cudaEventRecord(start);
    for (int i = 0; i < 1 << 26; ++i)
        writeSharedMemoryDifferent<<<numBlocks, blockSize>>>();
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float elapsedTimeDifferent;
    cudaEventElapsedTime(&elapsedTimeDifferent, start, stop);

    // 测试相同位置
    cudaEventRecord(start);
    for (int i = 0; i < 1 << 26; ++i)
        writeSharedMemorySame<<<numBlocks, blockSize>>>();
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float elapsedTimeSame;
    cudaEventElapsedTime(&elapsedTimeSame, start, stop);

    // 输出结果
    printf("Time for same position: %f ms\n", elapsedTimeSame);
    printf("Time for different positions: %f ms\n", elapsedTimeDifferent);

    // 清理资源
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
