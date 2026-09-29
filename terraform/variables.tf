variable "hostname" {
  description = "Nombre de la máquina virtual."
  type        = string
  default     = "devstack"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,62}$", var.hostname))
    error_message = "hostname debe usar minúsculas, números o guiones y tener hasta 63 caracteres."
  }
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

  validation {
    condition     = var.memory_mb >= 8192
    error_message = "memory_mb debe ser al menos 8192 MiB para este laboratorio DevStack."
  }
}

variable "vcpu" {
  description = "Número de vCPU de la VM."
  type        = number
  default     = 4

  validation {
    condition     = var.vcpu >= 2
    error_message = "vcpu debe ser al menos 2."
  }
}

variable "disk_size_gb" {
  description = "Capacidad final del disco derivado de la VM, en GiB."
  type        = number
  default     = 30

  validation {
    condition     = var.disk_size_gb >= 30
    error_message = "disk_size_gb debe ser como mínimo 30 GiB para evitar instalaciones incompletas de DevStack."
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

variable "libvirt_uri" {
  description = "URI de conexión a libvirt."
  type        = string
  default     = "qemu:///system"
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

  validation {
    condition     = can(regex("^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$", var.private_mac))
    error_message = "private_mac debe tener formato xx:xx:xx:xx:xx:xx."
  }
}

variable "netstack_mac" {
  description = "MAC estable de la interfaz conectada a DevStack."
  type        = string
  default     = "52:54:00:24:04:01"

  validation {
    condition     = can(regex("^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$", var.netstack_mac))
    error_message = "netstack_mac debe tener formato xx:xx:xx:xx:xx:xx."
  }
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
  default     = ["192.168.100.1"]

  validation {
    condition     = length(var.dns_servers) > 0
    error_message = "dns_servers debe contener al menos un servidor DNS."
  }
}

variable "enable_spice" {
  description = "Habilita SPICE solo cuando se utilizará una consola gráfica."
  type        = bool
  default     = false
}
