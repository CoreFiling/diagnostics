#!/bin/bash

osName=`cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2`
echo -e "OS Version:\t\t" $osName

tndpVer=`ls /usr/local/cfl-charts/pva*.tgz`
echo -e "TNDP Appliance version:\t" ${tndpVer:26:6}

kubeVer=`kubectl version | cut -d '"' -f6`
kubectlVer=`echo $kubeVer | awk '{print $1}'`
k8sVer=`echo $kubeVer | awk '{print $2}'`

echo -e "kubectl version:\t" $kubectlVer
echo -e "Kubernetes version:\t" $k8sVer

helmVer=`helm version | cut -d '"' -f2`
echo -e "Helm version:\t\t" $helmVer

buVer=`kubectl get deployment -oyaml beacon-ui|grep image:|grep -oP '\d+\.\d+\..*'`
echo -e "Beacon UI version:\t" $buVer

tnwspVer=`kubectl get deployment -oyaml tnwsp-tnwsp|grep tnwsp/tnwsp|grep -oP '\d+\.\d+\..*'`
echo -e "TNWSP version:\t\t" $tnwspVer

echo
echo -e "TNWSP Plugin version(s) in use:"
grep -i beacon-tnwsp-plugin  /opt/cfl/tnwsp/config/processorPoolConfig.xml|grep -oP '\d+\.\d+\..*\.jar'|uniq

echo
echo -e "TNEFRVM version(s) in use:"
grep -i tnefrvm  /opt/cfl/tnwsp/config/processorPoolConfig.xml|grep -oP '\d+\.\d+\..*\.jar'|uniq
