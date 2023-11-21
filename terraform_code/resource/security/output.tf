output "my_security_group" {
  value = aws_security_group.my_security_group.id
}
 
output "jenkins_security_group" {
  value = aws_security_group.jenkins_cicd.id
}

output "docker_swarm_security_group" {
  value = aws_security_group.Docker_Swarm.id
}
