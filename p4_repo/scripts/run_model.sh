
if [ -z "$1" ]
  then
    CURRENT=`pwd`
    NAME=`basename "$CURRENT"`
    echo "$SDE/run_tofino_model.sh -p $NAME"
    $SDE/run_tofino_model.sh -p $NAME
  else
    echo "$SDE/run_tofino_model.sh -p $1"
    $SDE/run_tofino_model.sh -p $1
fi
