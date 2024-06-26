# operation

## Prerequisites

Make sure the following dependencies are installed and set up.

Automatic deployment:

- [Kubectl](https://k8s-docs.netlify.app/en/docs/tasks/tools/install-kubectl/)
- [Vagrant](https://www.vagrantup.com/) and a supported provider (e.g. [VirtualBox](https://www.virtualbox.org/))
- [Ansible](https://www.ansible.com/)

Manual deployment

- [Docker](https://docs.docker.com/engine/install/)
- [minikube](https://minikube.sigs.k8s.io/docs/start/)

## Provisioning

### Addons (Optional)
Available addons:
- [Kiali](https://kiali.io/)
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)

These are enabled by default. To disable them set `enable_addons: false` in `ansible/group_vars/all.yml`

### Set up

To set up/start the Vagrant nodes with the Ansible provisioning run:
``` console
vagrant up
```
This command creates all the nodes, installs everything on them and start the cluster in the control node.

This command takes a long time to run as it ensures that everything is started up properly, don't cancel the command if it takes a while.
The last step checking that the services are running has limited retries, if this runs out not everything has been started yet, wait a while before using the application.

In case Vagrant does not set up the virtual machines properly, destroy them and rerun the command.
``` console
vagrant destroy
vagrant up
```

The specific node configuration is defined in the Vagrantfile (IP, workers, cores, and memory).
Currently, the controller node is available at `192.168.58.2` and the worked nodes at `[192.168.58.3, 192.168.58.4, ...]` (for as many worker nodes as are configured).
You can check if the nodes are up and running with this command:
(chmod only required once to make the file executable)
``` console
chmod +x ping.sh
./ping.sh
```
Additionally, you can check that all nodes are correctly added to the cluster:
(This requires Kubectl mentioned in the next part, where you can even run this command locally.)
``` console
vagrant ssh controller -c "sudo microk8s kubectl get nodes -o wide"
```

### Host-based Kubectl
The Ansible setup retrieves the Kubectl config file which allows local Kubectl control over the cluster and stores it in the main directory under the name `microk8s-config`.
As the operating systems differ in how they define their kubeconfig we just provide the file at this level.
You are free to add these to your bash scripts or just link to them for single shells.

The kubeconfig file can be mentioned directly with commands like this:
``` console
kubectl get nodes -o wide --kubeconfig microk8s-config
```
Or it can be linked for the current shell, this will reset for a new shell:

Linux/MacOS:
``` console
export KUBECONFIG=microk8s-config
kubectl get nodes -o wide
```
Windows:
``` console
set KUBECONFIG=microk8s-config
kubectl get nodes -o wide
```
You can move the file and change the path however you like.
With this export of direct definition you can control the cluster from your localhost. 

### Usage
Once the application has been deployed, you can add these lines to your `/etc/hosts` (Linux), `C:\Windows\System32\drivers\etc\hosts` (Windows), or `private/etc/hosts` (MacOS).
```
<IP> app.local
<IP> prometheus.local
<IP> grafana.local
<IP> kiali.local
<IP> kubernetes.local
```

Where `<IP>` is the IP address returned by the following command (likely `192.168.58.240`):
```
kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

After which you can access the several services:
- [Web App](app.local): The phishing URL predictor
- [Prometheus](prometheus.local): Monitoring system
- [Grafana](grafana.local): Graphical interface to display the metrics generated by the cluster
- [Kiali](kiali.local): Visualises the service mesh (Istio)
- [Kubernetes Dashboard](https://kubernetes.local): Visualises the kubernetes cluster (Note: this is a HTTPS connection)

To log into the Kubernetes Dashboard you need a token. This token can be obtained like this:

``` console
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | awk '/^microk8s-dashboard-token-/{print $1}') | awk '$1=="token:"{print $2}'
```

#### Sticky sessions
The web application has sticky sessions enabled. This means you will either get the stable release or the canary release. If you'd like to test this, remove the cookies before refreshing. You might need to do this multiple times as the canary build will only show 10% of the time.


### Additional Use Case
A Local Rate Limit is present in the application. It is enforced by an EnvoyFilter present in the file ```kubernetes\app.yml```.
A maximum of 30 requests per minute can be sent to the application. If you would like to increase/decrease the limit, you can change both the parameters ```max_tokens``` and ```tokens_per_fill``` in the EnvoyFiler with the desired value.

## Kubernetes

### Manual Deployment
Start a Kubernetes cluster by running:

```
minikube start --driver=docker
```

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

To access the application via port 5000, you can run:

```
kubectl port-forward svc/app-serv 5000:5000
```

## Docker Compose

### Docker
To run the project, first log in to GitHub Package Registry:

```
docker login ghcr.io
```

Then you can deploy the application by running:

```
docker compose up
```

## Project structure

``` console
├── ansible                       # Ansible configuration directory
│   ├── group_vars                # Directory for group variables
│   │   └── all.yml               # Global variables for all hosts
│   ├── inventory.cfg             # Ansible inventory configuration file
│   ├── provisioning.yml          # Main playbook for provisioning
│   └── roles                     # Directory for Ansible roles
│       ├── addons                # Role for managing addons
│       │   └── tasks
│       │       └── main.yml      # Tasks for addons role
│       ├── deploy                # Role for deploying applications
│       │   └── tasks
│       │       └── main.yml      # Tasks for deploy role
│       ├── host                  # Role to get kube config 
│       │   └── tasks
│       │       └── main.yml      # Tasks for host role
│       ├── join                  # Role for joining nodes to a cluster
│       │   └── tasks
│       │       └── main.yml      # Tasks for join role
│       ├── microk8s              # Role for managing MicroK8s
│       │   └── tasks
│       │       └── main.yml      # Tasks for microk8s role
│       └── setup                 # Role for initial setup
│           └── tasks
│               └── main.yml      # Tasks for setup role
├── docker-compose.yml            # Docker Compose configuration file
├── docs                          # Documentation directory
│   └── ACTIVITY.md               # Documentation of activities
├── kubernetes                    # Kubernetes configurations
│   ├── addons                    # Addons configurations
│   │   ├── grafana.yml
│   │   ├── istio-gateway.yml
│   │   ├── kiali.yml
│   │   └── prometheus.yml
│   ├── app.yml
│   ├── gateway.yml
│   ├── kubernetes-dashboard.yml
│   └── model-service.yml
├── LICENSE                       # License file
├── ping.sh                       # Script to check connectivity
├── README.md                     # Project README file
└── Vagrantfile                   # Vagrant configuration file

```
