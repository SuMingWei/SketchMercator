if [ -z "$1" ]
  then
    CURRENT=`pwd`
    NAME=`basename "$CURRENT"`
    echo "$SDE/run_switchd.sh -p $NAME"
    $SDE/run_switchd.sh -p $NAME
  else
    echo "$SDE/run_switchd.sh -p $1"
    $SDE/run_switchd.sh -p $1
fi
