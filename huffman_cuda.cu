#include <stdio.h>

// Huffman Node Structure
struct Node {
    unsigned char data;
    unsigned frequency;
    Node *left, *right;
};

// Kernel function to calculate frequencies
__global__ void calculateFrequencies(const unsigned char* data, unsigned int* frequencies, int size) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx < size)
        atomicAdd(&frequencies[data[idx]], 1);
}

// Helper function to create a new node
Node* createNode(unsigned char data, unsigned frequency, Node* left, Node* right) {
    Node* node = new Node;
    node->data = data;
    node->frequency = frequency;
    node->left = left;
    node->right = right;
    return node;
}

// Comparison function for sorting nodes based on frequency
int compareNodes(const void* a, const void* b) {
    Node** nodeA = (Node**)a;
    Node** nodeB = (Node**)b;
    return (*nodeA)->frequency - (*nodeB)->frequency;
}

// Build Huffman tree and generate codes
void buildHuffmanTree(Node** nodes, int size) {
    while (size > 1) {
        Node* left = nodes[0];
        Node* right = nodes[1];
        Node* parent = createNode(0, left->frequency + right->frequency, left, right);

        nodes[0] = parent;
        for (int i = 1; i < size - 1; ++i)
            nodes[i] = nodes[i + 1];
        nodes[size - 1] = nullptr;
        --size;

        qsort(nodes, size, sizeof(Node*), compareNodes);
    }
}

// Recursive function to generate Huffman codes
void generateHuffmanCodes(Node* root, unsigned int code, unsigned int codeLength, unsigned int* codes) {
    if (root->left) {
        generateHuffmanCodes(root->left, code << 1, codeLength + 1, codes);
    }
    if (root->right) {
        generateHuffmanCodes(root->right, (code << 1) | 1, codeLength + 1, codes);
    }
    if (!root->left && !root->right) {
        codes[root->data] = code << (32 - codeLength);
    }
}

// Huffman encoding function
void huffmanEncode(const unsigned char* data, int size, unsigned int* codes) {
    const int alphabetSize = 256;

    // Initialize frequencies to 0
    unsigned int* frequencies;
    cudaMallocManaged(&frequencies, alphabetSize * sizeof(unsigned int));
    cudaMemset(frequencies, 0, alphabetSize * sizeof(unsigned int));

    // Calculate frequencies
    const int threadsPerBlock = 256;
    const int blocksPerGrid = (size + threadsPerBlock - 1) / threadsPerBlock;
    calculateFrequencies<<<blocksPerGrid, threadsPerBlock>>>(data, frequencies, size);
    cudaDeviceSynchronize();

    // Create nodes for each symbol with non-zero frequency
    Node** nodes = new Node*[alphabetSize];
    int nodeCount = 0;
    for (int i = 0; i < alphabetSize; ++i) {
        if (frequencies[i] > 0) {
            nodes[nodeCount++] = createNode(i, frequencies[i], nullptr, nullptr);
        }
    }

    // Sort nodes based on frequency
    qsort(nodes, nodeCount, sizeof(Node*), compareNodes);

    // Build Huffman tree
    buildHuffman
