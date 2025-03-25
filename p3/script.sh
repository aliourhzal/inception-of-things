#!/usr/bin/sh

echo -e "\033[1;32mCreating cluster...\033[0m"
k3d cluster create inception

echo -e "\033[1;32mCreating namespaces...\033[0m"
kubectl create namespace argocd
kubectl create namespace dev

echo -e "\033[1;32mInstalling ArgoCD...\033[0m"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

while [ true ]; do
    i=$(kubectl get pod -n argocd | grep "Running" | wc -l)
    if [ $i = 7 ]
    then
        break
    else
        echo -en "\r\033[1;32mInitializing cluster...\033[0m"
    fi
done

echo -e "\n\033[1;32mCreating ArgoCD app...\033[0m"
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

kubectl port-forward svc/argocd-server -n argocd 8080:443 &