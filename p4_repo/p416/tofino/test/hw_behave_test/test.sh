if [ -z "$1" ]
  then
    echo "[1] hardware switch (0) or simulator (1)"
  else
    python $tofino_cp/test_main.py --test read_delay --is_simulator $1 --int_args1 16384 --int_args2 32
fi
