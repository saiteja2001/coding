#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>

using namespace std;

__global__ void vector_add(int *a, int *b, int *c, int n) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if (i < n) {
        c[i] = a[i] + b[i];
    }
}

int main() {
    const int n = 100;  // Length of vectors
    std::vector<int> a(n), b(n), c(n);

    // Initialize vectors with random values
    std::srand(std::time(nullptr));
    for (int i = 0; i < n; ++i) {
        a[i] = std::rand() % 100;
        b[i] = std::rand() % 100;
    }

    // Allocate memory on device
    int *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, n * sizeof(int));
    cudaMalloc(&d_b, n * sizeof(int));
    cudaMalloc(&d_c, n * sizeof(int));

    // Copy input data from host to device
    cudaMemcpy(d_a, a.data(), n * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b.data(), n * sizeof(int), cudaMemcpyHostToDevice);

    // Launch kernel
    const int block_size = 256;
    const int num_blocks = (n + block_size - 1) / block_size;
    vector_add<<<num_blocks, block_size>>>(d_a, d_b, d_c, n);

    // Copy output data from device to host
    cudaMemcpy(c.data(), d_c, n * sizeof(int), cudaMemcpyDeviceToHost);

    // Free memory on device
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // Print results
    std::cout << "Vector a: ";
    for (int i = 0; i < n; ++i) {
        std::cout << a[i] << " ";
    }
    std::cout << std::endl;

    std::cout << "Vector b: ";
    for (int i = 0; i < n; ++i) {
        std::cout << b[i] << " ";
    }
    std::cout << std::endl;

    std::cout << "Vector c: ";
    for (int i = 0; i < n; ++i) {
        std::cout << c[i] << " ";
    }
    std::cout << std::endl;

    return 0;
}

