#!/bin/bash

# Add entries to /etc/hosts
echo "Adding entries to /etc/hosts..."
echo "192.168.133.135 control" | sudo tee -a /etc/hosts
echo "192.168.133.136 node1" | sudo tee -a /etc/hosts
echo "192.168.133.137 node2" | sudo tee -a /etc/hosts
echo "192.168.133.131 node3" | sudo tee -a /etc/hosts
echo "192.168.133.132 node4" | sudo tee -a /etc/hosts
echo "192.168.133.133 node5" | sudo tee -a /etc/hosts
echo "Entries added to /etc/hosts."

# Ping the nodes
echo "Pinging nodes..."
ping -c 1 node1
ping -c 1 node2
ping -c 1 node3
ping -c 1 node4
ping -c 1 node5
echo "Ping completed."

# Install Ansible and ansible-navigator
echo "Installing Ansible and ansible-navigator..."
sudo dnf install ansible-core python3-pip vim -y
pip install ansible-navigator
echo "Ansible and ansible-navigator installed."

# Install Podman
echo "Installing Podman..."
sudo dnf install podman -y
echo "Podman installed."

# Configure Vim
echo "Configuring Vim..."
echo "set ai" >> ~/.vimrc
echo "set ts=2" >> ~/.vimrc
echo "set et" >> ~/.vimrc
echo "set cursorcolumn" >> ~/.vimrc
echo "Vim configured."

# Create Ansible directories
echo "Creating Ansible directories..."
mkdir -p /home/student/ansible/mycollection
mkdir -p /home/student/ansible/roles
echo "Ansible directories created."

# Create the Ansible inventory file
echo "Creating Ansible inventory file..."
cat > /home/student/ansible/inventory << EOF
[dev]
node1
[test]
node2
[prod]
node[3:4]
[balancers]
node5
[webservers:children]
prod
EOF
echo "Ansible inventory file created."

# List hosts using Ansible
echo "Listing hosts using Ansible..."
ansible -i /home/student/ansible/inventory all --list-hosts

# Create the Ansible configuration file
echo "Creating Ansible configuration file..."
cat > /home/student/ansible/ansible.cfg << EOF
[defaults]
inventory = /home/student/ansible/inventory
roles_path = /home/student/ansible/roles
collection_path = /home/student/ansible/mycollection
remote_user = student
ask_pass = false
host_key_checking = false

[privilage_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = false
EOF
echo "Ansible configuration file created."

# Display Ansible version
echo "Displaying Ansible version..."
ansible --version

# Generate SSH keys
echo "Generating SSH keys..."
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Start the SSH agent
eval $(ssh-agent -s)

# Add the SSH key to the agent
ssh-add ~/.ssh/id_rsa



# Create a variable for the common password
PASSWORD="1234567890"

# Create an array of target servers
SERVERS=("node1" "node2" "node3" "node4" "node5")

# Loop through the servers and copy SSH keys
for SERVER in "${SERVERS[@]}"; do
    echo "Copying SSH key to $SERVER..."
    sshpass -p "$PASSWORD" ssh-copy-id "student@$SERVER"
    echo "SSH key copied to $SERVER."
done

cd /home/student/ansible/
ansible all -m ping

echo "Script completed."

