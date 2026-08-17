locals {
  base_image_path = "${var.path_to_image}/noble-server-cloudimg-amd64.img"
  disk_size_bytes = var.disk_size_gb * 1024 * 1024 * 1024
  fqdn            = "${var.hostname}.${var.domain}"
  ssh_public_key  = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

# Copia la imagen Noble al pool, sin modificar nunca el archivo original.
resource "libvirt_volume" "noble_base" {
  name = "${var.hostname}-noble-base.qcow2"
  pool = var.pool_name

  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = local.base_image_path
    }
  }
}

# Disco copy-on-write de la VM. capacity define de forma declarativa e
# idempotente su tamaño final; la imagen base nunca se redimensiona.
resource "libvirt_volume" "vm_disk" {
  name     = "${var.hostname}-disk.qcow2"
  pool     = var.pool_name
  capacity = local.disk_size_bytes

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.noble_base.path
    format = {
      type = "qcow2"
    }
  }
}

# En 0.9.x cloud-init genera el ISO local; después se carga como un volumen
# libvirt para conectarlo explícitamente al dominio.
resource "libvirt_cloudinit_disk" "devstack_cloudinit" {
  name = "${var.hostname}-cloudinit"

  meta_data = yamlencode({
    instance-id    = var.hostname
    local-hostname = var.hostname
  })

  user_data = templatefile("${path.module}/config/cloud_init.cfg", {
    hostname   = var.hostname
    fqdn       = local.fqdn
    public_key = local.ssh_public_key
  })

  network_config = templatefile("${path.module}/config/network_config.cfg", {
    private_mac          = var.private_mac
    private_ipv4         = var.private_ipv4
    private_gateway_ipv4 = var.private_gateway_ipv4
    netstack_mac         = var.netstack_mac
    netstack_ipv4        = var.netstack_ipv4
    dns_servers          = var.dns_servers
    search_domain        = var.domain
  })
}

resource "libvirt_volume" "cloudinit_iso" {
  name = "${var.hostname}-cloudinit.iso"
  pool = var.pool_name

  target = {
    format = {
      # El proveedor detecta y conserva la imagen de cloud-init como ISO.
      # Declararlo así evita que Terraform intente actualizar un volumen inmutable.
      type = "iso"
    }
  }

  create = {
    content = {
      url = libvirt_cloudinit_disk.devstack_cloudinit.path
    }
  }

  lifecycle {
    replace_triggered_by = [libvirt_cloudinit_disk.devstack_cloudinit]
  }
}

resource "libvirt_domain" "devstack_vm" {
  name        = var.hostname
  type        = "kvm"
  memory      = var.memory_mb
  memory_unit = "MiB"
  vcpu        = var.vcpu

  os = {
    type      = "hvm"
    type_arch = "x86_64"
    boot_devices = [
      {
        dev = "hd"
      },
    ]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = merge({
    disks = [
      {
        device = "disk"
        driver = {
          name = "qemu"
          type = "qcow2"
        }
        source = {
          volume = {
            pool   = var.pool_name
            volume = libvirt_volume.vm_disk.name
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      },
      {
        device    = "cdrom"
        read_only = true
        driver = {
          name = "qemu"
          type = "raw"
        }
        source = {
          volume = {
            pool   = var.pool_name
            volume = libvirt_volume.cloudinit_iso.name
          }
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
      },
    ]
    interfaces = [
      {
        mac = {
          address = var.private_mac
        }
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = var.private_network_name
          }
        }
      },
      {
        mac = {
          address = var.netstack_mac
        }
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = var.netstack_network_name
          }
        }
      },
    ]
    consoles = [
      {
        target = {
          type = "serial"
          port = 0
        }
      },
    ]
    # Sustituye qemu_agent = true de 0.8.x por el canal estándar del agente.
    channels = [
      {
        source = {
          unix = {}
        }
        target = {
          virt_io = {
            name = "org.qemu.guest_agent.0"
          }
        }
      },
    ]
    }, var.enable_spice ? {
    graphics = [
      {
        spice = {
          auto_port = true
          listen    = "127.0.0.1"
        }
      },
    ]
  } : {})

  # La IP y la clave se aplican en el primer arranque; un cambio de cloud-init
  # requiere una VM nueva para que el ISO actualizado se procese de nuevo.
  lifecycle {
    replace_triggered_by = [libvirt_cloudinit_disk.devstack_cloudinit]
  }
}
