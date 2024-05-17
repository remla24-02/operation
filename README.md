# operation

## Project structure

TODO

## Running the project

### Docker
To run the project, first login to GitHub Package Registry:

```
docker login ghcr.io
```

Then you can deploy the application by running:

```
docker compose up
```

## Provisioning

### Vagrant
We assume [Vagrant](https://www.vagrantup.com/) and a supported provider (e.g. [VirtualBox](https://www.virtualbox.org/)) are installed.
To set up/start the Vagrant nodes run:
``` console
vagrant up
```

If one of the nodes gets stuck in the `Booting VM...` step this can happen with Vagrant in our experience.
Cancel the startup with `ctrl+C` and check the nodes status to find the faulty node id.
Destroy this node and retry.
To do this run the following commands:
``` console
vagrant global-status
vagrant destroy <fault-node-id>
vagrant up
```

The specific node configuration is defined in the Vagrantfile (ip, workers, cores, and memory).
Currently, the controller node is available at `192.168.58.2` and the worked nodes at `[192.168.58.3, 192.168.58.4, ...]` (as many worker nodes as are configured).

### Ansible
TODO

Once the application has been deployed, you can go to:  http://localhost:8000/



