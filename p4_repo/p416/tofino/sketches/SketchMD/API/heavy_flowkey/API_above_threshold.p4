control ABOVE_THRESHOLD_CONSTANT (
    in bit<32> est_1,
    in bit<32> est_2,
    in bit<32> est_3,
    inout bit<1> is_above_threshold)
{
    bit<32> diff_1;
    bit<32> diff_2;
    bit<32> diff_3;

    action subtract_table_act() {
        diff_1 = est_1 - 1073741824;
        diff_2 = est_2 - 1073741824;
        diff_3 = est_3 - 1073741824;
    }
    action above_threshold_table_act() {
        is_above_threshold = 1;
    }
    apply {
        subtract_table_act();
        if (diff_1[31:31] == 0) {
            above_threshold_table_act();
        }
        else if (diff_2[31:31] == 0) {
            above_threshold_table_act();
        }
        else if (diff_3[31:31] == 0) {
            above_threshold_table_act();
        }
    }
}


control ABOVE_THRESHOLD_CONSTANT_RAND (
    in bit<32> est_1,
    in bit<32> est_2,
    in bit<32> est_3,
    in bit<1> rand,
    inout bit<1> is_above_threshold)
{
    bit<32> diff_1;
    bit<32> diff_2;
    bit<32> diff_3;

    action subtract_table_1() {
        diff_1 = est_1 - 1073741824;
        diff_2 = est_2 - 1073741824;
        diff_3 = est_3 - 1073741824;
    }
    action subtract_table_2() {
        diff_1 = est_1 - 500;
        diff_2 = est_2 - 500;
        diff_3 = est_3 - 500;
    }
    action above_threshold_table_act() {
        is_above_threshold = 1;
    }
    apply {
        if (rand == 0) {
            subtract_table_1();
        }
        else {
            subtract_table_2();
        }
        if (diff_1[31:31] == 0) {
            above_threshold_table_act();
        }
        else if (diff_2[31:31] == 0) {
            above_threshold_table_act();
        }
        else if (diff_3[31:31] == 0) {
            above_threshold_table_act();
        }
    }
}

control ABOVE_THRESHOLD_RAND (
    in bit<32> est_1,
    in bit<32> est_2,
    in bit<32> est_3,
    in bit<32> threshold,
    in bit<1> rand,
    inout bit<1> is_above_threshold)
{
    bit<32> diff_1;
    bit<32> diff_2;
    bit<32> diff_3;

    action subtract_table_1() {
        diff_1 = est_1 - 1073741824;
        diff_2 = est_2 - 1073741824;
        diff_3 = est_3 - 1073741824;
    }
    action subtract_table_2() {
        diff_1 = est_1 - threshold;
        diff_2 = est_2 - threshold;
        diff_3 = est_3 - threshold;
    }
    action above_threshold_table_act() {
        is_above_threshold = 1;
    }
    apply {
        if (rand == 0) {
            subtract_table_1();
        }
        else {
            subtract_table_2();
        }
        if (diff_1[31:31] == 0) {
            above_threshold_table_act();
        }
        else if (diff_2[31:31] == 0) {
            above_threshold_table_act();
        }
        else if (diff_3[31:31] == 0) {
            above_threshold_table_act();
        }
    }
}

// control ABOVE_THRESHOLD_EXACT (
//     in bit<32> est_1,
//     in bit<32> est_2,
//     in bit<32> est_3,
//     inout bit<1> is_above_threshold)
// {
//     bit<32> diff_1;
//     bit<32> diff_2;
//     bit<32> diff_3;

//     action subtract_table_act() {
//         diff_1 = est_1 - 1073741824;
//         diff_2 = est_2 - 1073741824;
//         diff_3 = est_3 - 1073741824;
//     }
//     action above_threshold_table_act() {
//         is_above_threshold = 1;
//     }
//     apply {
//         subtract_table_act();
//         if (diff_1 == 0) {
//             above_threshold_table_act();
//         }
//         else if (diff_2 == 0) {
//             above_threshold_table_act();
//         }
//         else if (diff_3 == 0) {
//             above_threshold_table_act();
//         }
//     }
// }

// control ABOVE_THRESHOLD_RANGE (
//     in bit<32> est_1,
//     in bit<32> est_2,
//     in bit<32> est_3,
//     inout bit<1> is_above_threshold)
// {
//     bit<32> diff_1;
//     bit<32> diff_2;
//     bit<32> diff_3;
//     bit<32> diff_4;
//     bit<32> diff_5;
//     bit<32> diff_6;

//     action subtract_table_act() {
//         diff_1 = est_1 - 1073741824;
//         diff_2 = est_2 - 10000000;
//         diff_3 = est_3 - 10000000;
//         diff_4 = est_1 - 10001500;
//         diff_5 = est_2 - 10001500;
//         diff_6 = est_3 - 10001500;
//     }
//     action above_threshold_table_act() {
//         is_above_threshold = 1;
//     }
//     apply {
//         subtract_table_act();
//         if (diff_1[31:31] == 0 || diff_2[31:31] == 1) {
//             above_threshold_table_act();
//         }
//         else if(diff_3[31:31] == 0 || diff_4[31:31] == 1) {
//             above_threshold_table_act();
//         }
//         else if(diff_5[31:31] == 0 || diff_6[31:31] == 1) {
//             above_threshold_table_act();
//         }
//     }
// }
