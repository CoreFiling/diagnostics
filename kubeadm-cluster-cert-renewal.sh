#!/bin/sh

echo ">>> Generating new certificates"
sudo kubeadm certs renew all

echo ">>> Re-starting Kubernetes control plane components"
sudo service kubelet restart

sudo kill -s SIGHUP $(pidof kube-apiserver)
sudo kill -s SIGHUP $(pidof kube-controller-manager)
sudo kill -s SIGHUP $(pidof kube-scheduler)

echo ">>> Waiting 30 seconds for restarts to complete"
sleep 30

echo ">>> Verifying restarted cluster"
echo ">>> The dates to be printed should show expiry 12 months from today:"
# Cert from api-server
echo -n | openssl s_client -connect localhost:6443 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | openssl x509 -text -noout | grep "Not After"
# Cert from controller manager
echo -n | openssl s_client -connect localhost:10257 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | openssl x509 -text -noout | grep "Not After"
# Cert from scheduler
echo -n | openssl s_client -connect localhost:10259 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | openssl x509 -text -noout | grep "Not After"

echo ">>> Copying updated configuration to current user's home directory"
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo ">>> You should see a list of pods below if the cluster is now running correctly"
sudo kubectl get pod -A

echo ">>> You will need to copy /etc/kubernetes/admin.conf to .kube/config for other users who need to run kubectl"
