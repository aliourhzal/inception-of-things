#!/bin/bash

echo -e "\033[1;32mCreating cluster...\033[0m"
k3d cluster create inception

echo -e "\033[1;32mCreating namespaces...\033[0m"
kubectl create namespace argocd
kubectl create namespace dev
kubectl create namespace gitlab

echo -e "\033[1;32mInstalling Gitlab...\033[0m"
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  -f gitlab-values.yaml

while [ true ]; do
    i=$(kubectl get pod -n gitlab | grep "Running" | wc -l)
    if [ $i = 23 ]
    then
        break
    else
        echo -en "\r\033[1;32mInitializing cluster...\033[0m"
    fi
done


ARGOCD_PASSWD=$(kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode)

echo "***********************************************************************************"
echo "*                                                                                 *"
echo "*  login: root                                                                    *"
echo "*  password: $ARGOCD_PASSWD      *"
echo "*  url: localhost:8080                                                            *"
echo "*                                                                                 *"
echo "***********************************************************************************"

// kubectl port-forward svc/gitlab-webservice-default -n gitlab 8080:8080