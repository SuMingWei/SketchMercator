CURRENT=`pwd`
# NAME=`basename "$CURRENT"`

API=${p4_repo}/p414/tofino/sketches/API
common_p4=${p4_repo}/p414/tofino/sketches/common_p4

cd cs
CURRENT=`pwd`
NAME="cs"
library=$CURRENT/library

# cd instance1
# CURRENT=`pwd`
# P4_NAME="p414_${NAME}_instance1"
# $tofino/p4_build-9.0.0.sh  $CURRENT/${P4_NAME}.p4 -- P4_NAME=$P4_NAME P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4} -I ${library}"
# cp -r $SDE/build/p4-build/$P4_NAME/tofino/$P4_NAME/logs .
# cp $SDE/logs/p4-build/$P4_NAME/make.log .
# cd ..

cd instance2
CURRENT=`pwd`
P4_NAME="p414_${NAME}_instance2"
$tofino/p4_build-9.0.0.sh  $CURRENT/${P4_NAME}.p4 -- P4_NAME=$P4_NAME P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4} -I ${library}"
cp -r $SDE/build/p4-build/$P4_NAME/tofino/$P4_NAME/logs .
cp $SDE/logs/p4-build/$P4_NAME/make.log .
cd ..

cd instance3
CURRENT=`pwd`
P4_NAME="p414_${NAME}_instance3"
$tofino/p4_build-9.0.0.sh  $CURRENT/${P4_NAME}.p4 -- P4_NAME=$P4_NAME P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4} -I ${library}"
cp -r $SDE/build/p4-build/$P4_NAME/tofino/$P4_NAME/logs .
cp $SDE/logs/p4-build/$P4_NAME/make.log .
cd ..

cd instance4
CURRENT=`pwd`
P4_NAME="p414_${NAME}_instance4"
$tofino/p4_build-9.0.0.sh  $CURRENT/${P4_NAME}.p4 -- P4_NAME=$P4_NAME P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4} -I ${library}"
cp -r $SDE/build/p4-build/$P4_NAME/tofino/$P4_NAME/logs .
cp $SDE/logs/p4-build/$P4_NAME/make.log .
cd ..

# cd univmon
# CURRENT=`pwd`
# NAME="univmon"
# library=$CURRENT/library

# cd instance1
# CURRENT=`pwd`
# P4_NAME="p414_${NAME}_instance1"
# # $tofino/p4_build-9.0.0.sh  $CURRENT/${P4_NAME}.p4 -- P4_NAME=$P4_NAME P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4} -I ${library}"
# # cp -r $SDE/build/p4-build/$P4_NAME/tofino/$P4_NAME/logs .
# cp $SDE/logs/p4-build/$P4_NAME/make.log .
# cd ..

# cd instance2
# CURRENT=`pwd`
# P4_NAME="p414_${NAME}_instance2"
# # $tofino/p4_build-9.0.0.sh  $CURRENT/${P4_NAME}.p4 -- P4_NAME=$P4_NAME P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4} -I ${library}"
# # cp -r $SDE/build/p4-build/$P4_NAME/tofino/$P4_NAME/logs .
# cp $SDE/logs/p4-build/$P4_NAME/make.log .
# cd ..

# cd instance3
# CURRENT=`pwd`
# P4_NAME="p414_${NAME}_instance3"
# # $tofino/p4_build-9.0.0.sh  $CURRENT/${P4_NAME}.p4 -- P4_NAME=$P4_NAME P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4} -I ${library}"
# # cp -r $SDE/build/p4-build/$P4_NAME/tofino/$P4_NAME/logs .
# cp $SDE/logs/p4-build/$P4_NAME/make.log .
# cd ..

# cd instance4
# CURRENT=`pwd`
# P4_NAME="p414_${NAME}_instance4"
# # $tofino/p4_build-9.0.0.sh  $CURRENT/${P4_NAME}.p4 -- P4_NAME=$P4_NAME P4FLAGS="--no-dead-code-elimination" P4PPFLAGS="-I ${API} -I ${common_p4} -I ${library}"
# # cp -r $SDE/build/p4-build/$P4_NAME/tofino/$P4_NAME/logs .
# cp $SDE/logs/p4-build/$P4_NAME/make.log .
# cd ..

# # cd ..
