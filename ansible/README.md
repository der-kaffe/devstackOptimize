# Ansible

Antes de ejecutar el despliegue, define la contraseña local de laboratorio en el
entorno del controlador. El playbook exige al menos 8 caracteres y no almacena
el secreto en Git.

```sh
export DEVSTACK_ADMIN_PASSWORD='cambia-esta-clave-local'
ansible-playbook -i inventory.yml site.yml
```

Para seguir el proceso de instalación:

```sh
ssh ubuntu@192.168.100.5 'sudo -u stack tail -f /opt/stack/devstack/ansible-stack.sh.log'
```

Si una instalación no termina, vuelve a ejecutar `site.yml`. El playbook detiene
el estado parcial con `unstack.sh` antes de reintentar; no uses `.stackenv` como
indicador de éxito.

El marker `.ansible-stack-complete` contiene el SHA efectivo de DevStack y el
checksum de `local.conf`. Si cualquiera cambia, el playbook desapila y vuelve a
ejecutar `stack.sh`. Los logs de apilado y desapilado se crean con permisos
privados para `stack`.

Al finalizar, `ansible-experiment-manifest.txt` conserva los SHA de los
componentes OpenStack y versiones relevantes del host para apoyar la
reproducibilidad de los experimentos.
