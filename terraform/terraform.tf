terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # La rama 0.9 usa el esquema nativo de libvirt XML.
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9.3"
    }
  }
}
