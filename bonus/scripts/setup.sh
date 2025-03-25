#!/bin/bash

create cluster
k3d cluster create inception -p "8080:80@loadbalancer"

# create namespaces
kubectl create namespace gitlab
kubectl create namespace dev
kubectl create namespace argocd

#install gitlab
kubectl apply -n gitlab -f ../confs/gitlab.yaml

echo -e "\r\033[1;32mInitializing Gitlab...\033[0m"
while [ true ]; do
    i=$(kubectl get pod -n gitlab | grep "Running" | wc -l)
    if [ $i = 1 ]
    then
        break
    fi
done

echo -e "\r\033[1;32mInitializing ArgoCD...\033[0m"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
while [ true ]; do
    i=$(kubectl get pod -n argocd | grep "Running" | wc -l)
    if [ $i = 7 ]
    then
        break
    fi
done

kubectl apply -f ../confs/argocd.yaml

ARGOCD_PASSWD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o yaml | grep password | awk '{print $2}' | base64 -d)
GITLAB_POD_NAME=$(kubectl get pods -n gitlab | grep "gitlab-deployment" | awk '{print $1}')
GITLAB_PASSWD=$(kubectl exec -it -n gitlab $GITLAB_POD_NAME -- cat /etc/gitlab/initial_root_password | grep "Password:" | awk '{print $2}' )

echo "**********************************************************************"
echo "*  ArgoCD:                                                           *"
echo "*     login: admin                                                   *"
echo "*     password: $ARGOCD_PASSWD                                     *"
echo "*     url: argocd.local:8081                                         *"
echo "*                                                                    *"
echo "*   Gitlab                                                           *"
echo "*     login: root                                                    *"
echo "*     password: $GITLAB_PASSWD"
echo "*     url: gitlab.local:8080                                         *"
echo "**********************************************************************"

kubectl port-forward svc/argocd-server -n argocd 8081:443

