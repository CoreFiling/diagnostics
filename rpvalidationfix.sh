#!/bin/bash

echo "Scaling TNWSP down"
kubectl scale deployment --replicas=0 tnwsp-tnwsp

echo "Updating TNWSP version"
kubectl get deployments tnwsp-tnwsp -o json | sed 's@"docker.corefiling.com/tnwsp/tnwsp:.*"@"docker.corefiling.com/tnwsp/tnwsp:2.85.0"@' | kubectl replace -f -

echo "Updating plugin version"
sed -i "s#beacon-tnwsp-plugin-.*.jar#beacon-tnwsp-plugin-2.40.4f.jar#g" /opt/cfl/tnwsp/config/processorPoolConfig.xml

echo "Re-enabling report package validation"
sed -i 's#<property name="validate-report-package" value=".*"#<property name="validate-report-package" value="true"#g' /opt/cfl/tnwsp/config/processorPoolConfig.xml

echo "Scaling TNWSP up"
kubectl scale deployment --replicas=1 tnwsp-tnwsp

echo "Applying performance fix"
kubectl get deployments validation-service-impl -o json | sed 's@"docker.corefiling.com/platform/validation-service-impl:.*"@"docker.corefiling.com/platform/validation-service-impl:1.15.0-ci.beacon2471.512634"@' | kubectl replace -f -
