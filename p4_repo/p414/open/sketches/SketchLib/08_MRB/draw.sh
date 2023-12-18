NAME=p414_original_mrb_level_05
cd $NAME
# /Users/hnamkung/workspace/hun_p4-hlir/bin/p4-graphs original_pcsa_4.p4
# /Users/hnamkung/workspace/hun_p4-hlir/bin/p4-graphs --deps $NAME.p4
# /Users/hnamkung/workspace/hun_p4-hlir/bin/p4-graphs --deps-without-cf-dep $NAME.p4
# /Users/hnamkung/workspace/hun_p4-hlir/bin/p4-graphs --rmt main.p4
/Users/hnamkung/workspace/hun_p4-hlir/bin/p4-graphs --rmt-without-cf-dep $NAME.p4
cd ..

