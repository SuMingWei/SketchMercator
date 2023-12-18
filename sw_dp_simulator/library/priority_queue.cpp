#include "priority_queue.h"

PriorityQueue::PriorityQueue()
{
}

PriorityQueue::PriorityQueue(int _topk)
{
    topk = _topk;
    size = 0;
    min_heap = new pair<flowkey_t, int>[topk*3];
    for(int i=0; i<topk*3; i++) {
        flowkey_t flowkey;
        flowkey.src_addr = 0;
        flowkey.src_port = 0;
        flowkey.dst_addr = 0;
        flowkey.dst_port = 0;
        flowkey.proto = 0;
        min_heap[i] = make_pair(flowkey, 0);
    }
}

void PriorityQueue::clear()
{
    size = 0;
    for(int i=0; i<topk*3; i++) {
        flowkey_t flowkey;
        flowkey.src_addr = 0;
        flowkey.src_port = 0;
        flowkey.dst_addr = 0;
        flowkey.dst_port = 0;
        flowkey.proto = 0;
        min_heap[i] = make_pair(flowkey, 0);
    }
    hashmap.clear();
}

int PriorityQueue::heap_size()
{
    return size;
}

int PriorityQueue::is_full()
{
    return size == topk;
}

int PriorityQueue::get_min()
{
    return min_heap[1].second;
}

void PriorityQueue::swap(int position_1, int position_2)
{
    flowkey_t flowkey1 = min_heap[position_1].first;
    flowkey_t flowkey2 = min_heap[position_2].first;
    hashmap[flowkey1].first = position_2;
    hashmap[flowkey2].first = position_1;

    pair<flowkey_t, int> temp = min_heap[position_1];
    min_heap[position_1] = min_heap[position_2];
    min_heap[position_2] = temp;
}

int PriorityQueue::min_heap_bubble_up_or_bubble_down(int position)
{
    int parent = position / 2;

    // bubble up
    if(min_heap[parent].second > min_heap[position].second) {
        while(1) {
            if(min_heap[parent].second <= min_heap[position].second)
                break;
            if(position == 1)
                break;
            swap(parent, position);

            position = parent;
            parent = position / 2;
        }
        return position;
    }
    else {
        while(1) {
            int smallest = position;
            int child1 = position*2;
            int child2 = position*2+1;
            if (child1 <= heap_size() && min_heap[smallest].second > min_heap[child1].second) {
                smallest = child1;
            }
            if (child2 <= heap_size() && min_heap[smallest].second > min_heap[child2].second) {
                smallest = child2;
            }

            if (smallest != position) {
                swap(smallest, position);
                position = smallest;
            }
            else {
                break;
            }
        }
        return position;
    }
}

// unordered_map<uint64_t, pair<int, int>> hashmap; // <flowkey, <position in min_heap, estimate>>
// pair<uint64_t, int>* min_heap; // <flowkey, estimate>

void PriorityQueue::update(flowkey_t flowkey, int estimate, int isPrint)
{
    if (isPrint) {
        cout << "update!" << endl;
    }
    if (hashmap.find(flowkey) != hashmap.end()) { // flowkey is in the hash map / min heap
        if (isPrint) {
            cout << "in the hashmap!" << endl;
        }

        int original_estimate = hashmap[flowkey].second;
        if (isPrint) {
            cout << "original " << original_estimate << endl;
        }
        if (original_estimate != estimate) {
            if (isPrint) {
                cout << "frequency update" << endl;
            }
            int original_position = hashmap[flowkey].first;
            if (isPrint) {
                cout << "is original position correct?" << endl;
//                cout << original_position << " " << min_heap[original_position].first << " " << min_heap[original_position].second << endl;
            }

            min_heap[original_position].second = estimate;

            hashmap[flowkey].first = min_heap_bubble_up_or_bubble_down(original_position);
            hashmap[flowkey].second = estimate;

//            int position = hashmap[flowkey].first;
//            cout << min_heap[position].first << " " << min_heap[position].second << endl;
        }
    }
    else {
        if (isPrint) {
            cout << "not in the hashmap" << endl;
        }
        if(is_full()) {
            if (isPrint) {
                cout << "full" << endl;
            }
            if(get_min() < estimate) {
                if (isPrint) {
                    cout << "overwrite" << endl;
                }
                flowkey_t min_flowkey = min_heap[1].first;
                hashmap.erase(min_flowkey);

                min_heap[1].first = flowkey;
                min_heap[1].second = estimate;

                int new_position = min_heap_bubble_up_or_bubble_down(1);
                hashmap.insert(make_pair(flowkey, make_pair(new_position, estimate)));
            }
        }
        else {
            if (isPrint) {
                cout << "not full" << endl;
            }
            size++;
            min_heap[size].first = flowkey;
            min_heap[size].second = estimate;
            if (isPrint) {
//                cout << size << " " << flowkey << " " << estimate << endl;
            }
            int position = min_heap_bubble_up_or_bubble_down(size);
            hashmap.insert(make_pair(flowkey, make_pair(position, estimate)));
        }
    }
    if (isPrint) {
        cout << endl;
    }
}
