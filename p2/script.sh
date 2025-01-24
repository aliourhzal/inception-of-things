#! /bin/bash

k3d cluster create inception

kubectl create namespace argocd
kubectl create namespace dev

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


ARGOCD_SERVER_POD=$(kubectl get pods -n argocd | awk 'NR==8' | awk '{print $1}')
ARGOCD_SERVER_STATUS=$(kubectl describe pod $(ARGOCD_SERVER_POD) -n argocd | grep "^Status" | awk '{print $2}')

while [ $ARGOCD_SERVER_STATUS != "Running" ]; do
    sleep 1
    echo -e "\e[1;31mArgoCD server not ready yet ...\e[0m"
    ARGOCD_SERVER_STATUS=$(kubectl describe pod $(ARGOCD_SERVER_POD) -n argocd | grep "^Status" | awk '{print $2}')
done

kubectl apply -f application.yaml

ARGOCD_PASSWD = $(argocd admin initial-password -n argocd | head -n 1)

echo -e "\e[1;32m$ARGOCD_PASSWD\e[0m"

# kubectl port-forward svc/argocd-server -n argocd 8080:443