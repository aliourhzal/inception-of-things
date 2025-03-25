#!/bin/bash

echo -e "\033[1;32mCreating cluster...\033[0m"
k3d cluster create inception

echo -en "\033[1;32mCreating namespaces...\033[0m"
kubectl create namespace gitlab

echo -en "\033[1;32mInstalling Gitlab...\033[0m"
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  -f gitlab-values.yaml

# sleep 30
# echo -en "\r\033[1;32mInitializing cluster...\033[0m"
# while [ true ]; do
#     i=$(kubectl get pods -n gitlab | grep "Running" | wc -l)
#     if [ $i = 23 ]
#     then
#         break
#     fi
# done

# echo -en "\r\033[1;32mCluster initialized...\033[0m"
# GITLAB_PASSWD=$(kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode)

# echo "***********************************************************************************"
# echo "*                                                                                 *"
# echo "*  login: root                                                                    *"
# echo "*  password: $GITLAB_PASSWD     *"
# echo "*  url: localhost:8080                                                            *"
# echo "*                                                                                 *"
# echo "***********************************************************************************"

# #   