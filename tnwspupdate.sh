#!/bin/sh

set -e

kubectl get deployment tnwsp-tnwsp -oyaml|sed "s#docker.corefiling.com/tnwsp/tnwsp:.*#docker.corefiling.com/tnwsp/tnwsp:2.86.0#g"|kubectl replace -f -

echo "TNWSP version should now show as 2.86.0 below"

kubectl get deployment tnwsp-tnwsp -oyaml|grep tnwsp/tnwsp
