output "Docker_Server" {
  value = aws_instance.pacpet1_docker.public_ip
}

output "Ansible_Server" {
  value = aws_instance.pacpet1_ansible.public_ip
}

output "Jenkins_Server" {
  value = aws_instance.pacpet1_jenkins.public_ip
}

output "SonarQube_Server" {
  value = aws_instance.pacpet1_sonarqube.public_ip
}

#Export Name Servers
output "NameServers" {
  value = "${aws_route53_zone.pacpet1_hosted_zone.name_servers}"
}

#Load Balancer
output "LoadBalancer" {
  value = "${aws_lb.pacpet1_lb.dns_name}"
}