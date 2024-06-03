#!/bin/bash

# Navigate to the ansible directory
cd ansible

# Check if navigation was successful
if [ $? -ne 0 ]; then
  echo "Failed to navigate to ansible directory. Please ensure the directory exists."
  exit 1
fi

# Execute the ansible ping command
ansible all -m ping -i inventory.cfg

# Check if the ansible command was successful
if [ $? -ne 0 ]; then
  echo "Ansible ping command failed. Please check your Ansible configuration and inventory file."
  exit 1
fi

echo "Ansible ping command executed successfully."
