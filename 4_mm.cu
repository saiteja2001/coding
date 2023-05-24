#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <ctime>

#define TILE_WIDTH 32

__global__ void matrixMult(int *a, int *b, int *c, int n)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < n && col < n) {
        int sum = 0;
        for (int i = 0; i < n; ++i) {
            sum += a[row * n + i] * b[i * n + col];
        }
        c[row * n + col] = sum;
    }
}

int main()
{
    int n;
    n=4;

    // allocate memory for matrices on host
    int *a = new int[n * n];
    int *b = new int[n * n];
    int *c = new int[n * n];

    // initialize matrices with random values
    std::srand(std::time(0));
    for (int i = 0; i < n * n; ++i) {
        a[i] = std::rand() % 10;
        b[i] = std::rand() % 10;
    }

    // allocate memory for matrices on device
    int *dev_a, *dev_b, *dev_c;
    cudaMalloc(&dev_a, n * n * sizeof(int));
    cudaMalloc(&dev_b, n * n * sizeof(int));
    cudaMalloc(&dev_c, n * n * sizeof(int));

    // copy matrices from host to device
    cudaMemcpy(dev_a, a, n * n * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, n * n * sizeof(int), cudaMemcpyHostToDevice);

    // launch kernel
    dim3 dimGrid((n - 1) / TILE_WIDTH + 1, (n - 1) / TILE_WIDTH + 1, 1);
    dim3 dimBlock(TILE_WIDTH, TILE_WIDTH, 1);
    matrixMult<<<dimGrid, dimBlock>>>(dev_a, dev_b, dev_c, n);

    // copy result matrix from device to host
    cudaMemcpy(c, dev_c, n * n * sizeof(int), cudaMemcpyDeviceToHost);

    // print result matrix
 std::cout << "Result matrix:\n";
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            std::cout << a[i * n + j] << " ";
        }
        std::cout << "\n";
    }
 std::cout << "Result matrix:\n";
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            std::cout << b[i * n + j] << " ";
        }
        std::cout << "\n";
    }
    std::cout << "Result matrix:\n";
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            std::cout << c[i * n + j] << " ";
        }
        std::cout << "\n";
    }

    // free memory on device
    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);

    // free memory on host
    delete[] a;
    delete[] b;
    delete[] c;

    return 0;
}
