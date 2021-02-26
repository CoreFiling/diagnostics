#!/bin/sh

# CoreFiling script for TNDP troubleshooting, as referenced from the Platform Administration Guide

echo "Checking TNDP installation"

echo "Confirming system requirements"

processors=`grep -c "^processor\s" /proc/cpuinfo`

if [ $processors -lt 4 ]; then
  echo "Available CPUs/cores ($processors) is less than the minimum system requirement of 4. Correct this before continuing."
  exit 1
fi

mem=`grep -i memtotal /proc/meminfo|awk '{print $2}'`

if [ $mem -lt 16284672 ]; then
  echo "Available memory appears to be less than the minimum system requirement of 16GB. Correct this before continuing."
  exit 1
fi

# Now check the pods are running correctly or grab logs if not
echo "Checking running pods"

# For the moment, gather logs for further investigation by CoreFiling
# Future versions may diagnose directly

tmpdir=/tmp/cfl-logs
rm -rf $tmpdir
mkdir -p $tmpdir

kubectl get pods > $tmpdir/pod-status.log

pods=`kubectl get pods|grep -v NAME|awk '{print $1}'|tr '\n' ' '`

for pod in $pods; do
  kubectl describe pod $pod > $tmpdir/$pod.describe;
  kubectl logs $pod > $tmpdir/$pod.log;
done

logbundle=~/tndp-logs.tar.gz

cd $tmpdir && tar czf $logbundle .
cd
rm -r $tmpdir

echo "Logs have been collected to $logbundle"
echo "Please share this file with CoreFiling support to continue diagnosis"
