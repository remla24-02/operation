# The ip all nodes run on (nodes_ip.0/1 gives problems so start from .2)
nodes_ip = "192.168.58."

# The control node configuration
controller_cores = 1
controller_mem = 1024 * 4

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
        controller.vm.network "private_network", ip: nodes_ip + "2"
        controller.vm.provider "virtualbox" do |v|
            v.cpus = controller_cores
            v.memory = controller_mem
        end
    end

    # Define the worker nodes
    (1..workers).each do |i|
        config.vm.define "node#{i}" do |worker|
            worker.vm.network "private_network", ip: nodes_ip + "#{2 + i}"
            worker.vm.provider "virtualbox" do |v|
                v.cpus = worker_cores
                v.memory = worker_mem
            end
        end
    end

    # Set up the Ansible playbooks
#     config.vm.provision :ansible do |a|
#         a.compatibility_mode = "2.0"
#         a.playbook = "provisioning.yml"
#     end
end
