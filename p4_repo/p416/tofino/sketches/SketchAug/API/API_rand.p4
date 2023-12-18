control CALC_RNG(out bit<5> random_number)
{
    Random<bit<5>>() rng;
    action get_random() {
        random_number = rng.get();
    }
    table random {
        actions = { get_random; }
        default_action = get_random();
        size = 1;
    }
    apply {
        random.apply();
    }
}