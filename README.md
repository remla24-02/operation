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

### Vagrant
We assume [Vagrant](https://www.vagrantup.com/) and a supported provider (e.g. [VirtualBox](https://www.virtualbox.org/)) are installed.
To set up/start the Vagrant nodes run:
``` console
vagrant up
```
If you get a VBoxManage error asking to disable the KVM kernel extension run: (This might clash with Docker)
``` console
sudo rmmod kvm-intel
vagrant up
```

In our experience, it can happen that one of the nodes gets stuck in some steps (`Booting VM...`, `Reboot to update docker group`, etc.) due to some faulty node setup from Vagrant leaving the node unusable.
Cancel the startup with `Ctrl+C` and check the node's status to find the faulty node id.
Destroy this node and retry.
To do this run the following commands:
``` console
vagrant global-status
vagrant destroy <fault-node-id>
vagrant up
```

The specific node configuration is defined in the Vagrantfile (IP, workers, cores, and memory).
Currently, the controller node is available at `192.168.58.2` and the worked nodes at `[192.168.58.3, 192.168.58.4, ...]` (for as many worker nodes as are configured).

### Ansible
TODO

Once the application has been deployed, you can go to http://localhost:8000/
