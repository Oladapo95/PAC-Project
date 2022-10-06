locals {
  ansible_user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y

  echo "*********Install Ansible********"
  sudo apt install software-properties-common
  sudo add-apt-repository --yes --update ppa:ansible/ansible
  sudo apt update -y
  sudo apt install ansible -y

  echo "****************Copy the private key into the Server **************"
  echo "****************Ansible would use this when connecting to the Docker Server **************"
  echo "${file(var.pacpet1_prvkey_path)}" >> ${var.ans_prvkey_path}

  echo "*********This runs as the root and disables StrictHostChecking********"
  sudo bash -c 'echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'

  echo "****Add the Docker Servers IP to the host file and also the localhost for ansible*******"
  sudo bash -c 'echo "localhost ansible_connection=local
  [Docker_Servers]
  ${aws_instance.pacpet1_docker.public_ip} ansible_ssh_private_key_file=${var.ans_prvkey_path}" >> /etc/ansible/hosts'

  echo "*********Install Docker engine ********"
  sudo apt-get install ca-certificates curl gnupg lsb-release -y
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update -y
  sudo apt install docker-ce docker-ce-cli -y

  echo "*******Create Docker File********"
  cd /home/ubuntu/
  mkdir Docker
  echo "*******We change the owner of this directory to ubuntu because ansible********"
  echo "*******would need to drop a file in this directory and it cant do that if its owned by root********"
  sudo chown -R ubuntu:ubuntu Docker
  touch Docker/Dockerfile

  #Insert Content to Docker File
  echo "${file(var.docker_file_path)}" > Docker/Dockerfile

  #Create Ansible Playbook that creates docker image
  mkdir Ansible && touch Ansible/playbook-dockerimage.yaml
  echo "${file(var.docker_image_path)}" > Ansible/playbook-dockerimage.yaml
  
  #Create Ansible Playbook that creates docker container
  touch Ansible/playbook-container.yaml
  echo "${file(var.docker_container_path)}" > Ansible/playbook-container.yaml

  #Create Ansible Playbook that installs new relic infrastructure agent to monitor containers
  touch Ansible/playbook-newrelic.yaml
  echo "${file(var.newrelic_infra_path)}" > Ansible/playbook-newrelic.yaml

  #Install New relic
  curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=NRAK-DKQ2N9WXV6A63PVHNF3DRG6SHE6 NEW_RELIC_ACCOUNT_ID=3644862 NEW_RELIC_REGION=EU /usr/local/bin/newrelic install -y

  echo "****************Change Hostname(IP) to something readable**************"
  sudo hostnamectl set-hostname Ansible
  sudo reboot
  EOF
}