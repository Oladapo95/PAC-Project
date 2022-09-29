locals {
  jenkins_user_data = <<-EOF
  #!/bin/bash
  echo "*********Install Jenkins engine ********"
  sudo apt update -y
  sudo hostname Jenkins

  echo "*********Install Java runtime required by jenkins ********"
  sudo apt install openjdk-11-jre-headless -y

  echo "*********Install Jenkins ********"
  curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

  echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

  sudo apt-get update
  sudo apt-get install jenkins -y
  echo "*********Jenkins Install Complete********"

  echo "*****Install git*********"
  sudo apt install git -y

  echo "*****Install Maven*******"
  sudo apt install maven -y

  
  echo "*********This runs as the root and disables StrictHostChecking********"
  sudo bash -c 'echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
  sudo reboot
  
  EOF
}