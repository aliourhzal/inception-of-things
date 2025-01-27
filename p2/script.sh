#!/bin/bash

echo -e "\033[1;32mCreating cluster...\033[0m"
k3d cluster create inception

echo -e "\033[1;32mCreating namespaces...\033[0m"
kubectl create namespace argocd
kubectl create namespace dev

echo -e "\033[1;32mInstalling ArgoCD...\033[0m"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


ARGOCD_REPO_SERVER_POD=$(kubectl get pods -n argocd | grep "^argocd-repo-server" | awk '{print $1}')
ARGOCD_REPO_SERVER_STATUS=$(kubectl describe pod $ARGOCD_REPO_SERVER_POD -n argocd | grep "^Status" | awk '{print $2}')

echo -e "\033[1;32mStarting ArgoCD repo server...\033[0m"
while [ $ARGOCD_REPO_SERVER_STATUS != "Running" ]; do
    sleep 1
    ARGOCD_REPO_SERVER_STATUS=$(kubectl describe pod $ARGOCD_REPO_SERVER_POD -n argocd | grep "^Status" | awk '{print $2}')
done

ARGOCD_SERVER_POD=$(kubectl get pods -n argocd | grep "^argocd-server" | awk '{print $1}')
ARGOCD_SERVER_STATUS=$(kubectl describe pod $ARGOCD_SERVER_POD -n argocd | grep "^Status" | awk '{print $2}')

echo -e "\033[1;32mStarting ArgoCD server...\033[0m"
while [ $ARGOCD_SERVER_STATUS != "Running" ]; do
    sleep 1
    ARGOCD_SERVER_STATUS=$(kubectl describe pod $ARGOCD_SERVER_POD -n argocd | grep "^Status" | awk '{print $2}')
done

echo -e "\033[1;32mCreating ArgoCD app...\033[0m"
kubectl apply -f application.yaml

# ARGOCD_PASSWD=$(argocd admin initial-password -n argocd | head -n 1)
ARGOCD_PASSWD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o yaml | grep password | awk '{print $2}' | base64 -d)

echo "************************************************"
echo "*                                              *"
echo "*  login: admin                                *"
echo "*  password: $ARGOCD_PASSWD                  *"
echo "*  url: localhost:8080                         *"
echo "*                                              *"
echo "************************************************"

kubectl port-forward svc/argocd-server -n argocd 8080:443