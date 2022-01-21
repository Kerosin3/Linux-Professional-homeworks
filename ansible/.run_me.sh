#/bin/bash
vagrant destroy -f && vagrant up
ansible-playbook ./playbooks/servers.yml -f 10
echo 'running main server on 8082 port, reserved server on 8083 localhost'
