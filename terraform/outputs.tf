output "vm_name" {
  description = "Nombre de la máquina virtual creada en libvirt."
  value       = libvirt_domain.devstack_vm.name
}

output "vm_fqdn" {
  description = "FQDN configurado mediante cloud-init."
  value       = local.fqdn
}

output "vm_private_ipv4" {
  description = "IPv4 estática configurada en la red privada."
  value       = var.private_ipv4
}

output "vm_netstack_ipv4" {
  description = "IPv4 estática configurada en la red netstack."
  value       = var.netstack_ipv4
}
