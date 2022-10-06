locals {
  docker_user_data = <<-EOF
  #!/bin/bash
  echo "*********Install Docker engine ********"
  sudo apt update -y
  sudo apt-get install ca-certificates curl gnupg lsb-release -y
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update -y
  sudo apt install docker-ce docker-ce-cli -y
  
  echo "****************Change Hostname(IP) to something readable**************"
  sudo hostnamectl set-hostname Docker
  sudo reboot
  EOF
}