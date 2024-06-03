# The ip all nodes run on (nodes_ip.0/1 gives problems so start from .2)
nodes_ip = "192.168.58."
start_device = 2

# The control node configuration
controller_cores = 2
controller_mem = 1024 * 6

# The worker nodes configuration
workers = 2
worker_cores = 2
worker_mem = 1024 * 6

# Configure the VM
Vagrant.configure("2") do |config|
    # The box and version used
    config.vm.box = "bento/ubuntu-24.04"
    config.vm.box_version = "202404.26.0"
    
    # Define the controller node
    config.vm.define "controller" do |controller|
        controller.vm.hostname = "controller"
        controller.vm.network "private_network", ip: "#{nodes_ip}#{start_device}"
        controller.vm.provider "virtualbox" do |vb|
            vb.name = "controller"
            vb.memory = controller_mem
            vb.cpus = controller_cores
        end
    end

    # Define the worker nodes
    (1..workers).each do |i|
        config.vm.define "node#{i}" do |worker|
            worker.vm.hostname = "node#{i}"
            worker.vm.network "private_network", ip: "#{nodes_ip}#{start_device + i}"
            worker.vm.provider "virtualbox" do |vb|
                vb.name = "node#{i}"
                vb.memory = worker_mem
                vb.cpus = worker_cores
            end
            # Set up the Ansible playbooks after all nodes created
            if i == workers
                worker.vm.provision :ansible do |a|
                    a.limit = "all"
                    a.compatibility_mode = "2.0"
                    a.playbook = "ansible/provisioning.yml"
                    a.inventory_path = "ansible/inventory.cfg"
                    a.extra_vars = {
                        "controller_ip" => "#{nodes_ip}#{start_device}"
                    }
                end
            end
        end
    end
end
