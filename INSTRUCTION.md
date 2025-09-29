# ToDo App Kubernetes Deployment Instructions

This document explains how to validate the deployment of the ToDo web application and MySQL StatefulSet in the Kubernetes cluster.

---

## Prerequisites

Make sure you have the following installed:

* **Python 3.8+**
* **Docker**
* **Kind** (Kubernetes in Docker)
* **kubectl**

Ensure your Kubernetes cluster is running:

```bash
kind get clusters
```

---

## Step 1: Deploy the Cluster and Resources

1. Create the Kubernetes cluster:

```bash
bash bootstrap.sh
```

This will perform the following actions:

* Create a kind cluster using `cluster.yml`.
* Apply the `mysql` namespace.
* Deploy PersistentVolume (`pv.yml`) and PersistentVolumeClaim (`pvc.yml`).
* Deploy the ConfigMap (`configMap.yml`) and Secret (`secret.yml`).
* Deploy MySQL StatefulSet (`statefulSet.yml`) with 3 replicas.
* Deploy the ToDo app Deployment (`deployment.yml`).

2. Verify the cluster nodes:

```bash
kubectl get nodes
```

---

## Step 2: Validate Namespace

Check if the `mysql` namespace exists:

```bash
kubectl get ns
```

You should see `mysql` in the list.

---

## Step 3: Validate Persistent Storage

1. Verify the PersistentVolume:

```bash
kubectl get pv
```

2. Verify the PersistentVolumeClaim:

```bash
kubectl get pvc -n mysql
```

Ensure that the PVC is in the `Bound` state.

---

## Step 4: Validate Secrets and ConfigMaps

Check that the secrets are available:

```bash
kubectl get secret app-secret -n mysql -o yml
```

Check the ConfigMap:

```bash
kubectl get configmap app-config -n mysql -o yml
```

---

## Step 5: Validate MySQL StatefulSet

1. Check StatefulSet status:

```bash
kubectl get statefulset -n mysql
```

Ensure there are 3 replicas, and all are `READY`.

2. Check pods:

```bash
kubectl get pods -n mysql -l app=mysql
```

All 3 pods (`mysql-0`, `mysql-1`, `mysql-2`) should be in `Running` state.

3. Validate liveness and readiness probes:

```bash
kubectl describe pod mysql-0 -n mysql
```

You should see that liveness and readiness probes are configured and successful.

4. Connect to the MySQL pod to verify DB creation:

```bash
kubectl exec -it mysql-0 -n mysql -- mysql -u root -p
```

Use the `MYSQL_ROOT_PASSWORD` from the secret. Then run:

```sql
SHOW DATABASES;
```

You should see `tododb` among the databases.

---

## Step 6: Validate ToDo App Deployment

1. Check Deployment status:

```bash
kubectl get deployment -n mysql
```

Ensure the pod is `READY`.

2. Check the pod logs:

```bash
kubectl logs <todoapp-pod-name> -n mysql
```

You should see the application starting successfully and connecting to `mysql-0`.

3. Port-forward to access the app in a browser:

```bash
kubectl port-forward deployment/todoapp 8080:8080 -n mysql
```

Open `http://localhost:8080` in your browser. You should see the ToDo app landing page.

---

## Step 7: Validate Database Connectivity

From the ToDo app pod:

```bash
kubectl exec -it <todoapp-pod-name> -n mysql -- bash
```

Inside the pod, run:

```bash
python manage.py dbshell
```

You should be able to connect to `mysql-0` and query the `tododb` database.
