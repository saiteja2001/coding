#include <bits/stdc++.h>
#include <ctime>
#include <omp.h>

using namespace std;

// Parallel reduction to find min value
template<typename T> T parallel_min(const vector<T>& data)
{
    T min_value = data[0];
    #pragma omp parallel for reduction(min:min_value)
    for (int i = 1; i < data.size(); ++i)
        if (data[i] < min_value)
            min_value = data[i];

    return min_value;
}

// Parallel reduction to find max value
template<typename T> T parallel_max(const vector<T>& data)
{
    T max_value = data[0];
    #pragma omp parallel for reduction(max:max_value)
    for (int i = 1; i < data.size(); ++i)
        if (data[i] > max_value)
            max_value = data[i];
    return max_value;
}

// Parallel reduction to find sum
template<typename T> T parallel_sum(const vector<T>& data)
{
    T sum = 0;
    #pragma omp parallel for reduction(+:sum)
    for (int i = 0; i < data.size(); ++i)
        sum += data[i];

    return sum;
}

// Parallel reduction to find average
template<typename T> double parallel_average(const vector<T>& data)
{
    T sum = parallel_sum(data);
    double average = static_cast<double>(sum) / data.size();
    return average;
}

int main() {
    // Ask user for the size of the vector
    int size;
    cout << "Enter the size of the vector: ";
    cin >> size;

    // Ask user for the values of the vector
    vector<int> data(size);
    cout << "Enter the values of the vector:" << endl;
    for (int i = 0; i < size; ++i) {
        cin >> data[i];
    }

    // Find min, max, sum and average using parallel reduction
    auto start_time = chrono::steady_clock::now();

    int min_value = parallel_min(data);
    int max_value = parallel_max(data);
    int sum = parallel_sum(data);
    double average = parallel_average(data);

    auto end_time = chrono::steady_clock::now();

    // Print results and timing information
    cout << "Min value: " << min_value << endl;
    cout << "Max value: " << max_value << endl;
    cout << "Sum: " << sum << endl;
    cout << "Average: " << average << endl;
    auto duration_ms = chrono::duration_cast<chrono::milliseconds>(end_time - start_time);
    cout << "Time taken: " << duration_ms.count() << "ms" << endl;

    return 0;
}
