#ifndef SEED_H
#define SEED_H

#include <iostream>
#include <stdio.h>

#include "library/params.h"
#include "library/sketch_template.h"

void load_hash_seeds(HashSeedSet &sampling_hash, vector<sketchTemplate> &level_countSketch, parameters &params);

#endif // SEED_H
