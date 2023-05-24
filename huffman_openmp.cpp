#include <iostream>
#include <queue>
#include <unordered_map>
#include <omp.h>

using namespace std;

// Define a node in the Huffman tree
struct HuffNode {
    char data;
    int freq;
    HuffNode* left;
    HuffNode* right;

    // Constructor
    HuffNode(char data, int freq) {
        this->data = data;
        this->freq = freq;
        left = right = NULL;
    }
};

// Compare two HuffNodes based on their frequency
struct CompareFreq {
    bool operator()(HuffNode* a, HuffNode* b) {
        return a->freq > b->freq;
    }
};

// Traverse the Huffman tree and generate codes for each character
void traverse_huffman_tree(HuffNode* root, string code, unordered_map<char, string>& codes) {
    if (root->left == NULL && root->right == NULL) {
        codes[root->data] = code;
    } else {
        traverse_huffman_tree(root->left, code + "0", codes);
        traverse_huffman_tree(root->right, code + "1", codes);
    }
}

// Perform parallel Huffman encoding
string parallel_huffman_encoding(string data) {
    int num_threads = omp_get_max_threads();

    // Create a frequency map for each thread
    vector<unordered_map<char, int>> freq_maps(num_threads);

    // Count the frequency of each character in parallel
    #pragma omp parallel for
    for (int i = 0; i < data.size(); i++) {
        int tid = omp_get_thread_num();
        freq_maps[tid][data[i]]++;
    }

    // Combine the frequency maps from all threads
    unordered_map<char, int> freq_map;
    for (int i = 0; i < num_threads; i++) {
        for (auto p : freq_maps[i]) {
            freq_map[p.first] += p.second;
        }
    }

    // Create a priority queue of HuffNodes based on their frequency
    priority_queue<HuffNode*, vector<HuffNode*>, CompareFreq> pq;
    for (auto p : freq_map) {
        pq.push(new HuffNode(p.first, p.second));
    }

    // Build the Huffman tree in parallel
    while (pq.size() > 1) {
        HuffNode* left = pq.top();
        pq.pop();
        HuffNode* right = pq.top();
        pq.pop();

        int sum_freq = left->freq + right->freq;
        HuffNode* parent = new HuffNode('\0', sum_freq);
        parent->left = left;
        parent->right = right;

        pq.push(parent);
    }

    // Traverse the Huffman tree to generate codes for each character
    unordered_map<char, string> codes;
    traverse_huffman_tree(pq.top(), "", codes);

    // Encode the data in parallel
    string encoded_data = "";
    for (int i = 0; i < data.size(); i++) {
        encoded_data += codes[data[i]];
    }

    return encoded_data;
}

int main() {
    string data = "Hello, world!";
    string encoded_data = parallel_huffman_encoding(data);

    cout << "Original data: " << data << endl;
    cout << "Encoded data: " << encoded_data << endl;

    return 0;
}
