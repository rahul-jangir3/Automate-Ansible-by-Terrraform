output "docker_instance_ip" {
  value = module.docker_instance.public_ip
}

output "nginx_instance_url" {
  value = "http://${module.nginx_instance.public_ip}"
}
