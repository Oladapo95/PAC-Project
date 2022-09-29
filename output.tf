output "Docker_Server" {
  value = aws_instance.pacpet1_docker.public_ip
}

output "Ansible_Server" {
  value = aws_instance.pacpet1_ansible.public_ip
}

output "Jenkins_Server" {
  value = aws_instance.pacpet1_jenkins.public_ip
}