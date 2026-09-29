# devstackOptimize

Infraestructura reproducible para desplegar un laboratorio **OpenStack DevStack 2026.1** sobre una VM Ubuntu Noble ejecutada en **KVM/libvirt**.

El repositorio separa dos responsabilidades:

- `terraform/`: crea la VM, disco, cloud-init y sus dos interfaces de red.
- `ansible/`: prepara Ubuntu e instala DevStack/OVN de forma repetible.

## Topología

| Elemento | Valor por defecto |
|---|---|
| VM | `devstack` |
| Administración | `192.168.100.5/24` |
| Gateway administración | `192.168.100.1` |
| Provider | `172.24.4.1/24` |
| Gateway provider | `172.24.4.254` |
| Red de proyecto | `10.10.0.0/24` |
| Floating IPs | `172.24.4.100-172.24.4.200` |
| RAM | 12 GiB |
| vCPU | 4 |
| Disco | 30 GiB |

## Requisitos del host

- Linux con KVM y virtualización anidada disponibles.
- libvirt y `virsh`.
- Terraform >= 1.5.
- Ansible.
- Imagen `noble-server-cloudimg-amd64.img`.
- Clave SSH pública.
- Las redes libvirt `privada` y `netstack` definidas a partir de los XML incluidos en `terraform/networks/`.

Ejemplo para preparar las redes:

```bash
sudo virsh net-define terraform/networks/privada.xml
sudo virsh net-start privada
sudo virsh net-autostart privada

sudo virsh net-define terraform/networks/netstack.xml
sudo virsh net-start netstack
sudo virsh net-autostart netstack
```

## 1. Crear la VM

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Ajusta rutas, recursos y redes si corresponde.

terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Comprueba luego el acceso SSH:

```bash
ssh ubuntu@192.168.100.5
```

## 2. Instalar DevStack

La contraseña de laboratorio no se guarda en Git. Debe entregarse por variable de entorno al controlador Ansible.

```bash
export DEVSTACK_ADMIN_PASSWORD='cambia-esta-clave-local'

cd ../ansible
ansible-playbook -i inventory.yml site.yml
```

La instalación usa un commit fijado de DevStack para que el entorno experimental pueda repetirse. Al finalizar se genera:

```text
/opt/stack/devstack/ansible-experiment-manifest.txt
```

Ese manifiesto registra versiones del sistema y SHA de los componentes principales de OpenStack.

## Diagnóstico

Para seguir el log de instalación:

```bash
ssh ubuntu@192.168.100.5 \
  'sudo -u stack tail -f /opt/stack/devstack/ansible-stack.sh.log'
```

El playbook puede ejecutarse nuevamente. Si cambia el commit de DevStack o `local.conf`, Ansible detecta el cambio, desapila el entorno anterior y vuelve a ejecutar `stack.sh`.

## Seguridad

Este repositorio está pensado para un laboratorio local, no para producción. No almacenes contraseñas reales en `group_vars`, `tfvars`, logs ni commits.

## Estructura

```text
.
├── ansible/
│   ├── group_vars/
│   ├── templates/
│   ├── prepare.yml
│   ├── install.yml
│   └── site.yml
└── terraform/
    ├── config/
    ├── networks/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```
