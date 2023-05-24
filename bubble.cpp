#include <stdio.h>
#include <omp.h>
#include <bits/stdc++.h>
using namespace std;
void bubble_sort(int arr[], int n) {
    int i, j;
    for (i = 0; i < n - 1; i++) {
        if (i % 2 == 0) {
            #pragma omp parallel for shared(arr)
            for (j = 0; j < n - 1; j += 2) {
                if (arr[j] > arr[j+1]) {

	                cout<<"Even pass: swapping id: "<< j << " and " << j+1<<endl;
                    int temp = arr[j];
                    arr[j] = arr[j+1];
                    arr[j+1] = temp;

	     
                }
            }
	cout<<"Array after even pass: \n";
            for(int i=0;i<n;i++)
		cout<<arr[i]<<" ";
	cout<<endl;
        }
        else {
            #pragma omp parallel for shared(arr)
            for (j = 1; j < n - 1; j += 2) {
                if (arr[j] > arr[j+1]) {
	        cout<<"Odd pass: swapping id: "<< j << " and " << j+1<<endl;
                    int temp = arr[j];
                    arr[j] = arr[j+1];
                    arr[j+1] = temp;
                }
            }
	cout<<"Array after odd pass: \n";
            for(int i=0;i<n;i++)
		cout<<arr[i]<<" ";
	cout<<endl;
        }
    }
}

int main() {
    int arr[] = {64, 34, 25, 12, 22, 11, 90};
    int n = sizeof(arr) / sizeof(arr[0]);

    bubble_sort(arr, n);

    printf("Sorted array: ");
    for (int i = 0; i < n; i++)
        printf("%d ", arr[i]);
    printf("\n");

    return 0;
}
