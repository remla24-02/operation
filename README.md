# operation

## Project structure

TODO

## Running the project

### Docker
To run the project, first log in to GitHub Package Registry:

```
docker login ghcr.io
```

Then you can deploy the application by running:

```
docker compose up
```

## Provisioning
We assume [Vagrant](https://www.vagrantup.com/), a supported provider (e.g. [VirtualBox](https://www.virtualbox.org/)), and [Ansible](https://www.ansible.com/) are installed.
To set up/start the Vagrant nodes with the Ansible provisioning run:
``` console
vagrant up
```
This command creates all the nodes, installs everything on them and start the cluster in the control node.

The specific node configuration is defined in the Vagrantfile (IP, workers, cores, and memory).
Currently, the controller node is available at `192.168.58.2` and the worked nodes at `[192.168.58.3, 192.168.58.4, ...]` (for as many worker nodes as are configured).
You can check if the nodes are up and running with this command:
(Sometimes the ping command fails in the main directory, in that case, run it in the ansible directory with a correct inventory path.)
``` console
ansible all -m ping -i ansible/inventory.cfg
```
Additionally, you can check that all nodes are correctly added to the cluster:
(This requires Kubectl mentioned in the next part, where you can even run this command locally.)
``` console
vagrant ssh controller -c "sudo microk8s kubectl get nodes -o wide"
```
If a node doesn't show up running `vagrant provision` again should fix the problem.

### Host-based Kubectl
The Ansible setup retrieves the Kubectl config file which allows local Kubectl control over the cluster and stores it in the main directory under the name `microk8s-config`.
As the operating systems differ in how they define their kubeconfig we just provide the file at this level.
(For Linux there is a commented method that can move it directly into their `~/.kube` folder.)
You are free to add these to your bash scripts or just link to them for single shells.

To use the host-based Kubectl we assume that [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) (other sources exist) is installed.
The kubeconfig file can be mentioned directly with commands like this:
``` console
kubectl get nodes --kubeconfig microk8s-config
```
Or it can be linked for the current shell, this will reset for a new shell:
(Linux command in the example)
``` console
export KUBECONFIG=microk8s-config
kubectl get nodes
```
You can move the file and change the path however you like.
With this export of direct definition you can control the cluster from your localhost. 

## Usage
Once the application has been deployed, you can go to http://localhost:8000/

## Kubernetes

### Requirements

Make sure that [minikube](https://minikube.sigs.k8s.io/docs/start/) and [Docker](https://www.docker.com/) are installed and start a Kubernetes cluster by running:

```
minikube start --driver=docker
```

### Manual Deployment

Note: Make sure to have enabled the ingress addons by running:

```
minikube addons enable ingress
```

If you would like to manually deploy the application to a Kubernetes cluster, go to the directory ```kubernetes``` and run:

```
kubectl apply -f deployment.yml
```

Then you can tunnel the Ingress to localhost, by running:

```
minikube tunnel
```

After this, you can access the application by going to http://localhost

To access the application via port 8000, you can run:

```
kubectl port-forward svc/app-serv 8000:8000
```


