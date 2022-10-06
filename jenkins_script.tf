locals {
  jenkins_user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y

  #Install Java runtime required by jenkins
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

  #Install git
  sudo apt install git -y

  #Install Maven
  sudo apt install maven -y
  
  #This runs as the root and disables StrictHostChecking
  sudo bash -c 'echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
  
  #Install New relic
  curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=NRAK-DKQ2N9WXV6A63PVHNF3DRG6SHE6 NEW_RELIC_ACCOUNT_ID=3644862 NEW_RELIC_REGION=EU /usr/local/bin/newrelic install -y

  echo "****************Change Hostname(IP) to something readable**************"
  sudo hostnamectl set-hostname Jenkins
  sudo reboot
  EOF
}