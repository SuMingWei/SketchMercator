#ifndef PRIORITY_QUEUE_H
#define PRIORITY_QUEUE_H

#include <iostream>
#include <queue>
#include <vector>
#include <unordered_map>

#include <stdio.h>
#include <stdlib.h>
#include "stdint.h"

#include "params.h"
#include "pcap_helper.h"
#include "flowkey.h"

using namespace std;

// 210204 Hun Namkung
// You need to maintain minheap and hashmap to store topk results by O(logK) per packet
// https://stackoverflow.com/questions/53095013/store-top-k-results-from-count-min-sketch


class PriorityQueue {
public:
    int topk;
    int size;
    pair<flowkey_t, int>* min_heap; // <flowkey, estimate>
    unordered_map<flowkey_t, pair<int, int>, MyHashFunction> hashmap; // <flowkey, <position in min_heap, estimate>>

    PriorityQueue();
    PriorityQueue(int _topk);
    void clear();

    void update(flowkey_t flowkey, int estimate, int isPrint);
    int heap_size();
    int is_full();
    int get_min();
    void swap(int position_1, int position_2);
    int min_heap_bubble_up_or_bubble_down(int position);

};

#endif //SKETCHING_EXAMPLES_PRIORITY_QUEUE_H
