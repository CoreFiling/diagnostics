#!/bin/bash

echo "Checking licence expiry:"

kubectl get secret platform-licence -oyaml -o jsonpath='{$.data.licence\.jar}'|base64 -d|grep -a "Licence expires"|head -n1|sed -n 's/.*expires \(202[0-9]-[0-9][0-9]-[0-9][0-9]\).*/\1/p'

echo "Checking XBRL processor licence expiry:"

kubectl get secret tnwsp-licence -oyaml -o jsonpath='{$.data.licence\.jar}'|base64 -d|grep -a "Licence expires"|head -n1|sed -n 's/.*expires \(202[0-9]-[0-9][0-9]-[0-9][0-9]\).*/\1/p'

