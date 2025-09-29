#!/bin/bash

set -euo pipefail

kind create cluster --config cluster.yml --name dev-ingress-cluster

kubectl apply -f namespace.yml

kubectl apply -f pv.yml
kubectl apply -f pvc.yml

kubectl wait --for=condition=Bound pvc/pvc-data -n todoapp --timeout=60s

kubectl apply -f confgiMap.yml
kubectl apply -f secret.yml

kubectl apply -f statefulSet.yml
kubectl rollout status statefulset/mysql -n mysql

kubectl apply -f deployment.yml
