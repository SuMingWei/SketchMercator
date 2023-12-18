#include "seed.h"

void load_hash_seeds(HashSeedSet &sampling_hash, vector<sketchTemplate> &countSketch_level, parameters &params)
{
    int a;
    string seed_name;
    seed_name = params.hash_seed_name;
//    seed_name = "_02_data_plane/hash_seeds/" + seed_name;
    seed_name = string(std::getenv("sw_dp_simulator")) + "/hash_module/seeds/hash_seeds/" + seed_name;

    // cout << seed_name << endl;
    FILE* fp;
    fp = fopen(seed_name.c_str(), "r");

    char buf[5000];
    fgets(buf, sizeof buf, fp); // 1. basic hash
    fgets(buf, sizeof buf, fp); //
    fgets(buf, sizeof buf, fp); // 1.1 sampling hash


    fscanf(fp, "%s ", buf); // paramA
//    printf("sampingA\n");
    for(int i=0; i<25; i++) {
        fscanf(fp, "%d ", &sampling_hash.aParams[i]);
//        printf("%d\n", sampling_hash.aParams[i]);
    }

    fscanf(fp, "%s ", buf); // paramB
    for(int i=0; i<25; i++) {
        fscanf(fp, "%d ", &sampling_hash.bParams[i]);
    }

    fgets(buf, sizeof buf, fp); // 1.2 sketching hash

    for(int i=0; i<25; i++) {

        for(int k=1; k<=4; k++) {
            if (k == 1 || k == 3) {
                fgets(buf, sizeof buf, fp); // index or res
            }
            fscanf(fp, "%s ", buf); // levelxx
            fscanf(fp, "%s ", buf); // paramA
            for (int j = 0; j < 10; j++) {
                // if (j < params.depth) {
                    if(k == 1) {
                        fscanf(fp, "%d ", &a);
                        countSketch_level[i].index_hash->aParams[j] = a;
                    }
                    if(k == 2) {
                        fscanf(fp, "%d ", &a);
                        countSketch_level[i].index_hash->bParams[j] = a;
                    }
                    if(k == 3) {
                        fscanf(fp, "%d ", &a);
                        countSketch_level[i].res_hash->aParams[j] = a;
                    }
                    if(k == 4) {
                        fscanf(fp, "%d ", &a);
                        countSketch_level[i].res_hash->bParams[j] = a;
                    }
                // } else {
                //     fscanf(fp, "%d ", &a);
                // }
            }
        }
    }

    fgets(buf, sizeof buf, fp); // 2. crc hash
    fgets(buf, sizeof buf, fp); //
    fgets(buf, sizeof buf, fp); // 2.1 sampling hash

    fscanf(fp, "%s ", buf); // paramPoly
//    printf("paramPoly\n");
    for(int i=0; i<25; i++) {
        fscanf(fp, "%d ", &sampling_hash.polyParams[i]);
//        printf("%u\n", sampling_hash.polyParams[i]);
    }

    fgets(buf, sizeof buf, fp); // 2.2 sketching hash

    for(int i=0; i<25; i++) {
        for(int k=1; k<=2; k++) {
            fgets(buf, sizeof buf, fp); // index or res
//            printf("[A] %s", buf);
            fscanf(fp, "%s ", buf); // levelxx
//            printf("[B] %s\n", buf);
            fscanf(fp, "%s ", buf); // paramA
//            printf("[C] %s\n", buf);
//            exit(1);
            for (int j = 0; j < 10; j++) {
                if (j < params.depth) {
                    if(k == 1) {
                        fscanf(fp, "%d ", &a);
                        countSketch_level[i].index_hash->polyParams[j] = a;
                    }
                    if(k == 2) {
                        fscanf(fp, "%d ", &a);
                        countSketch_level[i].res_hash->polyParams[j] = a;
                    }
                } else {
                    fscanf(fp, "%d ", &a);
                }
            }
        }
    }
}
