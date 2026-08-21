```sh
ansible-vault create group_vars/devstack/vault.yml
# Añade: devstack_admin_password: "una-contraseña-larga-y-única"
ansible-playbook --ask-vault-pass -i inventory.yml site.yml
ssh ubuntu@192.168.100.5 'sudo -u stack tail -f /opt/stack/devstack/ansible-stack.sh.log'
```

Si una instalación no termina, vuelve a ejecutar `site.yml`. El playbook detiene
el estado parcial con `unstack.sh` antes de reintentar; no uses `.stackenv` como
indicador de éxito.

El marker `.ansible-stack-complete` contiene el SHA efectivo de DevStack y el
checksum de `local.conf`. Si cualquiera cambia, el playbook desapila y vuelve a
ejecutar `stack.sh`. Los logs de apilado y desapilado se crean con permisos
privados para `stack`.
