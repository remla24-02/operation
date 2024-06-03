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

To set up/start the Vagrant nodes with the Ansible provisioning run:
``` console
vagrant up
```
This command creates all the nodes, installs everything on them and start the cluster in the control node.

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

If a node doesn't show up running `vagrant provision` again should fix the problem.
Helm sometimes gets stuck in the Prometheus upgrade, step `TASK [prometheus : Install/upgrade Prometheus using microk8s helm]`, to fix this run:
``` console
vagrant ssh controller -c "sudo microk8s helm rollback prometheus -n monitoring"
vagrant ssh controller -c "sudo microk8s helm uninstall prometheus -n monitoring"
vagrant provision
```
Restart your device or destroy and re-create the nodes is this problems keeps happening.

### Host-based Kubectl
The Ansible setup retrieves the Kubectl config file which allows local Kubectl control over the cluster and stores it in the main directory under the name `microk8s-config`.
As the operating systems differ in how they define their kubeconfig we just provide the file at this level.
(For Linux there is a commented method that can move it directly into their `~/.kube` folder.)
You are free to add these to your bash scripts or just link to them for single shells.


The kubeconfig file can be mentioned directly with commands like this:
``` console
kubectl get nodes -o "wide" --kubeconfig microk8s-config
```
Or it can be linked for the current shell, this will reset for a new shell:
(Linux command in the example)
``` console
export KUBECONFIG=microk8s-config
kubectl get nodes -o "wide"
```
You can move the file and change the path however you like.
With this export of direct definition you can control the cluster from your localhost. 

### Usage
Once the application has been deployed, you can add these lines to your `/etc/hosts` (Linux), `C:\Windows\System32\drivers\etc\hosts` (Windows), or `private/etc/hosts` (macOS).
```
192.168.58.3 app.local
192.168.58.3 prometheus.local
192.168.58.3 grafana.local
```

After which you can access the web application at [app.local](app.local)
The Prometheus dashboard at [prometheus.local](prometheus.local)
And the Grafana dashboard at [grafana.local](grafana.local)

It might take a while for all services to be available like with the nodes from before.
In case it takes a very long time, run the provisioning again to make sure everything got set up correctly.
Again Helm might get stuck but follow the previous explanation again in that case.

``` console
vagrant provision
```

#### Grafana credentials:
- username: admin
- password: prom-operator

## Manual deployment

### Kubernetes
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

### Docker Compose
To run the project, first log in to GitHub Package Registry:

```
docker login ghcr.io
```

Then you can deploy the application by running:

```
docker compose up
```

If you wish to run a different version that the latest change the image tag in the `docker-compose.yml` file.
The available package versions can be found [here](https://github.com/orgs/remla24-02/packages).

## Project structure

``` console
├── ansible                                 # Ansible configuration directory
│   ├── group_vars                          # Variables for groups of hosts
│   │   └── all.yml                         # Variables for all hosts
│   ├── inventory.cfg                       # Inventory file defining hosts and groups              
│   ├── provisioning.yml                    # Main playbook for provisioning
│   └── roles                               # Ansible roles directory
│       ├── deploy                          # Role for deployment tasks
│       │   └── tasks               
│       │       └── main.yml                # Tasks for deployment
│       ├── host                            # Role for host configuration
│       │   └── tasks               
│       │       └── main.yml                # Tasks for host configuration
│       ├── join                            # Role for joining nodes
│       │   └── tasks               
│       │       └── main.yml                # Tasks for joining nodes
│       ├── microk8s                        # Role for MicroK8s installation
│       │   └── tasks               
│       │       └── main.yml                # Tasks for installing MicroK8s
│       ├── prometheus                      # Role for Prometheus setup
│       │   └── tasks               
│       │       └── main.yml                # Tasks for setting up Prometheus
│       └── setup                           # General setup role
│           └── tasks               
│               └── main.yml                # General setup tasks
├── docker-compose.yml                      # Docker Compose configuration file
├── docs                                    # Documentation directory
│   └── ACTIVITY.md                         # Activity log or documentation file
├── kubernetes                              # Kubernetes configuration directory
│   ├── configmaps                          # ConfigMap resources
│   │   ├── model-service-configmap.yml     # ConfigMap for model service
│   │   └── prometheus-configmap.yml        # ConfigMap for Prometheus
│   ├── deployments                         # Deployment resources
│   │   ├── app-deployment.yml              # Deployment for the app
│   │   └── model-service-deployment.yml    # Deployment for the model service
│   ├── helm                                # Helm chart configurations
│   │   └── prometheus-values.yml           # Values file for Prometheus Helm chart
│   ├── ingress                             # Ingress resources
│   │   ├── app-ingress.yml                 # Ingress for the app
│   │   ├── grafana-ingress.yml             # Ingress for Grafana
│   │   └── prometheus-ingress.yml          # Ingress for Prometheus
│   ├── rules                               # Rules configurations
│   │   └── prometheus-rules.yml            # Prometheus alerting rules
│   └── services                            # Service resources
│       ├── app-service.yml                 # Service for the app
│       └── model-service-service.yml       # Service for the model service
├── LICENSE                                 # License file
├── microk8s-config                         # (Non-git) MicroK8s configuration file
├── ping.sh                                 # Shell script for pinging services or hosts
├── README.md                               # Readme file with project information
└── Vagrantfile                             # Vagrant configuration file
```
