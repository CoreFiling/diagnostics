#!/bin/bash

usage () {
  echo "USAGE:"
  echo "  command [REQUIRED] --app=(seahorse|platform|beacon) [OPTIONAL] --flag"
  echo "  FLAGS:"
  echo "    -a=*|--app=* to set the app name"
  echo "    -i|--init-containers to include logs from pod init containers"
  echo "    -d|--debug for verbose output"

  exit 0
}

set_flags () {
  for arg in $@; do
    case $arg in
      -h|--help)
        usage
        shift
      ;;
      -a=*|--app=*)
        APP="${arg#*=}"
        shift
      ;;
      -i|--init-containers)
        INIT_CONTAINERS="true"
        shift
      ;;
      -d|--debug)
        DEBUG="true"
        set -x
        shift
      ;;
    esac
  done
}

sys_req () {
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
}

get_pod_logs () {
  kubectl get pods -A 2>&1 > $tmpdir/pods.status.txt

  namespaces=`kubectl get namespaces|awk '{print $1}'|grep -v NAME`

  for namespace in $namespaces; do

    pods=`kubectl get pods -n $namespace --no-headers=true | awk '{print $1}'`
    for pod in $pods; do
      if [ ! -z "$DEBUG" ];then
        echo "Getting logs for pod $pod" 
      fi
      kubectl -n $namespace describe pod $pod > $tmpdir/$pod.describe;
      kubectl -n $namespace logs $pod > $tmpdir/$pod.log;
      if [ $INIT_CONTAINERS=="true" ]; then
        initContainers=`kubectl -n $namespace get pod $pod -o=jsonpath='{.spec.initContainers[*].name}'`
        for initContainer in $initContainers; do
          kubectl -n $namespace logs $pod -c $initContainer > $tmpdir/$pod.$initContainer.log;
        done
      fi
    done

  done
}

get_TNWSP_logs () {
  TNWSP_LOGS=/var/log/tnwsp
  if test -d $TNWSP_LOGS ; then
    echo "Attempting to collect TNWSP logs. Note that you need to re-run this script with 'sudo' if the following step fails"
    tar czf $tmpdir/tnwsp-logs.tar.gz $TNWSP_LOGS
  fi
}

bundle_logs () {
  logbundle=~/$APP-logs.tar.gz
  cd $tmpdir && tar czf $logbundle .
  cd && rm -r $tmpdir
}

set_flags $@

if [ -z "$APP" ]; then
  APP=$( kubectl config view --minify -o jsonpath='{..namespace}' )
fi

echo "Confirming system requirements"
sys_req

tmpdir=/tmp/cfl-logs && rm -rf $tmpdir && mkdir -p $tmpdir

echo "Collecting logs"
get_pod_logs

if [[ "$APP" == "platform" ]]; then
  get_TNWSP_logs
fi

echo "Bundling logs"
bundle_logs

echo "Saved logs to $logbundle"
echo "Please share this file with CoreFiling support to continue diagnosis"
