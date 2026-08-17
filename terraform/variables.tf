variable "hostname" {
  description = "Nombre de la máquina virtual."
  type        = string
  default     = "devstack"
}

variable "domain" {
  description = "Dominio DNS de la máquina virtual."
  type        = string
  default     = "midominio.org"
}

variable "memory_mb" {
  description = "Memoria RAM de la VM, en MiB."
  type        = number
  default     = 12288
}

variable "vcpu" {
  description = "Número de vCPU de la VM."
  type        = number
  default     = 4
}

variable "disk_size_gb" {
  description = "Capacidad final del disco derivado de la VM, en GiB."
  type        = number
  default     = 30

  validation {
    condition     = var.disk_size_gb >= 10
    error_message = "disk_size_gb debe ser como mínimo 10 GiB."
  }
}

variable "path_to_image" {
  description = "Directorio que contiene noble-server-cloudimg-amd64.img."
  type        = string
  default     = "/home/juanc/vmstore/images"
}

variable "pool_name" {
  description = "Nombre del pool de almacenamiento libvirt existente."
  type        = string
  default     = "pool"
}

variable "ssh_public_key_path" {
  description = "Ruta a la clave pública SSH que cloud-init instalará para el usuario por defecto de la imagen."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "private_network_name" {
  description = "Red libvirt privada de administración."
  type        = string
  default     = "privada"
}

variable "netstack_network_name" {
  description = "Red libvirt conectada a DevStack."
  type        = string
  default     = "netstack"
}

variable "private_mac" {
  description = "MAC estable de la interfaz de administración."
  type        = string
  default     = "52:54:00:64:00:05"
}

variable "netstack_mac" {
  description = "MAC estable de la interfaz conectada a DevStack."
  type        = string
  default     = "52:54:00:24:04:01"
}

variable "private_ipv4" {
  description = "IPv4 estática de administración de la VM. .1 se reserva para el gateway."
  type        = string
  default     = "192.168.100.5"
}

variable "private_gateway_ipv4" {
  description = "Gateway IPv4 de la red privada."
  type        = string
  default     = "192.168.100.1"
}

variable "netstack_ipv4" {
  description = "IPv4 estática de la interfaz netstack."
  type        = string
  default     = "172.24.4.1"
}

variable "dns_servers" {
  description = "Servidores DNS de la interfaz privada."
  type        = list(string)
  default     = ["8.8.8.8"]
}

variable "enable_spice" {
  description = "Habilita SPICE solo cuando se utilizará una consola gráfica."
  type        = bool
  default     = false
}
