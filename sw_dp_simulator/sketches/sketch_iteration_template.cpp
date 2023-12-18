#include "sketch_iteration_template.h"

// if level = 20,
// for i = 19 ~ 0
// return 0 ~ 20

int get_last_level(uint32_t sampling_hash, int level)
{
    int last_level = 0;

    for(int i=level-1; i>=0; i--) {
        if( ((sampling_hash >> i) & 1)  == 0) {
            return last_level;
        }
        last_level++;
    }
    return last_level;
}
