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
docker-compose up
```

## Provisioning
We assume [Vagrant](https://www.vagrantup.com/), a supported provider (e.g. [VirtualBox](https://www.virtualbox.org/)), and [Ansible](https://www.ansible.com/) are installed.
To set up/start the Vagrant nodes with the Ansible provisioning run:
``` console
vagrant up
vagrant provision
vagrant provision
```
The first command creates all the nodes, installs everything on them and start the cluster in the control node.
As registering the worker nodes is tricky this requires the other 2! calls to provision.
NOTE: This only applies when creating the nodes the first time.

If you get a VBoxManage error asking to disable the KVM kernel extension run:
(This clashes with Docker so restart if needed.)
``` console
sudo rmmod kvm-intel
vagrant up
vagrant provision
vagrant provision
```

In our experience, it can happen that one of the nodes gets stuck in some steps (e.g. `Booting VM...`) due to some faulty node setup from Vagrant leaving the node unusable.
Do mind that some steps such as installing big things (e.g. `MicroK8s`) can require a few minutes depending on your machine.
Cancel the startup with `Ctrl+C` and check the node's status to find the faulty node id.
Destroy this node and retry.
To do this run the following commands:
(In case it's the controller node you might need to rerun the provisioning of the workers (`vagrant up --provision`).)
``` console
vagrant global-status
vagrant destroy <fault-node-id>
vagrant up
vagrant provision
vagrant provision
```

The specific node configuration is defined in the Vagrantfile (IP, workers, cores, and memory).
Currently, the controller node is available at `192.168.58.2` and the worked nodes at `[192.168.58.3, 192.168.58.4, ...]` (for as many worker nodes as are configured).
You can check if the nodes are up and running with this command:
(Sometimes the ping command fails in the main directory, in that case run it in the ansible directory with a correct inventory path.)
``` console
ansible all -m ping -i ansible/inventory.cfg
```
Additionally, you can check that all nodes are correctly added to the cluster:
``` console
vagrant ssh controller -c "sudo microk8s kubectl get nodes -o wide"
```
If a node doesn't show up running `vagrant provision` again should fix the problem.
As previously mentioned, they don't always attach properly.

## Usage
Once the application has been deployed, you can go to http://localhost:8000/
