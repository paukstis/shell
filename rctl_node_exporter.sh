#!/bin/sh

make_text() {
  TYPE=$1
  PTAG=$(echo $LABEL | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
  BUF=$(printf "$BUF# HELP $PREFIX$PTAG $LABEL\n# TYPE $PREFIX$PTAG $TYPE%s" "\n")
  for JAIL in $JAILS; do
    OUT=$(rctl -u jail:$JAIL)
    STAT=$(printf "$OUT" | grep "^$LABEL=" | cut -d '=' -f2)
    BUF=$(printf "$BUF$PREFIX$PTAG{jail=\"$JAIL\"} %.0f%s" "$STAT" "\n")
  done
}

MY_FILE="/var/tmp/node_exporter/jail_rctl"
PREFIX="node_jail_rctl_"
BUF=""

set $(jls -h name)
shift # remove first line which is header 'name'
JAILS=$@

for LABEL in "datasize" "stacksize" "memoryuse" "openfiles" "nthr" "pcpu" "maxproc"; do
  make_text "gauge"
done

for LABEL in "cputime" "wallclock"; do
  make_text "counter"
done

printf "$BUF" >> ${MY_FILE}
/bin/mv -f ${MY_FILE} ${MY_FILE}.prom
